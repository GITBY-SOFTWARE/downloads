---
title: No repaints at rest
date: 2026-09-06T15:57:56Z
version: 0.1.47
summary: The background Git checks no longer repaint the screen when nothing changed.
---

## Fixed

- Gitby's background Git checks repainted the whole screen on a timer even when nothing had changed, a regular flicker. They now repaint only on a real change.
