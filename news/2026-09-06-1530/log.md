---
title: A Rendering setting
date: 2026-09-06T15:30:52Z
version: 0.1.43
summary: Choose smooth, reduced or compatibility rendering, for less flicker on terminals that need it.
---

## New

- Settings › Appearance › Rendering: **smooth** (motion, and each frame drawn at once), **reduced** (no decorative motion, and the screen redraws only when something changes) or **compatibility** (no motion and no synchronized output, for terminals that mishandle it).

## Fixed

- With reduced motion, a shell's output still shows right away.
