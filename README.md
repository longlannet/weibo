# weibo skill

Read-only Weibo skill for OpenClaw.

This repository packages a small, practical workflow around `mcp-server-weibo` + `mcporter` so an OpenClaw agent can inspect public Weibo content without turning the skill itself into a giant pile of setup notes.

## What it does

This skill is meant for **public, read-only Weibo workflows**, including:

- hot search / trending topics
- public post search
- topic search
- user search
- reading public profiles and recent feeds
- reading comments for a specific post
- checking followers / fans when the upstream server exposes them

## What it does not do

- posting, replying, liking, or following
- account automation
- generic web search across the whole internet
- replacing a broader search tool like Exa or Google

## Why this repo exists

The goal is to keep the skill in a shape that is actually reusable:

- `SKILL.md` stays focused on **agent execution rules**
- `README.md` stays focused on **human-facing repo usage**
- runtime artifacts are kept out of source control
- install and validation are scripted instead of relying on vague manual steps

## Repository layout

```text
weibo/
├── .gitignore
├── README.md
├── SKILL.md
├── TODO.md
├── scripts/
│   ├── install.sh
│   └── check.sh
└── config/
    └── mcporter.json.example
```

Runtime-generated files are intentionally separate from source files:

```text
weibo/
├── .venv/
└── config/
    └── mcporter.json
```

## Dependency model

This skill uses a split dependency layout:

### Shared on host
- `mcporter`

### Local to this skill
- `mcp-server-weibo`
- `.venv/`
- `config/mcporter.json`

That means:
- `mcporter` is reused if already available on the host
- if missing, the install script attempts to install a shared copy
- the Weibo MCP server itself stays local to this skill

## Install

From the repository root:

```bash
bash scripts/install.sh
```

What the install script does:

1. creates `.venv`
2. installs `mcp-server-weibo`
3. resolves or installs shared `mcporter`
4. writes `config/mcporter.json`
5. registers the local `weibo` server
6. runs a small smoke test

## Validate

```bash
bash scripts/check.sh
```

Manual validation examples:

```bash
cd weibo
mcporter list weibo --schema
mcporter call weibo.get_trendings limit:3
```

> When testing manually, run `mcporter` from the skill root so the local config is used.

## Example commands

### Hot search

```bash
cd weibo
mcporter call weibo.get_trendings limit:5
```

### Search public posts

```bash
cd weibo
mcporter call weibo.search_content keyword:OpenAI limit:3
```

### Search users

```bash
cd weibo
mcporter call weibo.search_users keyword:OpenAI limit:3
```

### Search topics

```bash
cd weibo
mcporter call weibo.search_topics keyword:人工智能 limit:5
```

### Read a profile

```bash
cd weibo
mcporter call weibo.get_profile uid:1639339450
```

### Read recent feeds

```bash
cd weibo
mcporter call weibo.get_feeds uid:1639339450 limit:5
```

### Read hot feeds

```bash
cd weibo
mcporter call weibo.get_hot_feeds uid:1639339450 limit:5
```

### Read comments

```bash
cd weibo
mcporter call weibo.get_comments feed_id:5232787294279898 page:1
```

## Common issues

### `python3 not found`
The host is missing Python 3.

### `mcporter not found`
The host has no usable `mcporter`, and automatic shared install failed.
Check:
- whether `npm` is available
- whether the shared npm prefix is writable

### `server binary not found`
The local `.venv` install did not finish correctly.
Run:

```bash
bash scripts/install.sh
```

### `weibo` not visible in schema
Usually this means config context or registration is wrong.
Try:

```bash
cd weibo
bash scripts/install.sh
bash scripts/check.sh
```

## Current status

This repository has been cleaned up to support:

- reproducible reinstall
- scripted validation
- runtime/source separation
- a leaner `SKILL.md`

## Roadmap

See [TODO.md](./TODO.md) for the current `v0.1.1` plan.

## Notes for maintainers

- keep execution-critical rules in `SKILL.md`
- keep repository-facing explanation in `README.md`
- do not dump long testing logs or historical debugging transcripts into `SKILL.md`
- if docs grow, prefer moving long reference material into `references/`
