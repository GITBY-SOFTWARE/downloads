# Gitby downloads

This is the official public distribution repository for Gitby. It hosts the
compiled `gitby` CLI + TUI and the VS Code-compatible extension without exposing
the private engine source repository.

## Install

**macOS (Apple Silicon or Intel)**

```sh
curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.sh | sh
```

The installer detects the Mac's architecture, verifies the release checksum,
and installs `gitby` for the current user in `~/.local/bin` without requiring
administrator access. Open a new terminal after installation, then run `gitby`.

**Linux**

```sh
curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.sh | sh
```

**Windows PowerShell**

```powershell
irm https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.ps1 | iex
```

The installers detect x64 or ARM64, select the correct build, verify its SHA-256
checksum, and install for the current user without requiring root. Linux releases
are statically linked with musl so the same binary works across modern glibc- and
musl-based distributions. You do not need to clone this repository.

Set `GITBY_INSTALL_DIR` to choose a different destination or `GITBY_VERSION` to
pin a release. The defaults are `~/.local/bin` on macOS/Linux and
`%LOCALAPPDATA%\Gitby\bin` on Windows.

## Update

```sh
gitby update
```

`gitby update` (or `gitby upgrade`) installs the newest release over the
running binary on every platform. Running the install line again does the
same. `gitby help` lists every command and `gitby --version` prints the
installed version.

## Release contents

Each release is intended to include:

- the `gitby` CLI + TUI for x64 and ARM64 Linux, macOS, and Windows;
- `gitby-vscode.vsix` for VS Code, Cursor, VSCodium, and Windsurf;
- `SHA256SUMS` for installer verification.

The privately operated `gitby-server` is not distributed from this public
repository.

Published versions will appear on the [Releases](https://github.com/GITBY-SOFTWARE/downloads/releases)
page.

## Publishing

The private `engine` repository builds every platform and publishes `public-dist`
here with a short-lived GitHub App token. The App must be installed only on this
repository with **Contents: write**. Configure its numeric App ID as the
`DOWNLOADS_APP_ID` Actions variable and its private key as the
`DOWNLOADS_APP_PRIVATE_KEY` Actions secret in `GITBY-SOFTWARE/engine`.
