---
title: The in-terminal browser comes to Windows and the Mac
date: 2026-09-25T08:26:43Z
version: 0.2.3
summary: The Browser page runs on Windows, on Apple silicon Macs and over SSH, with smoother frames and clearer setup errors.
---

## New

- The Browser page runs on Windows (in WezTerm or Gitby's own Rio terminal) and on Apple silicon Macs, as well as on Linux. **In validation.**
- The Browser page works over SSH to a Linux server: frames are sent through the terminal connection. **In validation.**
- Settings › Browser sets the browser's frame rate and render scale.

## Improved

- When the browser cannot start, Gitby names every missing system library and the command that installs them.
- A development-channel build updates only to a newer development build.
- In the AI page, a bare "plan about <file>" makes the assistant ask what you mean instead of guessing.

## Fixed

- The terminal app no longer freezes on Windows terminals that do not answer the image-protocol query, and draws images correctly in WezTerm.
- On Windows, the browser no longer flickers or drops frames on partial redraws, and its Chromium runtime loads from its own folder.
- On a Mac, the browser shows the right cursor.

## Security

- A server address given as a bare public host now defaults to an encrypted `wss://` connection.
- Fixes from a production security audit across the realtime server, the shared core and the terminal app.
