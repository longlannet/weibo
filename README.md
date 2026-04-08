# weibo skill

一个面向 OpenClaw 的**微博只读 skill**，通过 `mcp-server-weibo` + `mcporter` 提供微博公开内容读取能力。

适合做：
- 热搜 / 热点话题查看
- 微博内容搜索
- 微博用户搜索
- 用户主页动态读取
- 评论读取
- 粉丝 / 关注列表查看（取决于上游能力）

不适合：
- 发微博 / 回帖 / 点赞 / 关注等写入操作
- 当作通用网页搜索引擎

---

## 仓库结构

```text
weibo/
├── .gitignore
├── README.md
├── SKILL.md
├── scripts/
│   ├── install.sh
│   └── check.sh
└── config/
    └── mcporter.json.example
```

运行后会额外生成：

```text
weibo/
├── .venv/                  # skill 私有 Python 环境（运行时生成）
└── config/
    └── mcporter.json       # skill 本地 mcporter 配置（运行时生成）
```

说明：
- `.venv/` 是安装产物，不应作为 skill 源码的一部分提交。
- `config/mcporter.json` 是本机运行配置，不应当作通用模板提交。
- 仓库中保留 `config/mcporter.json.example` 作为结构示例。

---

## 依赖分层

当前采用“**宿主共享 + skill 私有**”的设计：

### 宿主共享
- `mcporter`

### skill 私有
- `mcp-server-weibo`
- `weibo/.venv`
- `weibo/config/mcporter.json`

这意味着：
- 优先复用宿主已有 `mcporter`
- 如果宿主缺少 `mcporter`，安装脚本会尝试安装一份共享副本
- `mcp-server-weibo` 固定安装在 skill 自己目录下

---

## 安装

在 skill 根目录下执行：

```bash
bash scripts/install.sh
```

安装脚本会自动完成：
1. 创建 `weibo/.venv`
2. 安装 `mcp-server-weibo`
3. 解析或安装共享 `mcporter`
4. 生成 `weibo/config/mcporter.json`
5. 注册 `weibo` 到 mcporter
6. 做一次最小 smoke test

---

## 校验

```bash
bash scripts/check.sh
```

也可以手动验证：

```bash
cd weibo
mcporter list weibo --schema
mcporter call weibo.get_trendings limit:3
```

> 手动测试时，建议从 skill 根目录执行 `mcporter`，这样会优先使用本 skill 的本地配置。

---

## 常用调用示例

### 查看热搜

```bash
cd weibo
mcporter call weibo.get_trendings limit:5
```

### 搜索微博内容

```bash
cd weibo
mcporter call weibo.search_content keyword:OpenAI limit:3
```

### 搜索微博用户

```bash
cd weibo
mcporter call weibo.search_users keyword:OpenAI limit:3
```

### 搜索话题

```bash
cd weibo
mcporter call weibo.search_topics keyword:人工智能 limit:5
```

### 读取用户资料

```bash
cd weibo
mcporter call weibo.get_profile uid:1639339450
```

### 读取用户动态

```bash
cd weibo
mcporter call weibo.get_feeds uid:1639339450 limit:5
```

### 读取热门动态

```bash
cd weibo
mcporter call weibo.get_hot_feeds uid:1639339450 limit:5
```

### 读取评论

```bash
cd weibo
mcporter call weibo.get_comments feed_id:5232787294279898 page:1
```

---

## 常见问题

### 1）提示 `python3 not found`
宿主机缺少 Python 3，需要先安装。

### 2）提示 `mcporter not found`
宿主机没有可用的 `mcporter`，且自动安装失败。
请检查：
- `npm` 是否可用
- 是否有权限写入共享 npm 前缀

### 3）提示 `server binary not found`
说明 `weibo/.venv` 安装没完成，重新运行：

```bash
bash scripts/install.sh
```

### 4）schema 看不到 `weibo`
通常是配置上下文不对，或者注册没成功。建议：

```bash
cd weibo
bash scripts/install.sh
bash scripts/check.sh
```

---

## 给维护者的建议

- agent 执行规则、工作流、失败处理以 `SKILL.md` 为准
- `README.md` 主要面向人类读者与仓库维护
- 尽量不要把测试日志、历史决策、临时排障过程塞进 `SKILL.md`
- 如果后续文档继续增长，优先把长说明拆到 `references/`，而不是让 `SKILL.md` 膨胀
