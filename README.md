# Gitby downloads

This is the official public distribution repository for Gitby. It hosts the
compiled `gitby` CLI + TUI and the VS Code-compatible extension without exposing
the private engine source repository.

## Install

**macOS (Apple Silicon)**

```sh
curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.sh | sh
```

The installer detects the Mac's architecture, verifies the release checksum,
and installs `gitby` for the current user in `~/.local/bin` without requiring
administrator access. Open a new terminal after installation, then run `gitby`.

**Linux (x64)**

```sh
curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.sh | sh
```

**Windows PowerShell (x64)**

```powershell
irm https://github.com/GITBY-SOFTWARE/downloads/releases/latest/download/install.ps1 | iex
```

The installers verify the download's SHA-256 checksum and install for the
current user without requiring root. Linux releases are statically linked with
musl so the same binary works across modern glibc- and musl-based distributions.
You do not need to clone this repository.

Set `GITBY_INSTALL_DIR` to choose a different destination or `GITBY_VERSION` to
pin a release. The defaults are `~/.local/bin` on macOS/Linux and
`%LOCALAPPDATA%\Gitby\bin` on Windows.

## Channels

Gitby publishes two channels:

- **release** (default) — production binaries that talk to `https://gitby.cloud`.
  Resolved by the `latest` release; this is what the install lines above use.
- **development** — a single moving pre-release (tag `development`) built from
  every push to `main`. These binaries point at the Gitby **dev stack**, not
  `gitby.cloud`, and are meant for testing only. Opt in with `GITBY_CHANNEL`:

  ```sh
  curl -fsSL https://github.com/GITBY-SOFTWARE/downloads/releases/download/development/install.sh | GITBY_CHANNEL=development sh
  ```

  ```powershell
  $env:GITBY_CHANNEL='development'; irm https://github.com/GITBY-SOFTWARE/downloads/releases/download/development/install.ps1 | iex
  ```

  Note the installer is fetched from the `development` release itself, not
  `latest`: the `latest` installer is the production one (no `GITBY_CHANNEL`
  support), and there may be no production `latest` at all yet. `gitby update`
  and the default `latest` never pick up the development channel.

## Update

```sh
gitby update
```

`gitby update` (or `gitby upgrade`) installs the newest **release** over the
running binary on every platform. Running the release install line again does
the same. `gitby help` lists every command and `gitby --version` prints the
installed version.

## Release contents

Each **release** publishes:

- the `gitby` CLI + TUI for **Linux x64** (static musl), **macOS arm64**, and
  **Windows x64**;
- `gitby-vscode.vsix` for VS Code, Cursor, VSCodium, and Windsurf;
- versioned `install.sh` / `install.ps1`;
- `SHA256SUMS` for installer verification.

Additional targets (Linux arm64, macOS Intel, Windows arm64) are not built yet.
The privately operated `gitby-server` is not distributed from this public
repository.

Published versions appear on the [Releases](https://github.com/GITBY-SOFTWARE/downloads/releases)
page; the `development` pre-release is updated on every push to the engine's main.

## Publishing

The private `engine` repository builds the targets and publishes `public-dist`
here with a short-lived GitHub App token. Pushes to the engine's `main` publish
the **development** channel automatically; the **release** channel is cut
deliberately (a `v*` tag or a manual `workflow_dispatch` with `channel=release`).
The App must be installed only on this repository with **Contents: write**.
Configure its numeric App ID as the `DOWNLOADS_APP_ID` Actions variable and its
private key as the `DOWNLOADS_APP_PRIVATE_KEY` Actions secret in
`GITBY-SOFTWARE/engine`.
