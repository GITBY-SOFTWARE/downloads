---
title: Icons for everyone, and gitby's Rio on Windows
date: 2026-10-14T15:52:10Z
version: 0.2.8
summary: gitby installs its icon font for you, shows icons wherever your terminal can draw them, and can install its Rio terminal on Windows.
---

## New

- gitby installs its icon font for you on Linux, macOS and Windows: no admin rights, and your own text font stays as it is. File icons are on wherever your terminal can draw them, and setup asks in every terminal, with a preview in your terminal's own font. If icons show as boxes right after the update, restart the terminal once, or turn them off in Settings › Appearance.

## Fixed

- On Windows, gitby can install its Rio terminal, where the in-terminal browser runs. Earlier releases carried no checksum for it, so gitby refused to download it.
- gitby's Rio draws the icons too.

## Security

- The TLS library gitby uses is updated to rustls 0.23.46, which fixes RUSTSEC-2026-0346 to 0349.
