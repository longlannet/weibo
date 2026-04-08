---
name: weibo
description: 微博热搜、内容搜索、用户搜索、用户动态与评论读取。Use when the task involves Weibo / 微博 public content such as checking hot search topics, searching posts, searching users, reading user feeds, or inspecting public discussion.
metadata:
  {
    "openclaw":
      {
        "emoji": "🧭",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Weibo

Use this skill for public, read-only Weibo workflows.

## When to use
- 中文实时热点 / 热搜
- 公共事件舆情与广场讨论
- 按关键词搜索微博内容或话题
- 搜索微博用户并查看近期公开动态
- 查看某条微博下的公开评论

## Quick start
```bash
bash scripts/install.sh
cd weibo && mcporter list weibo --schema
cd weibo && mcporter call weibo.get_trendings limit:3
```

## Flow
1. Trend / topic: `get_trendings` → `search_content` / `search_topics`
2. Person / account: `search_users` → `get_profile` → `get_feeds` / `get_hot_feeds`
3. Comment: `search_content` / `search_topics` → `get_comments`

## Notes
- Read-only only.
- Run commands from the skill root so the local config is used.
- Re-run `scripts/install.sh` if setup is missing or stale.
