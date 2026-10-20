---
title: See what your AI's subagents are doing
date: 2026-10-20T14:37:53Z
version: 0.2.13
summary: The AI page shows Claude Code's subagents at work, agents keep listening between turns, and nothing gitby opens draws over its screen any more.
---

## New

- The AI page's mode line counts the subagents and shells running in the background. Press ↓ on the newest prompt, type `/tasks`, or click the count to open the task manager: what each subagent was asked, the tools it called and whether they worked, what it last said and what it handed back. Claude Code only.
- Claude Code and Codex read your clone's `AGENTS.md` and `CLAUDE.md` through gitby, cleaned first: hidden characters and HTML comments are removed, and each file and the whole set are capped in size.
- `/import` lists this clone's Claude Code and Codex conversations on this machine and carries one on inside gitby.
- Near 80% of the context, gitby has the assistant save what matters to its memory, then compacts the conversation. `/compact` does it now, `/autocompact off` turns the automatic one off, and the header shows how full the context is.
- Agents connected through `gitby mcp` keep listening after their turn ends, so a teammate's agent asking in a plan wakes yours. `gitby mcp install claude-code` sets this up.
- Agents can take back notes they wrote themselves.
- Subagents your AI starts are told gitby's rules: the files a subagent will change are claimed first, its prompt says which those are, and two subagents running at once never get the same file.

## Improved

- An agent in a plan that is not agreed yet cannot claim, commit or push, so nobody builds before the split is settled. Under full access, the files an agreed plan gives your agent are granted at once.

## Fixed

- Opening a file with the system default app, or an editor gitby does not know, could draw that program over gitby's screen. Terminal apps now open in gitby's editor window, and desktop apps run apart from gitby.
- The warning that a claimed file was deleted without a confirmed rename no longer appears for teammates' new files you have not pulled yet, and it shows once instead of over and over.
- Releasing a folder now also releases what your agents claimed in it.
- After an agent pushed through gitby, it could not release the files it had just pushed until gitby next fetched, and its next push still asked it to claim them again. A push through gitby now reads as pushed at once.
- An agent's `commit` without a list of files took every changed file in the clone, so one change of yours or another agent's refused the whole commit. It now takes only the changed files the agent holds and new files Git does not track yet.

## Security

- On Windows, gitby now unpacks its downloads with zip 9.0.5, for advisories RUSTSEC-2026-0367, -0368 and -0369. The way gitby used the older version was not affected.
