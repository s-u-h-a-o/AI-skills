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

## Skill 一览

### 🖌️ 设计系统 (`design/`)

| Skill | 用途 |
|-------|------|
| `ui-ux-pro-max` | UI/UX 设计知识库：67 风格、96 调色板、57 字体搭配、25 图表、13 技术栈 |
| `theme-factory` | 10 套预设主题工厂，一键套用或自定义生成配色 + 字体搭配 |
| `canvas-design` | Canvas 设计哲学：创建海报、艺术作品等 PNG/PDF 静态视觉 |
| `accessibility-testing` | WCAG 2.1 AA/AAA 无障碍审计，产出修复方案和代码 |
| `wireframing` | 文本线框图设计：低/中/高保真度，含组件清单和交互标注 |

### 🎨 前端开发 (`frontend/`)

| Skill | 用途 |
|-------|------|
| `frontend-ui-engineering` | 生产级 UI 组件开发：可访问、高性能、非 AI 审美 |
| `frontend-design` | 有意识的独特视觉设计指导：配色、排版、布局的差异化选择 |
| `web-artifacts-builder` | React + TypeScript + Vite + Tailwind + shadcn/ui 脚手架与打包 |
| `state-management` | 不可变状态管理模式：`(prev: State) => State`，防竞态 |
| `types-and-interfaces` | TypeScript 类型设计：discriminated union、Zod 单一真相源 |

### ⚙️ 工程质量 (`engineering/`)

| Skill | 用途 |
|-------|------|
| `test-driven-development` | TDD 红-绿-重构循环：先写测试 → 看失败 → 最少实现 → 重构 |
| `systematic-debugging` | 系统化调试四阶段法：复现 → 定位根因 → 修复 → 验证 |
| `verification-before-completion` | 完成前验证：先有证据再断言，禁止未经验证声称完成 |
| `deploy-to-ecs` | 部署到阿里云 ECS：Nginx 配置、构建上传、服务启动 |
| `webapp-testing` | Playwright 前端自动化测试：UI 验证、浏览器截图、日志查看 |
| `error-handling` | 结构化错误处理：类型化错误、区分 LLM 可见错误与会话崩溃 |
| `module-organisation` | 按职责边界组织代码：tools/、commands/、services/、hooks/ |
| `async-concurrency` | 异步并发模式：并发安全、AbortController 取消、流式输出 |

### 🔄 开发流程 (`workflow/`)

| Skill | 用途 |
|-------|------|
| `brainstorming` | 头脑风暴：探索意图 → 澄清需求 → 设计方案，所有创造性工作的前置步骤 |
| `writing-plans` | 编写实现计划：小口任务、精确文件路径、完整代码、TDD 步骤 |
| `executing-plans` | 执行实现计划：逐步执行、审查检查点、完成收尾 |
| `finishing-a-development-branch` | 收尾开发分支：验证测试 → 合并/PR/丢弃选项 → 清理 |
| `requesting-code-review` | 请求代码审查：派发 subagent 审查正确性、可读性、安全 |
| `receiving-code-review` | 接收代码审查：技术验证、有理反驳、不盲从不抵触 |

### 🧠 AI 协作技巧 (`meta/`)

| Skill | 用途 |
|-------|------|
| `using-superpowers` | Skill 体系导航入口：在任何响应前先检查可用 skill |
| `writing-skills` | 创建和验证 skill 的元技能：TDD 方法应用于流程文档 |
| `dispatching-parallel-agents` | 并行派发 Agent：2+ 独立任务同时处理 |
| `subagent-driven-development` | Subagent 驱动开发：每任务派发 + 两阶段审查（推荐执行方式） |
| `using-git-worktrees` | Git Worktree 隔离：创建独立工作区，不干扰当前分支 |

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
