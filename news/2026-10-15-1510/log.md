---
title: A gap around Rio's text, and the Windows installer owns the gitby command
date: 2026-10-15T15:10:16Z
version: 0.2.10
summary: gitby's Rio window leaves room around the text as kitty does, the Files title is shorter, and on Windows `gitby` now runs the copy you just installed.
---

## Improved

- gitby's Rio window (the terminal gitby opens on Windows) leaves a gap between its edge and the text, as kitty does, instead of drawing right against it. A Rio config you changed yourself is left as it is.
- The Files panel's title shows only its file and claim counts. The branch and team it also showed read like more tabs, and the header already names them.

## Fixed

- On Windows, the installer puts gitby's folder first on your PATH, so `gitby` and `gitby update` run the copy it just installed rather than an older one found earlier. When something else still answers to `gitby` (a PowerShell alias or function, another copy, or a copy on the system PATH), the installer names it and the command that removes it; it removes nothing itself. It ends by running the installed gitby and saying whether it answered.
