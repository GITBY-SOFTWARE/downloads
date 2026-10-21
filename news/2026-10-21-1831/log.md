---
title: A deleted file beside an unrelated new one commits again (Linux only)
date: 2026-10-21T18:31:00Z
version: 0.2.18
summary: Linux only. A held file deleted next to a new file with the same name, such as two index.ts files in different folders, no longer blocks the commit and push as a possible move. Windows and macOS stay on 0.2.17.
---

## Fixed

- This release is for Linux only. Windows and macOS have no new files in it, so they stay on 0.2.17, and the install scripts keep installing 0.2.17 everywhere. On Linux, `gitby update` takes you to 0.2.18.
- Deleting a file you hold while adding a new file with the same name or in the same folder was always treated as a possible move Gitby had not seen, so both files were held back. Two unrelated `index.ts` files in different folders blocked each other. Now it only counts as a possible move when the new file has mostly the same content as the deleted one, the same test Git uses for renames. Gitby's servers check pushes the same way once they run this release.
- When a commit or push is held back because a file may have moved, the message now says that and what to do, instead of "claim these first" about files you already hold.
