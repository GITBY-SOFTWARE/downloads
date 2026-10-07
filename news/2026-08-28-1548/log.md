---
title: One loading card at startup
date: 2026-08-28T15:48:54Z
version: 0.1.9
summary: Starting Gitby over a real network shows one steady loading card instead of one that pops in again at every step.
---

## Improved

- Starting up shows a single loading card whose status line changes as it signs in and loads your teams and repositories, instead of a card that popped in again at every step.
- Opening a repository fetches its route, Git access and teammates at the same time, so the repository picker no longer pauses before connecting.
