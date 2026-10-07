---
title: Responsive while a terminal is busy
date: 2026-09-04T15:57:04Z
version: 0.1.14
summary: Keys and panel switches stay quick while a shell prints a lot.
---

## Improved

- Keys and coordination updates are handled before redraws, and a busy terminal's output is drawn at most about 30 times a second, so switching panels no longer lags while a shell prints.
