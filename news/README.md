# Release notes

The website's **What's new** popup, its changelog on `/news` and the docs read
the release notes in this folder, newest first:

```text
news/
  introduction.md          the changelog's opening words
  2026-09-25-1733/         one folder per release: YYYY-MM-DD-HHmm, in UTC
    log.md
```

Each `log.md` starts with frontmatter, then one `##` heading per category:

```markdown
---
title: One line people read first
date: 2026-09-25T17:33:52Z
version: 0.2.4
summary: One sentence for the popup.
---

## New
- ...

## Improved
- ...

## Fixed
- ...

## Security
- ...
```

- `date` is the release's publish time in UTC (ISO 8601). It orders the entries
  and decides what is new to each person: the popup shows only entries newer
  than the last one that person was shown, so never move a date backwards, and
  give a correction a new folder rather than a later date on an old one.
- The folder name repeats the date (`YYYY-MM-DD-HHmm`) so the folders sort in
  order; when the two disagree, `date` wins.
- Categories are any `##` heading; New, Improved, Fixed and Security get their
  own marks on the site. Write for people using Gitby: what changed for them,
  never code.
- Only folders named like a release time are shown, so a draft can wait in a
  folder with any other name.
- The site picks up a push to `main` within ten minutes.
