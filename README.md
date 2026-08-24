# Gitby downloads

This is the official public distribution repository for Gitby. It will host the
compiled `gitby` terminal client and the VS Code-compatible extension without
exposing the private engine source repository.

> Release publishing is currently being wired. Until the first release appears,
> there is no public installation package in this repository.

## Install

Once the first public release is available, use the branded installer for your
platform:

**macOS and Linux**

```sh
curl -fsSL https://gitby.sh/install | sh
```

**Windows PowerShell**

```powershell
irm https://gitby.sh/install.ps1 | iex
```

The installer will select the correct platform build and verify it before
installation. You do not need to clone this repository.

## Release contents

Each release is intended to include:

- the `gitby` TUI for supported Linux, macOS, and Windows targets;
- `gitby-vscode.vsix` for VS Code, Cursor, VSCodium, and Windsurf;
- SHA-256 checksums and release signatures.

The privately operated `gitby-server` is not distributed from this public
repository.

Published versions will appear on the [Releases](https://github.com/GITBY-SOFTWARE/downloads/releases)
page. Product information is available at [gitby.cloud](https://gitby.cloud).
