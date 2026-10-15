---
title: The browser asks before it runs without the sandbox
date: 2026-10-14T16:59:10Z
version: 0.2.9
summary: Where Chromium's sandbox is missing, the Browser page now asks for your go-ahead instead of telling you to set a variable.
---

## Improved

- Where Chromium's sandbox is missing (Windows and macOS for now, and Linux without user namespaces), the Browser page explains what running without it means and asks for your go-ahead with one key, instead of telling you to set `GITBY_BROWSER_NO_SANDBOX=1`. gitby remembers your answer, and Settings › Browser takes it back. Only a key on your own screen gives it: an AI assistant starting the browser never can.
