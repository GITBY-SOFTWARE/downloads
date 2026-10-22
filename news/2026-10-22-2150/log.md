---
title: More AI coders, and AI windows that come back
date: 2026-10-22T21:50:00Z
version: 0.2.21
summary: The AI page starts 15 more coding CLIs, opens your AI windows again after a reconnect or an update, and gains /btw, /rename, /retry and prompt search.
---

## New

- The AI page can start 15 more coding CLIs, beside Claude Code, Codex, OpenCode, Cursor and Grok: oh-my-pi, Gemini CLI, GitHub Copilot, Qwen Code, Goose, Kimi, Mistral Vibe, Cline, Kilo, Auggie, Factory Droid, Devin, Qoder, CodeBuddy and MiniMax Code. Each uses the sign-in its own CLI saved, and gitby names the command that signs in one that is not. Gemini CLI, Qwen Code, Goose and Mistral Vibe are started in their mode that asks before acting. oh-my-pi does not ask before a plain edit, so a file someone else holds is kept from it by staying read-only on disk.
- `/btw <question>` asks about the conversation on the side. The answer shows above the composer until esc closes it, and nothing is added to the conversation: it comes from a copy the CLI never saves, with no tools. Claude Code and Codex only.
- `/rename <name>` names a conversation, and `/resume` lists it by that name. `/resume <words>` lists only the conversations that mention them; in the list, `p` pins one to the top and `d` pressed twice deletes one.
- An edit's change is drawn under it as a short diff, and the model's thinking folds to one line. `/thinking` shows it whole.
- `ctrl+r` finds an earlier prompt by the words you have typed, and `ctrl+g` writes the prompt in your own editor (`$VISUAL` or `$EDITOR`) where the composer is, on Linux and macOS.
- `/retry` asks a request that ended on an error again.
- The desktop notice now also tells you when an AI window finishes, stops on an error, asks you a question or asks for a terminal while you are in another window.
- `alt+1` to `alt+4` show an AI window, `alt+,` and `alt+.` step through them, and `alt+w` closes the one on screen.

## Fixed

- After a reconnect, a restart or an update, only the first AI window came back, holding the newest conversation. Gitby now keeps which windows each clone has open, and the conversation each holds, on this machine, and opens them again with their own agents. Windows open before this update cannot come back, since the older version did not keep them.
