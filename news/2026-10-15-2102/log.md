---
title: The browser unpacks on servers without bzip2, and man gitby
date: 2026-10-15T21:02:55Z
version: 0.2.11
summary: The in-terminal browser's Chromium runtime now unpacks on any Linux machine, and gitby comes with a manual page.
---

## New

- `man gitby`: on Linux and macOS, gitby puts its manual page beside itself when the terminal app starts, covering every command, the environment variables gitby reads, and where it keeps its files.

## Fixed

- On Linux, the browser's Chromium runtime no longer needs a `bzip2` program to unpack, so the browser no longer stops at "unpacking the Chromium runtime failed (exit status: 2)" on servers that lack one. gitby now unpacks it itself, in half the time, and names a real problem such as a full disk instead of a bare exit status.
