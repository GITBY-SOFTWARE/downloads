---
title: gitby update, a status toast, and Windows fixes
date: 2026-09-05T19:24:28Z
version: 0.1.33
summary: Update from the command line, see status in a floating toast, and Windows now remembers your settings and shows its terminal.
---

## New

- `gitby update` (or `gitby upgrade`) installs the newest release and says what happened, without opening the app. `gitby help` lists the commands and `gitby version` prints the version.

## Improved

- Status messages such as "connected" and "pushed" float as a toast in the bottom-right corner, with a close button, instead of taking a whole row.
- The About screen says Gitby is made by LyraTech LLC, and sign-in messages say Gitby instead of a web address.
- Loading screens are shorter.

## Fixed

- On Windows, Gitby remembers your settings, your sign-in and your clones between launches. Before, every launch started as the first one.
- On Windows, the Terminal page shows the shell instead of staying blank.
- Settings and the notes and commit popups no longer leave traces of the screen behind them.
- An agent finds its folder when the path has a drive letter or spaces in it.
