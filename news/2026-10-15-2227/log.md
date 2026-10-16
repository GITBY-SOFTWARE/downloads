---
title: The browser starts on Ubuntu servers
date: 2026-10-15T22:27:37Z
version: 0.2.12
summary: On Ubuntu 23.10 and later, the in-terminal browser no longer crashes at start; it asks for your go-ahead to run without Chromium's sandbox, and a browser that fails to start now says why.
---

## Fixed

- On Ubuntu 23.10 and later, and other machines that let a normal user create namespaces but not set them up, the browser no longer crashes at start with "signal: 6 (SIGABRT)". gitby now checks for Chromium's sandbox the same way Chromium does, so it asks for your go-ahead to run pages without the sandbox, and starts once you give it. Where the sandbox works, pages still run in it.
- When the browser fails to start, the Browser page shows the reason Chromium gave instead of only the folder its logs are in.
