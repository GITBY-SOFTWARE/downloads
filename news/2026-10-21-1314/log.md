---
title: Agents give back what they are done with
date: 2026-10-21T13:14:00Z
version: 0.2.16
summary: Agents release files once their push lands, keep off files someone else holds, wake when you mention them, and ask their questions on a card in the AI chat. AI permissions are now set per mode.
---

## New

- Settings > AI permissions is a grid: each kind of action (read, edit, run, destructive commands, web, Gitby changes, the Gitby browser, other MCP servers, everything else) against the four modes, each allowed, asked or denied. The defaults keep what each mode did before, except that full access now asks before a destructive command and plan mode refuses one.
- Gitby reads the assistant's shell commands before they run and flags destructive ones, such as deleting outside the clone, wiping a disk, `sudo`, `git reset --hard`, `git clean`, a force push or piping a download into a shell. A flagged ask says why in red and can be allowed once at most.
- Agents keep off files someone else holds: an edit, or a shell command that writes, moves, deletes or changes the permissions of such a file, is refused before it runs. This covers the AI chat (Claude Code, Codex and ACP agents) and, for Claude Code you run yourself, a new hook, `gitby mcp guard`. Run `gitby mcp install` again to add the hook.
- Agents have a `revert` tool: it puts their local change to a file back to the last commit and keeps the change in a git stash. It asks you first (a destructive action in Settings > AI permissions).
- When Claude Code asks you a question in the AI chat, you answer on a card where the composer is: pick a choice, write your own answer, add a note, or chat about it first.
- Mention an agent in the team chat, or in a plan it is not part of, and it hears it and wakes up to answer. The AI chat's own assistant also wakes for mentions and for asks on its files.
- Type `/mcp` in the AI chat to see the assistant's MCP servers, with each one's state, tools or error. With Claude Code, Enter reconnects a server that failed, or turns one on or off (Gitby's own stays on). Codex shows the list only.

## Improved

- You can answer an ask for a file your own agent holds. The accept and deny buttons in Activity can be clicked, and show only where you may answer. Answering an ask for your agent's file needs the realtime server from this release.
- In every mode, the AI chat's assistant now asks Gitby before each edit and command, so your AI permissions decide them.
- Agents can list just the threads you are part of.

## Fixed

- Agents kept their files after committing and pushing, even once they were done with them. Now, when an agent's push lands, every file it holds with nothing left to commit or push goes back, with a short summary left as a note on the files it pushed. Files it says it still needs, and its unfinished part of an agreed plan, stay with it. An agent that has done nothing for ten minutes while holding such files is told once to give them back.
- Under full access, a finished part of someone else's agreed plan held back later asks for its files, so a claim from another of your agents waited for review.
- An agent asking for files could be told "no request was created" when the request had been made.
