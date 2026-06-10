# AI Skills — 团队共享技能库

AI 编码助手（Claude Code、Cursor、Codex 等）的团队共享技能库，git 统一维护，唯一真相源。

## 目录结构

```
skills/
├── frontend/        # 🎨 前端开发 — 组件、样式、状态管理、性能
├── design/          # 🖌️ 设计系统 — UI/UX、配色、字体、动效、布局
├── engineering/     # ⚙️ 工程质量 — TDD、调试、部署、代码审查
├── workflow/        # 🔄 开发流程 — 头脑风暴→计划→实现→分支收尾
└── meta/            # 🧠 AI 协作技巧 — skill 编写、代理调度、工具使用
```

## 使用方式

### 首次使用

```bash
# 克隆到项目
git clone <repo-url> .agents/skills

# 一键链接到你的 AI 工具
bash .agents/skills/link-skills.sh   # 自动检测可用工具并创建 symlink
# 或指定工具：
bash .agents/skills/link-skills.sh claude
bash .agents/skills/link-skills.sh cursor
bash .agents/skills/link-skills.sh codex
```

### 更新

```bash
cd .agents/skills && git pull
```

## 贡献指南

1. 新 skill 放到对应分类目录下
2. 每个 skill 一个独立文件夹，含 `SKILL.md`
3. 提交前确认 skill 可正常加载
4. git commit 描述清楚用途

## 分类标准

| 模块 | 收纳内容 |
|------|----------|
| `frontend/` | 组件、样式、状态管理、性能优化、框架实践 |
| `design/` | UI/UX 设计、配色、字体、动效、布局 |
| `engineering/` | TDD、调试、测试、部署、CI/CD、代码审查 |
| `workflow/` | 需求分析、计划、实现、分支管理、版本发布 |
| `meta/` | skill 编写、代理调度、工具技巧、AI 协作 |
