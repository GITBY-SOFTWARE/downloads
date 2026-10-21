---
title: Gitby's servers stop refusing a deletion beside an unrelated new file
date: 2026-10-21T20:38:00Z
version: 0.2.19
summary: A push that deletes a file you hold next to an unrelated new file with the same name or in the same folder is no longer refused by Gitby's servers as a possible move.
---

## Fixed

- Gitby's servers still refused a push that deleted a file you hold beside a new file with the same name or in the same folder, even when the new file had other content. They could not read the files to compare them, and a pair they could not compare counted as a possible move. They now fetch the contents they need from GitHub, so only a new file with mostly the same content as the deleted one counts as a possible move, as Gitby's terminal app already judged.
