#!/bin/sh

# Install the Gitby CLI + TUI without root access.
#
# Overrides:
#   GITBY_VERSION=0.1.42          install a specific release (default: latest)
#   GITBY_INSTALL_DIR=/some/path  install somewhere other than ~/.local/bin
#   GITBY_NO_MODIFY_PATH=1        do not update the user's shell profile
#   GITBY_DOWNLOAD_BASE=https://  use a custom release base (tests/mirrors)

set -eu
umask 077

repo="GITBY-SOFTWARE/downloads"
version=${GITBY_VERSION:-latest}

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
            https://*) curl --proto '=https' --tlsv1.2 -fL --retry 3 --connect-timeout 10 "$url" -o "$destination" ;;
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
    *) die "unsupported CPU architecture: ${arch_name:-unknown}; Gitby supports x64 and ARM64" ;;
esac

asset="gitby-${os}-${arch}.tar.gz"

if [ -n "${GITBY_DOWNLOAD_BASE:-}" ]; then
    base=${GITBY_DOWNLOAD_BASE%/}
elif [ "$version" = latest ]; then
    base="https://github.com/${repo}/releases/latest/download"
else
    case "$version" in v*) release_tag=$version ;; *) release_tag="v$version" ;; esac
    base="https://github.com/${repo}/releases/download/${release_tag}"
fi

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
trap cleanup 0 HUP INT TERM

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
tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" gitby
[ -f "$tmp_dir/gitby" ] && [ ! -L "$tmp_dir/gitby" ] || die "release archive did not contain a regular gitby binary"

mkdir -p "$install_dir"
staged="$install_dir/.gitby.new.$$"
cp "$tmp_dir/gitby" "$staged"
chmod 0755 "$staged"
mv -f "$staged" "$install_dir/gitby"

path_changed=no
case ":${PATH:-}:" in
    *:"$install_dir":*) ;;
    *)
        if [ -z "${GITBY_NO_MODIFY_PATH:-}" ] && [ "$install_dir" = "${HOME:-}/.local/bin" ]; then
            shell_name=${SHELL##*/}
            case "$shell_name" in
                zsh) profile="$HOME/.zshrc"; path_line='export PATH="$HOME/.local/bin:$PATH"' ;;
                bash) profile="$HOME/.bashrc"; path_line='export PATH="$HOME/.local/bin:$PATH"' ;;
                fish)
                    profile="$HOME/.config/fish/config.fish"
                    path_line='fish_add_path "$HOME/.local/bin"'
                    mkdir -p "$HOME/.config/fish"
                    ;;
                *) profile="$HOME/.profile"; path_line='export PATH="$HOME/.local/bin:$PATH"' ;;
            esac
            if ! grep -F "$path_line" "$profile" >/dev/null 2>&1; then
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
