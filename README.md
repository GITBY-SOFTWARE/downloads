# Gitby downloads

This is the official public distribution repository for Gitby. It hosts the
compiled `gitby` CLI + TUI and the VS Code-compatible extension without exposing
the private engine source repository.

## Install

**macOS (Apple Silicon)**

```sh
curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.sh | sh
```

The installer verifies the release checksum and installs `gitby` for the
current user in `~/.local/bin` without requiring administrator access. Open a
new terminal after installation, then run `gitby`. Only Apple Silicon Macs have
a build: on an Intel Mac the installer stops with a message saying so.

**Linux (x64)**

```sh
curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.sh | sh
```

**Windows PowerShell (x64)**

```powershell
irm https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.ps1 | iex
```

Windows 11 on ARM installs the x64 build, which it runs under emulation; there
is no native ARM64 build yet.

The installers install for the current user without requiring root, add the
install folder to the end of your `PATH` (never ahead of the system folders),
and check the download's SHA-256 against the `SHA256SUMS` file published in the
same release. That check catches a truncated or corrupted download. It is not a
signature: whoever can publish a release can publish both files, so it does not
prove who built the binary. Signed releases are planned. Linux releases are
statically linked with musl so the same binary works across modern glibc- and
musl-based distributions. You do not need to clone this repository.

Set `GITBY_INSTALL_DIR` to choose a different destination or `GITBY_VERSION` to
pin a release. The defaults are `~/.local/bin` on macOS/Linux and
`%LOCALAPPDATA%\Gitby\bin` on Windows.

## Channels

Gitby publishes two channels:

- **release** (default): production binaries that talk to the production
  service (`gitby.cloud`).
  Resolved by the `latest` release; this is what the install lines above use.
- **development**: a single moving pre-release (tag `development`) built from
  every push to `main`. These binaries point at the Gitby **dev stack**, not
  `gitby.cloud`, and are meant for testing only. The dev stack runs with
  development settings rather than production's sealed configuration and can
  be reset at any time, so do not connect private repositories or an account
  you use in production to it. Opt in with `GITBY_CHANNEL`:

  ```sh
  curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/download/development/install.sh | GITBY_CHANNEL=development sh
  ```

  ```powershell
  $env:GITBY_CHANNEL='development'; irm https://github.com/GITBY-SOFTWARE/downloads/releases/download/development/install.ps1 | iex
  ```

  Note the installer is fetched from the `development` release itself, not
  `latest`: there may be no production `latest` at all yet, and an older
  `latest` installer may not know `GITBY_CHANNEL`. `gitby update` and the
  default `latest` never pick up the development channel.

## Update

```sh
gitby update
```

`gitby update` (or `gitby upgrade`) installs the newest **release** that
ships your platform's archive over the running binary, on every platform.
Before replacing anything it checks the archive against the release's
`SHA256SUMS` and checks that the new binary reports the version it was
offered, and it replaces the `gitby-browser` sidecar beside `gitby` with it. A
development build updates only to newer development builds. Running the
release install line again also updates. `gitby help` lists every command and
`gitby --version` prints the installed version.

## Release contents

Each **release** publishes:

- the `gitby` CLI + TUI for **Linux x64** (static musl), **macOS arm64**, and
  **Windows x64**, each archive carrying the `gitby-browser` sidecar where the
  platform has one, plus the raw `gitby-browser-*` sidecars `gitby` downloads
  when its own copy is missing;
- `gitby-vscode.vsix` for VS Code, Cursor, VSCodium, and Windsurf;
- versioned `install.sh` / `install.ps1`;
- `SHA256SUMS`, which the installers and `gitby update` check every download
  against (integrity only, see above).

Additional targets (Linux arm64, macOS Intel, Windows arm64) are not built yet.
The privately operated `gitby-server` is not distributed from this public
repository.

Published versions appear on the [Releases](https://github.com/GITBY-SOFTWARE/downloads/releases)
page; the `development` pre-release is updated on every push to the engine's main.

## Publishing

The private `engine` repository builds the targets and publishes `public-dist`
here with a short-lived GitHub App token. Pushes to the engine's `main` publish
the **development** channel automatically; the **release** channel is cut
deliberately by pushing a `vX.Y.Z` tag. A manual `workflow_dispatch` release
must be started from that tag ("Use workflow from" the tag) with
`channel=release`; a run started from a branch with `channel=release` is
refused. The version always comes from the tag, which must be plain semver (no
pre-release suffix), sit on the default branch's history, and not be older than
the latest release (the same version again re-runs that release). Every platform, macOS included, is rebuilt from the tagged
commit: `skip_macos` is refused on the release channel and a `[skip macos]`
commit subject is ignored there. The App must be installed only on
this repository with **Contents: write**. Configure its numeric App ID as the
`DOWNLOADS_APP_ID` Actions variable, and its private key as the
`DOWNLOADS_APP_PRIVATE_KEY` secret of the engine's `production-release` and
`development-release` environments (not as a repository secret), so a run on
an arbitrary branch cannot read it. See the header of the engine's
`.github/workflows/release.yml` for the environment rules.
