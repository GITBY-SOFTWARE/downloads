---
title: Pictures and ! commands in the AI chat
date: 2026-10-20T20:20:00Z
version: 0.2.14
summary: Paste pictures and run your own commands in the AI chat, Sync Repo is one merge that tells you what blocks it, and desktop notifications reach you when something waits on you.
---

## New

- The AI chat takes pictures: press ctrl+v or alt+v to paste one from the clipboard, or drop a picture file on the terminal. Each shows as `[Image #N]` in your message and goes to Claude Code, Codex, or an ACP agent that takes pictures. Up to 20 per message. Pasting from the clipboard was tested on Linux only so far.
- Type `!` and a command in the AI chat (for example `!git status`) to run it yourself in the clone. Its output shows in the chat, and your next message tells the assistant what it printed. A command stops after two minutes.
- When something waits on you while Gitby is not in front (an ask to answer, an agent's message or plan, the assistant asking to use a tool), your system's notifications say so. Settings > General > Desktop notifications turns them off. Not tested on Windows yet.
- Agents connected through `gitby mcp` can check how far behind upstream the clone is (`sync_status`) and bring it up to date (`sync`), so they never need `git pull`.

## Improved

- Sync Repo is now one merge with upstream behind a loading card, instead of one file at a time: nothing of yours is replaced, and a merge that would conflict is undone and its files named.
- When files block Sync Repo, a window lists each one and what taking upstream's version would cost you (nothing when your copy already matches). Go through them one by one, take upstream's version of all of them, or leave them for now.
- Under full access, a large folder ask from an agent is granted in a few batches instead of one file at a time.
- A claim now shows its holder at once, without the bee.

## Fixed

- After about an hour, Gitby could no longer fetch, so Sync said "already in sync" while a push was refused because upstream had changed. Gitby now renews its access, and Sync says so when it cannot reach upstream.
- Taking upstream's version of a file could leave it staged when the repository refused the commit, which then blocked every later sync. It no longer does.
- Full access for an agent switched off after every reconnect, such as a server restart or a dropped network. It now stays on until you leave the repository or restart Gitby.
- An agent waiting on an approval could miss it and wait several seconds more.

## Security

- Gitby's connections no longer trust the emSign ECC Root CA - G3 root or its distrusted intermediates, whose private keys are now public (advisories RUSTSEC-2026-0381, -0382 and -0383). Before, someone holding those keys and able to intercept your network could have posed as Gitby's servers or GitHub.
