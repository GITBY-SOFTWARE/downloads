#!/bin/sh

# Install the Gitby CLI + TUI without root access.
#
# Overrides:
#   GITBY_VERSION=0.1.42          install a specific release (default: latest)
#   GITBY_CHANNEL=development      install the development channel (dev stack;
#                                  a moving pre-release built from every push to
#                                  main). Default is the "release" channel.
#   GITBY_INSTALL_DIR=/some/path  install somewhere other than ~/.local/bin
#   GITBY_NO_MODIFY_PATH=1        do not update the user's shell profile
#   GITBY_DOWNLOAD_BASE=https://  use a custom release base (tests/mirrors)
#
# Everything below is function definitions until the last line calls main, so
# a download cut off part-way (`curl ... | sh`) runs nothing at all.
#
# The archive is checked against the release's SHA256SUMS. That file comes
# from the same release, so the check catches a truncated or corrupted
# download, not a release replaced as a whole: artifact signing is still to
# come.

set -eu
umask 077

repo="GITBY-SOFTWARE/downloads"

say() {
    printf '%s\n' "$*"
}

die() {
    printf 'gitby install: %s\n' "$*" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

download() {
    url=$1
    destination=$2
    if command_exists curl; then
        case "$url" in
            https://*) curl --proto '=https' --proto-redir '=https' --tlsv1.2 -fL --retry 3 --connect-timeout 10 "$url" -o "$destination" ;;
            *) curl -fL --retry 3 --connect-timeout 10 "$url" -o "$destination" ;;
        esac
    elif command_exists wget; then
        wget -q --https-only --tries=3 -O "$destination" "$url"
    else
        die "curl or wget is required"
    fi
}

sha256() {
    if command_exists sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    elif command_exists shasum; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        die "sha256sum or shasum is required to verify the download"
    fi
}

# Set os, arch and asset for this machine, or stop with a clear message when
# Gitby publishes no build for it (instead of a bare 404 from the download).
detect_target() {
    os_name=${GITBY_OS:-$(uname -s 2>/dev/null || true)}
    arch_name=${GITBY_ARCH:-$(uname -m 2>/dev/null || true)}

    case "$os_name" in
        Linux) os=linux ;;
        Darwin) os=macos ;;
        *) die "unsupported operating system: ${os_name:-unknown} (use install.ps1 on Windows)" ;;
    esac

    case "$arch_name" in
        x86_64|amd64) arch=x64 ;;
        arm64|aarch64) arch=arm64 ;;
        *) die "unsupported CPU architecture: ${arch_name:-unknown}" ;;
    esac

    # A shell running under Rosetta on an Apple Silicon Mac reports x86_64;
    # the Mac itself runs the native arm64 build.
    if [ "$os" = macos ] && [ "$arch" = x64 ] && [ -z "${GITBY_ARCH:-}" ] &&
        [ "$(sysctl -n hw.optional.arm64 2>/dev/null || true)" = 1 ]; then
        arch=arm64
    fi

    # Only the builds a release publishes.
    case "$os-$arch" in
        linux-x64|macos-arm64) ;;
        macos-x64) die "Gitby does not publish a build for Intel Macs yet (macOS builds are Apple Silicon only)" ;;
        linux-arm64) die "Gitby does not publish a Linux ARM64 build yet (Linux builds are x64 only)" ;;
        *) die "Gitby does not publish a build for ${os}/${arch}" ;;
    esac

    asset="gitby-${os}-${arch}.tar.gz"
}

main() {
    version=${GITBY_VERSION:-latest}
    channel=${GITBY_CHANNEL:-release}
    detect_target

    if [ -n "${GITBY_DOWNLOAD_BASE:-}" ]; then
        base=${GITBY_DOWNLOAD_BASE%/}
    elif [ "$channel" = development ]; then
        # The development channel is a single moving pre-release
        # ("development") built from every push to main. Those binaries point
        # at the dev stack, not gitby.cloud - not for production use.
        # GITBY_VERSION is ignored here.
        base="https://github.com/${repo}/releases/download/development"
    elif [ "$version" = latest ]; then
        base="https://github.com/${repo}/releases/latest/download"
    else
        case "$version" in v*) release_tag=$version ;; *) release_tag="v$version" ;; esac
        base="https://github.com/${repo}/releases/download/${release_tag}"
    fi

    [ "$channel" = development ] && say "Using the development channel (dev stack; not for production)."

    if [ -n "${GITBY_INSTALL_DIR:-}" ]; then
        install_dir=$GITBY_INSTALL_DIR
    else
        [ -n "${HOME:-}" ] || die "HOME is not set; provide GITBY_INSTALL_DIR"
        install_dir="$HOME/.local/bin"
    fi

    tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/gitby-install.XXXXXX") || die "could not create a temporary directory"
    cleanup() {
        rm -rf "$tmp_dir"
    }
    # The signals exit, so the EXIT trap cleans up once and nothing after an
    # interrupt keeps running (a trap that only cleaned up let it continue).
    trap cleanup 0
    trap 'exit 1' HUP INT TERM

    say "Downloading Gitby for ${os}/${arch}..."
    download "$base/$asset" "$tmp_dir/$asset"
    download "$base/SHA256SUMS" "$tmp_dir/SHA256SUMS"

    expected=$(awk -v name="$asset" '$2 == name { print $1; exit }' "$tmp_dir/SHA256SUMS")
    case "$expected" in
        ''|*[!0-9A-Fa-f]*) die "release checksum for $asset is missing or invalid" ;;
    esac
    [ "${#expected}" -eq 64 ] || die "release checksum for $asset is missing or invalid"

    actual=$(sha256 "$tmp_dir/$asset")
    expected=$(printf '%s' "$expected" | tr 'A-F' 'a-f')
    actual=$(printf '%s' "$actual" | tr 'A-F' 'a-f')
    [ "$actual" = "$expected" ] || die "checksum mismatch for $asset"

    command_exists tar || die "tar is required to unpack Gitby"
    # Unpack everything: the archive carries `gitby` and, on platforms that
    # have it, the `gitby-browser` sidecar next to it. Gitby finds the sidecar
    # beside its own binary, so both must land in the same directory.
    tar -xzf "$tmp_dir/$asset" -C "$tmp_dir"
    [ -f "$tmp_dir/gitby" ] && [ ! -L "$tmp_dir/gitby" ] || die "release archive did not contain a regular gitby binary"

    mkdir -p "$install_dir"
    staged="$install_dir/.gitby.new.$$"
    cp "$tmp_dir/gitby" "$staged"
    chmod 0755 "$staged"
    mv -f "$staged" "$install_dir/gitby"

    # The browser sidecar, when the archive shipped one: install it next to
    # gitby. When it did not, an older one there would be paired with a newer
    # client, so it goes and gitby fetches the sidecar published for its own
    # version instead.
    if [ -f "$tmp_dir/gitby-browser" ] && [ ! -L "$tmp_dir/gitby-browser" ]; then
        staged_browser="$install_dir/.gitby-browser.new.$$"
        cp "$tmp_dir/gitby-browser" "$staged_browser"
        chmod 0755 "$staged_browser"
        mv -f "$staged_browser" "$install_dir/gitby-browser"
    elif [ -f "$install_dir/gitby-browser" ] || [ -L "$install_dir/gitby-browser" ]; then
        rm -f "$install_dir/gitby-browser"
    fi

    path_changed=no
    case ":${PATH:-}:" in
        *:"$install_dir":*) ;;
        *)
            if [ -z "${GITBY_NO_MODIFY_PATH:-}" ] && [ "$install_dir" = "${HOME:-}/.local/bin" ]; then
                # Appended, never prepended: a user-writable folder ahead of the
                # system ones would let anything dropped there shadow system
                # commands. `old_line` is what earlier installers wrote.
                shell_name=${SHELL##*/}
                path_line='export PATH="$PATH:$HOME/.local/bin"'
                old_line='export PATH="$HOME/.local/bin:$PATH"'
                case "$shell_name" in
                    zsh) profile="$HOME/.zshrc" ;;
                    bash) profile="$HOME/.bashrc" ;;
                    fish)
                        profile="$HOME/.config/fish/config.fish"
                        path_line='fish_add_path --append "$HOME/.local/bin"'
                        old_line='fish_add_path "$HOME/.local/bin"'
                        mkdir -p "$HOME/.config/fish"
                        ;;
                    *) profile="$HOME/.profile" ;;
                esac
                if ! grep -F -e "$path_line" -e "$old_line" "$profile" >/dev/null 2>&1; then
                    printf '\n# Gitby CLI + TUI\n%s\n' "$path_line" >> "$profile"
                fi
                path_changed=yes
            fi
            ;;
    esac

    say "Installed Gitby to $install_dir/gitby"
    if [ "$path_changed" = yes ]; then
        say "Added $install_dir to PATH in $profile. Open a new terminal, then run: gitby"
    elif [ "${PATH:-}" != "" ]; then
        case ":$PATH:" in
            *:"$install_dir":*) say "Run: gitby" ;;
            *) say "Add $install_dir to PATH, or run: $install_dir/gitby" ;;
        esac
    else
        say "Run: $install_dir/gitby"
    fi
}

main "$@"
