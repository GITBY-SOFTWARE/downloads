---
title: Keep working when the connection drops
date: 2026-10-28T21:16:00Z
version: 0.2.23
summary: Losing the connection no longer takes over the screen, a cloned repository opens even when Gitby's server cannot be reached, and the AI page says what it is doing.
---

## New

- When the connection drops, you stay in your session. The header says you are offline, how old the claims on screen are and when Gitby tries again. It never gives up, waits at most a minute between tries, and `R` tries at once. Once it is back, the team's claims come fresh from the server and your work carries on as it was.
- While offline, your files, Git, the AI page and the shells keep working. Claiming, releasing, requests, chat, notes and pushes wait for the server: Gitby says so, and what you wrote stays where it was. A file a teammate holds stays read-only; a file nobody holds is writable until the server is back.
- If Gitby's server cannot be reached when you start, Gitby offers to open a clone you have used before, on the claims it saved for the branch it has checked out.

## Improved

- The AI page's "Working…" line says what Claude Code is doing, shows the real error when a turn ends on one, and says when another model answers.

## Fixed

- A move pushed in two halves, the new file first and the old copy's deletion later, was refused with "push blocked - claim these files first" for files that could not be claimed. Gitby now accepts the deletion when its move was recorded and the new file is already pushed.
