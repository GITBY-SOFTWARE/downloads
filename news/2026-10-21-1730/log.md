---
title: Four AI windows, tables, pictures and a real terminal in the AI chat
date: 2026-10-21T17:30:00Z
version: 0.2.17
summary: The AI page opens up to four windows with agents of their own, draws tables and charts, shows pictures, runs commands that need a password in a terminal where you type, and shows each turn's usage and the assistant's to-do list.
---

## New

- The AI page has up to four windows, AI 1 to AI 4, each with its own assistant, conversation and agents (`gitby-agent`, `gitby-agent-2`, and so on). Open one with ctrl+n or `/window new`, switch with ctrl+pageup and ctrl+pagedown, the tabs on the header or `/window 2`, and close one with `/window close`. A window keeps working while another is shown, and two windows never get the same file.
- AI replies draw tables as a grid, and a numeric table gets a bar chart under it. Click a column's name to chart that column, or click the table to copy it. Settings > Appearance > Charts under tables turns the charts off.
- Pictures show in the AI chat: the ones you paste, and the ones a tool gives back, such as a screenshot. Click one to open it in your picture viewer. Only PNG pictures are drawn in this release; other kinds show a line instead.
- A `!command` in the AI chat runs in a real terminal where the composer is, so you can answer a password prompt (sudo, ssh, git) right there. ctrl+] stops it. On Windows it still runs without a terminal.
- Agents can run a command that needs a terminal or a password through Gitby's new `terminal` tool. It opens in the same place, under the agent's name, after your AI permissions allow it, and you type into it. The agent only sees what the terminal shows, never what you typed. This works for the AI chat's assistant on Linux and macOS.
- A dim line under each AI turn shows what it used, as the assistant reported it: tokens in and out, the cost when Claude Code gives one, and how long it took. The header shows the conversation's total.
- The assistant's to-do list is pinned above the composer, for example `To do 2/5 · ▸ Writing the parser`. ctrl+y or a click shows the whole list. Works with Claude Code, Codex and ACP agents that send a plan.
- `/copy` picks what to copy from the AI conversation: a prompt, a reply, a tool call and its output, or a code block, table or link inside a reply. `/yank` still copies the newest code block at once.
- Agents have a `record_move` tool, so a file an agent moved keeps its claim, requests and notes.

## Improved

- ctrl+end jumps to the newest message in the AI chat and ctrl+home to the start, without touching what you are writing.
- On the Agents page, Delete removes the plan shown, after asking. An empty plan composer says which commands it takes.
- You can commit and push files your own agent holds.

## Fixed

- A push that deleted a file you held was refused whenever it also added any new file, as a possible rename. Now only a new file with the same name or in the same folder counts as a possible move, and the refusal says what to do. New files that are not a possible move show in the tree again. This needs the realtime server from this release.
