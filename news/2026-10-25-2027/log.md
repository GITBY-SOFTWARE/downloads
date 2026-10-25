---
title: Pushing in the background, and work that survives a reconnect
date: 2026-10-25T20:27:00Z
version: 0.2.22
summary: A push no longer freezes the terminal app, a reconnect keeps your AI windows, shells and drafts, coders can be given a name, and Gitby offers to ignore build output.
---

## New

- A reconnect keeps your work. When the connection drops (a server restart, a deploy, a network blip), every AI window carries on with its CLI, a turn in the middle of its work included, and so do your shells, the browser and every message you were writing. What the team holds still comes fresh from the server.
- `/name Jarvis` gives an AI window's coder a nickname. It joins the room under it (`@you/jarvis`), so Online, claims and chat show it, and Online lists each person's agents under them. The change waits while the coder is working, holds files or is in a plan.
- Gitby notices build output Git is not ignoring (`node_modules/`, `target/`, `__pycache__/`, `.next/`, `*.pyc` and the like) and says so once. `I` shows the exact lines and the `.gitignore` they would go in, and `G` or the Files tree's right-click menu adds any file or folder. Nothing is written until you confirm, and a tracked `.gitignore` is claimed first.
- In VS Code, a file claimed by someone who is offline shows a dimmed lock. The claim still stands until they release it, and a request waits until they are back.

## Improved

- Pushing runs in the background. The screen, your keys and the team's updates stay live while a push goes through, and its notice stays up until it ends.

## Fixed

- A push that deleted many files beside many new ones of the same name (several `index.ts` or `model.ts`) could be refused with "these deleted files look moved" for files that were never moved. Gitby now compares every such pair, reading each file once.
