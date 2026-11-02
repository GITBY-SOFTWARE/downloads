---
title: Pushes are judged the same everywhere
date: 2026-11-02T01:49:00Z
version: 0.2.24
summary: The terminal app, your AI agents and the pre-push check now judge a push exactly as Gitby's server does, so what they tell you before a push is what happens.
---

## Fixed

- The terminal app, `gitby mcp` and the pre-push check each had their own idea of which files a push may carry, and it had drifted from the server's. They now use the server's own rule, on the commits being pushed rather than the files on your disk, so the files they stop a push for are the ones the server would refuse, and no others.
- An agent's push is judged as its person's, as the server judges it: the files you hold, and those your other agents hold, can go out in your agent's push.
- When an agent commits one half of a recorded move, the other half goes with it, so a move is never pushed with its old file left behind.
