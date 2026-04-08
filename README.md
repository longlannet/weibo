# weibo

面向 OpenClaw 的微博搜索与阅读 skill。

## 它能做什么

- 搜索热搜、微博内容与话题
- 搜索用户并查看公开主页 / 动态
- 读取公开微博评论
- 保持只读，不做发帖、点赞、关注等写操作

## 安装

```bash
bash scripts/install.sh
```

## 校验

```bash
bash scripts/check.sh
```

## 常用命令

```bash
cd weibo
mcporter list weibo --schema
mcporter call weibo.get_trendings limit:3
mcporter call weibo.search_content keyword:OpenAI limit:3
```

## 说明

- 请在 skill 根目录运行 `mcporter`，确保本地配置生效。
- 如果环境缺失或状态异常，重新运行 `scripts/install.sh`。
- 这个 skill 当前保持只读。
