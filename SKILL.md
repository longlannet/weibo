---
name: weibo
description: 微博热搜、内容搜索、用户搜索、用户动态与评论读取。Use when the task involves Weibo / 微博 public content such as checking hot search topics, searching posts, searching users, reading user feeds, or inspecting public discussion. This skill is currently designed for read-only workflows through mcp-server-weibo via mcporter.
---

# Weibo

Use this skill for **read-only Weibo workflows**.

## When to use

Use this skill when the user wants:
- 中文实时热点 / 热搜
- 公共事件舆情与广场讨论
- 按关键词搜索微博内容或话题
- 搜索微博用户并查看近期公开动态
- 查看某条微博下的公开评论

Do **not** treat this as a posting tool.

Prefer other tools when:
- need broad semantic discovery across many sites → `exa-search`
- need lifestyle / product experience / 种草内容 → `xiaohongshu`
- need classic web/news search across the web → `google-search`
- need short-video parsing/download → video-oriented workflows instead

## Runtime layout

This skill expects:
- shared host dependency: `mcporter`
- skill-local Python env: `{baseDir}/.venv`
- skill-local server binary: `{baseDir}/.venv/bin/mcp-server-weibo`
- runtime mcporter config: `{baseDir}/config/mcporter.json`

Important:
- `.venv/` and `config/mcporter.json` are runtime artifacts, not core skill source files
- when testing manually, run commands from `{baseDir}` so the skill-local config is used
- if setup is missing or stale, run the install script again instead of debugging by guesswork

## Default workflow

### Trend / topic workflow
1. Run `bash {baseDir}/scripts/install.sh` if the environment is not ready.
2. Run `weibo.get_trendings(limit)` to identify relevant topics.
3. Run `weibo.search_content(keyword, limit, page)` for deeper posts.
4. If topic search is useful, run `weibo.search_topics(keyword, limit, page)`.
5. Summarize narrative, recurring claims, and visible sentiment.

### Person / account workflow
1. Run `bash {baseDir}/scripts/install.sh` if needed.
2. Run `weibo.search_users(keyword, limit, page)`.
3. Identify the correct UID.
4. Run `weibo.get_profile(uid)`.
5. Run `weibo.get_feeds(uid, limit)` or `weibo.get_hot_feeds(uid, limit)`.
6. If useful, inspect `weibo.get_followers(uid, limit, page)` or `weibo.get_fans(uid, limit, page)`.
7. Summarize posting patterns or recent content.

### Comment workflow
1. Find the relevant post via `weibo.search_content` or `weibo.search_topics`.
2. Read the relevant post/feed id.
3. Run `weibo.get_comments(feed_id, page)` when comment detail matters.
4. Summarize positions, recurring themes, and visible sentiment.

## Tool checklist

Expected tools from `mcporter list weibo --schema`:
- `weibo.get_trendings(limit?)`
- `weibo.search_content(keyword, limit?, page?)`
- `weibo.search_users(keyword, limit?, page?)`
- `weibo.search_topics(keyword, limit?, page?)`
- `weibo.get_profile(uid)`
- `weibo.get_feeds(uid, limit?)`
- `weibo.get_hot_feeds(uid, limit?)`
- `weibo.get_followers(uid, limit?, page?)`
- `weibo.get_fans(uid, limit?, page?)`
- `weibo.get_comments(feed_id, page?)`

## Failure handling

Use this order when something fails:
1. Check `python3` exists.
2. Run `bash {baseDir}/scripts/install.sh`.
3. Run `bash {baseDir}/scripts/check.sh`.
4. Run `cd {baseDir} && mcporter list weibo --schema`.
5. Run a smoke test like `cd {baseDir} && mcporter call weibo.get_trendings limit:3`.

Common failure meanings:
- `python3 not found` → host is missing Python.
- `mcporter not found` → shared `mcporter` is missing and auto-install failed.
- `server binary not found` → `{baseDir}/.venv` install did not finish correctly.
- `schema not visible` → registration/config problem; rerun install from `{baseDir}`.
- command works outside `{baseDir}` but not inside, or vice versa → wrong mcporter config context.

## Output notes

Responses may include:
- result arrays and user objects
- post ids and profile URLs
- creation time and engagement fields
- HTML-like text fragments

Summarize and clean output unless the user asks for raw payloads.

## Limitations

- upstream MCP schema may evolve; re-check with `mcporter list weibo --schema`
- response text may contain HTML-like fragments
- public search quality depends on upstream Weibo endpoints and current MCP server behavior
- do not assume write/post capabilities just because read/search tools exist
