---
name: module-organisation
description: |
  Teaches Claude Code's module organization: tools/ for capabilities, commands/ for user-facing slash commands, services/ for business logic, state/ for AppState, utils/ for pure utilities, hooks/ for React state, and components/ for TUI rendering. Use this when deciding where to put new code or when tracing an unfamiliar behavior to its source. The division is by responsibility boundary, not by feature.
---

# 模块组织

## 模式

Claude Code 按职责而非功能来组织代码。`src/` 下的每个顶层目录负责系统的特定层次。工具放在 `tools/` 中，每个工具在其自己的子目录 `[Name]Tool/` 中。命令放在 `commands/` 中，每个命令在其自己的子目录或文件中。业务逻辑放在 `services/` 中。AppState 放在 `state/` 中。React hooks 放在 `hooks/` 中。React 组件（TUI 渲染）放在 `components/` 中。纯工具函数放在 `utils/` 中。

规则：工具知道如何执行某项能力。服务知道如何跨多个工具或外部系统进行协调。组件知道如何渲染状态。hook 知道如何订阅状态。这些从不交叉——工具不渲染，组件不调用 bash 命令。

## 为什么重要

Claude Code 是一个运行在终端中的 React 应用。它具有 Web 应用的完整复杂性（UI 状态、异步数据、事件处理），加上能力系统的额外复杂性（工具、权限、流式传输）。没有严格的层次分离，服务逻辑会泄漏到组件中、渲染逻辑会泄漏到工具中、状态管理会变得隐式。

每个工具一个子目录的模式（`tools/BashTool/BashTool.tsx`）是刻意设计的：每个工具都足够大，值得拥有自己的命名空间。`BashTool.tsx` 使用 `.tsx` 是因为 bash 输出可以在 TUI 中渲染为 JSX。`FileReadTool.ts` 使用 `.ts` 是因为其输出是纯数据。文件扩展名表明该工具是否涉及 UI 关注点。

## 如何应用

1. **新能力**（文件操作、shell 命令、Web 请求、子 Agent）：创建 `src/tools/[Name]Tool/[Name]Tool.ts[x]`。将工具导出为命名常量。在 `src/tools.ts` 中注册。
2. **新用户命令**（`/something`）：创建 `src/commands/something/index.ts` 或 `src/commands/something.ts`。在 `src/commands.ts` 中注册。
3. **新外部服务集成**（API 客户端、MCP 适配器）：创建 `src/services/[name]/`。将所有 HTTP/socket 代码放在此处。
4. **新 AppState 字段**：将其添加到 `AppStateStore.ts` 的 `AppState` 类型中。添加到 `initialState`。在 `state/selectors.ts` 中暴露一个选择器。
5. **新 React hook**（订阅状态、调用 API）：创建 `src/hooks/use[Name].ts`。
6. **新 UI 组件**（在终端中渲染）：创建 `src/components/[Name].tsx`。
7. **纯工具函数**（字符串处理、路径规范化、类型守卫）：创建 `src/utils/[name].ts`。无副作用，不从 `state/` 或 `tools/` 导入。

## 源码结构

```
src/
├── tools/                    # 能力：每个是一个 Tool<Input, Output>
│   ├── BashTool/
│   │   ├── BashTool.tsx      # .tsx：将 bash 输出渲染为 JSX
│   │   ├── bashPermissions.ts
│   │   └── bashUtils.ts
│   ├── FileReadTool/
│   │   └── FileReadTool.ts   # .ts：纯数据，无渲染
│   ├── AgentTool/
│   │   └── AgentTool.tsx     # 生成子 Agent——有 UI 进度
│   └── GlobTool/
│       └── GlobTool.ts
│
├── commands/                 # 用户斜杠命令：/commit、/add-dir、/plan
│   ├── commit.ts             # 简单命令：单个文件
│   ├── config/               # 复杂命令：子目录
│   │   ├── index.ts
│   │   └── configHelpers.ts
│   └── add-dir/
│       └── index.ts
│
├── services/                 # 跨切面业务逻辑
│   ├── api/                  # Claude API 客户端
│   ├── mcp/                  # Model Context Protocol
│   ├── compact/              # 消息压缩算法
│   ├── tools/                # 工具编排（非工具实现）
│   │   └── toolOrchestration.ts
│   └── analytics/
│
├── state/                    # AppState：单一真相源
│   ├── AppStateStore.ts      # 类型 + 初始状态（700 行）
│   ├── AppState.tsx          # React provider
│   ├── store.ts              # Zustand 工厂
│   └── selectors.ts
│
├── utils/                    # 纯函数，无副作用
│   ├── messages.ts           # 消息规范化流水线
│   ├── permissions/          # 权限规则匹配
│   ├── bash/                 # Bash 命令解析
│   └── file.ts               # 文件路径辅助、isENOENT()
│
├── hooks/                    # React hooks（状态订阅）
│   ├── useCanUseTool.ts
│   └── useSettingsChange.ts
│
└── components/               # TUI 组件（Ink/React）
    ├── REPL.tsx
    └── Spinner.tsx
```

`services/tools/` 目录与 `tools/` 不同——它包含运行工具的编排逻辑（调度、并发、预算），而非工具实现本身。这防止工具了解自己的调度机制。

## 应用到你的代码

**修复前** — 新能力直接添加到查询循环中：
```typescript
// src/query.ts — 错误：能力逻辑污染消息循环
async function handleToolCall(toolName: string, input: unknown) {
  if (toolName === 'search_logs') {
    // 50 行日志搜索逻辑直接写在这里
    const logs = await readLogsFromDisk(input.path)
    return { content: formatLogs(logs) }
  }
  // ...
}
```

**修复后** — 能力放在正确的位置：
```typescript
// src/tools/SearchLogsTool/SearchLogsTool.ts
export const SearchLogsTool: Tool<typeof inputSchema, string> = {
  inputSchema,
  isConcurrencySafe: (_input) => true,
  isReadOnly: (_input) => true,
  async call(args, context, canUseTool) { /* ... */ },
  async description(input) { return `在 ${input.path} 中搜索日志` },
}

// src/tools.ts — 注册它
import { SearchLogsTool } from './tools/SearchLogsTool/SearchLogsTool.js'
export const getTools = (): Tools => [
  // ...已有工具...
  SearchLogsTool,
]
```

## 需要此模式的信号

- 业务逻辑（HTTP 调用、文件解析、权限检查）直接存在于 React 组件中
- 工具直接从 `state/AppStateStore.ts` 导入而非接收 `context`
- `utils/` 中的工具函数有副作用或从 `tools/` 导入
- 需要访问多个工具的命令自行组装而非使用工具注册表
- 新功能在 `src/` 根目录添加文件而非正确的子目录

## 过度应用的信号

- 单个函数的工具函数不需要自己的子目录——放在 `utils/` 中的一个文件即可
- 如果工具辅助函数仅被该工具使用，就放在同一子目录中；不要移到 `utils/`
- 并非每个工具都需要 `.tsx` 扩展名——仅在工具输出被渲染为 JSX 时使用

## 配合使用

- `domain-model` — 解释映射到这些目录的六个概念
- `tool-definition` — `tools/` 中所有工具实现的 Tool 接口
- `naming-conventions` — 每个模块内的文件和导出命名规范
