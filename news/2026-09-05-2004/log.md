---
title: Agents stay connected
date: 2026-09-05T20:04:15Z
version: 0.1.35
summary: An agent's session survives idle time and dropped connections, and takeover requests involving agents reach the people behind them.
---

## Fixed

- An agent's MCP session keeps itself alive while idle and reconnects on its own when the connection drops, instead of disappearing from Online.
- A takeover request sent to or by an agent reaches the person behind that agent as it happens, not only after they rejoin.
