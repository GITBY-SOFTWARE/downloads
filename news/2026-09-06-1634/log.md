---
title: Close a finished terminal on Windows
date: 2026-09-06T16:34:35Z
version: 0.1.50
summary: On Windows, a terminal page notices when its shell exits, so you can close it.
---

## Fixed

- On Windows, a terminal page stayed "running" after its shell exited, so it could not be closed. It now shows that the shell exited, and `x` closes it.
