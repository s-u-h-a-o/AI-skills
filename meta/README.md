# 🧠 AI 协作技巧

元技能类，提升与 AI 编码助手协作效率的技巧和工具使用。

## Skill 清单

### `writing-skills`

创建、编辑和验证 skill 的元技能。包含 Anthropic 最佳实践、说服原理、测试方法论。

> **场景示例：** 团队需要创建一个“React 表单最佳实践”skill → 先参考此 skill 中的模板和最佳实践，写出 SKILL.md，用 subagent 测试 skill 是否能正确触发和生效，验证后提交。

### `using-superpowers`

skill 体系的导航入口：每次对话开始时，先了解如何使用和发现 skill，要求在任何响应之前先检查可用 skill。

> **场景示例：** 新成员加入团队，第一次使用 AI 编码助手 → 自动提醒先用 `/plugin` 安装 skill 库，然后用 `Skill` 工具调用合适的 skill，而非跳过流程直接写代码。

### `dispatching-parallel-agents`

当面对 2 个以上相互独立的任务时，并行派发多个 agent 同时处理。

> **场景示例：** 需要同时实现用户模块、订单模块、商品模块三个独立功能 → 并行派发 3 个 subagent，各自在隔离的 worktree 中开发，最后汇总合并，节省 2/3 时间。

### `subagent-driven-development`

在执行实现计划时，将独立的子任务委托给 subagent 并行或顺序执行。

> **场景示例：** 实现计划中有一个“重构 API 层”的子任务，不依赖其他步骤 → 发送给独立 subagent 执行，自己继续做数据库迁移，两个任务互不阻塞。

### `using-git-worktrees`

在开始 feature 开发前，创建隔离的 git worktree，避免影响当前工作区。

> **场景示例：** 正在 main 分支调试一个紧急 bug，PM 来了一个新需求 → 用 worktree 切出一个独立目录开发新功能，原终端继续调试，互不干扰。
