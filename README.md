# weibo

Weibo search and reading.

## What it does

- search hot topics, posts, and topics
- search users and inspect public profiles / feeds
- read comments on public posts
- stay read-only; no posting, liking, or following

## Install

```bash
bash scripts/install.sh
```

## Validate

```bash
bash scripts/check.sh
```

## Quick commands

```bash
cd weibo
mcporter list weibo --schema
mcporter call weibo.get_trendings limit:3
mcporter call weibo.search_content keyword:OpenAI limit:3
```

## Notes

- Run `mcporter` from the skill root so the local config is used.
- Re-run `scripts/install.sh` if setup is missing or stale.
- This skill is read-only.
