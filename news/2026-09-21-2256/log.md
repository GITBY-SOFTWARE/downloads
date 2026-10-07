---
title: The AI page, the in-terminal browser, agent plans and Git tools
date: 2026-09-21T22:56:39Z
version: 0.2.1
summary: Work with your AI assistant inside Gitby, browse in the terminal, let agents split work into plans, and use a commit graph, reflog, diff and worktrees.
---

## New

- An **AI** page: work with Claude Code, Codex or another ACP-compatible CLI inside Gitby, with an optional helper model that plans first. It keeps your prompt history, and **Shells** beside it lists the commands it ran and lets you stop them. **In validation.**
- A **Browser** page: a web browser in your terminal (Chromium in its own process, drawn with the kitty graphics protocol), with tabs, the mouse and keys, that your AI assistant can also use. Linux only in this release. **In validation.**
- **Agent plans**: AI agents, yours and your teammates', agree a plan for a feature on the new **Agents** page (`i`) before they claim files. You approve or decline it, hold an agent (`h`), and follow each part as it is claimed, pushed and released. **In validation.**
- Ask for a whole folder, or the whole repository, in one request. The holder answers all of it at once on Preview.
- Git tools as pages: a commit graph drawn with Git's own lanes, the reflog, your working changes as a diff (unified or side by side, Enter switches), and your worktrees.
- Revert a file you hold to its last commit with `u`. It asks first.
- Settle a sync conflict inside Gitby: for each conflicting part, keep yours, take theirs, keep both or drop a line. Nothing is written until every part is decided and you confirm.
- Select text in a terminal page with the mouse. It is copied when you let go.
- Relaxed claiming, a setting the repository's owner turns on: only other people's claims lock files, and editing a free file claims it for you. **In validation.**
- Settings › Agents installs or updates the gitby-planning skill for your agents.

## Improved

- Your agents follow the account you are signed in to: after you sign out or switch accounts, they stop acting as the old one.
- Adding a note keeps the notes in view, with the note box over them.
- Closing a terminal that is alone in a split closes the split instead of restarting the shell.
- The keys list (`?`) is grouped and fits narrower terminals, and the right-click menu no longer cuts off its keys.
- Linux builds are published again, as one static x64 binary, beside Windows (x64) and Apple silicon Macs.

## Fixed

- `gitby update` no longer fails on the development channel's release, and never offers a pre-release.
- Settings no longer flickers on Windows.
- Dragging a window border no longer lags.
- A holder can answer a takeover request without first selecting that exact file.
