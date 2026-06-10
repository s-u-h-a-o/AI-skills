---
name: async-concurrency
description: |
  Teaches Claude Code's concurrency model: isConcurrencySafe() for parallel tool execution, AbortController propagation for cancellation, Promise.all() for parallel initialization, and the StreamingToolExecutor for concurrent progress streams. Use this when writing tools that could benefit from parallel execution, need to respect cancellation, or must stream partial results. Read-only tools that don't declare concurrency safety are needlessly serialized.
---

# 异步并发

## 模式

Claude Code 的工具执行大多是顺序的——每次一个工具——但只读工具在 `isConcurrencySafe()` 返回 true 时可以并行运行。取消操作通过 `AbortController` 经由 `ToolUseContext` 传播。并行初始化使用 `Promise.all()`。流式输出部分结果使用 `onProgress` 回调，接入 `StreamingToolExecutor`。

核心设计：并发安全性是每次调用的判断，而非工具的常量属性。执行 `git status` 的 bash 工具可以安全并发。同一个 bash 工具执行 `npm install` 则不行。工具了解自己的输入，能做出正确的判断。

## 为什么重要

在开发者会话中，LLM 经常依次请求多个读操作（读文件 A、读文件 B、检查 git 状态）。如果这些严格串行执行，用户需要等待三次磁盘往返。`isConcurrencySafe: true` 告知调度器可以并行执行，减少感知延迟。

取消对于长时间运行的工具（bash 命令、网络请求）至关重要。当用户按下 Ctrl+C 时，`AbortController` 的信号触发，所有正在进行的工具调用必须立即停止。忽略 `context.abortController.signal` 的工具将在用户取消后继续运行，阻塞下一轮会话。

Git 状态是一个具体示例：Claude Code 使用单个 `Promise.all()` 并行执行五个 git 命令——分支、默认分支、状态、最近日志和用户名。这将约 500ms 的顺序 I/O 压缩为约 100ms 的并发批次。

## 如何应用

1. 对 `isConcurrencySafe(input)`：仅对不改变状态的操作返回 `true`。文件读取、glob、搜索、git status 命令是安全的。文件写入、bash 变更操作、agent 生成不安全。
2. 对 `isReadOnly(input)`：对不产生持久变更的操作返回 `true`。用于判断工具是否可在推测模式下跳过。
3. 将 `context.abortController.signal` 传递给所有异步 I/O：`fetch()`、`execFile()`、文件流。这确保用户中断时立即取消。
4. 在长时间运行的循环的检查点检查 `signal.aborted`。
5. 当工具运行多个独立的 I/O 操作时，使用 `Promise.all()`——不要逐个 await。
6. 要流式输出部分结果，在工作进行中调用 `onProgress(progressData)`。UI 订阅这些调用来显示实时输出。

## 源码示例

```typescript
// Source: src/context.ts (并行 git status——五个并发命令)
export const getGitStatus = memoize(async (): Promise<string | null> => {
  const isGit = await getIsGit()
  if (!isGit) return null

  // 五个独立的 git 命令通过 Promise.all 并行执行
  // 顺序执行约需 ~500ms；并行约需 ~100ms
  const [branch, mainBranch, status, log, userName] = await Promise.all([
    getBranch(),
    getDefaultBranch(),
    execFileNoThrow(gitExe(), ['--no-optional-locks', 'status', '--short']),
    execFileNoThrow(gitExe(), ['--no-optional-locks', 'log', '--oneline', '-n', '5']),
    execFileNoThrow(gitExe(), ['config', 'user.name']),
  ])

  // ... 格式化并返回
})

// Source: src/Tool.ts (BashTool 的 isConcurrencySafe 依赖输入)
export const BashTool: Tool<typeof inputSchema> = {
  isConcurrencySafe(input) {
    // 仅当命令被分类为搜索/读取时才安全
    const classification = isSearchOrReadBashCommand(input.command)
    return classification.isSearch || classification.isRead
  },

  isReadOnly(input) {
    const classification = isSearchOrReadBashCommand(input.command)
    return classification.isSearch || classification.isRead
  },

  async call(args, context, canUseTool) {
    // AbortController 信号传递给 shell 执行
    const result = await executeShell(args.command, {
      signal: context.abortController.signal,
      cwd: getCwd(),
    })
    return { type: 'success', data: result.stdout }
  },
}

// Source: src/Tool.ts (onProgress 用于流式输出)
async call(args, context, canUseTool, parentMessage, onProgress) {
  const proc = spawnProcess(args.command)

  proc.stdout.on('data', (chunk: Buffer) => {
    // 将部分输出实时推送到 UI
    onProgress?.({
      type: 'output',
      content: chunk.toString(),
    })
  })

  const exitCode = await proc.exitCode
  return { type: 'success', data: proc.collectedOutput }
}
```

`getGitStatus` 上的 `memoize()` 设计精巧：git status 在对话开始时被调用，如果某个工具触发重新评估，它可能被再次调用。Memoize 可防止重复运行全部五个 git 命令。当状态改变（如分支切换）时缓存被清除。

## 应用到你的代码

**修复前** — 只读工具不必要地阻塞并发执行：
```typescript
export const SearchTool: Tool<typeof inputSchema> = {
  // 错误：对只读操作返回 false，强制串行执行
  isConcurrencySafe: (_input) => false,
  isReadOnly: (_input) => false,

  async call(args, context, canUseTool) {
    // 未传递 signal——忽略取消操作
    const results = await searchFiles(args.pattern, args.directory)
    return { data: results }
  },
}
```

**修复后** — 工具正确声明并发性并遵循取消信号：
```typescript
import { AbortError } from '../../utils/errors.js'

export const SearchTool: Tool<typeof inputSchema> = {
  // 搜索始终是只读的——可与其他搜索工具并行运行
  isConcurrencySafe: (_input) => true,
  isReadOnly: (_input) => true,

  async call(args, context, canUseTool, _parentMessage, onProgress) {
    const results: string[] = []

    for await (const match of streamSearchResults(args.pattern, args.directory)) {
      // 在每个结果处检查取消状态——用户取消后不再处理
      if (context.abortController.signal.aborted) {
        throw new AbortError('搜索已取消。')
      }

      results.push(match)

      // 流式输出部分结果以提供响应式反馈
      onProgress?.({ type: 'partial_results', count: results.length })
    }

    return { data: results }
  },
}
```

## 需要此模式的信号

- 只读工具（文件读取、glob、grep）设置了 `isConcurrencySafe: () => false`
- 长时间运行的工具未将 `context.abortController.signal` 传递给其 I/O 操作
- 一个工具按顺序执行了 3 个以上独立的异步调用，而本可以 `Promise.all()` 并行
- 用户反馈 Ctrl+C 无法停止工具，会话挂起
- 长时间操作期间 UI 无进度显示，即使部分结果已可用

## 过度应用的信号

- 变更操作（写入、生成、删除）必须永远不返回 `isConcurrencySafe: true`——这里没有合法的并行变更模式
- 不要对依赖彼此输出的操作使用 `Promise.all()`
- `onProgress` 是可选的——不要为瞬时操作发送进度；其开销不值得

## 配合使用

- `tool-definition` — `isConcurrencySafe` 和 `isReadOnly` 的声明位置
- `error-handling` — 处理已取消异步操作的 AbortError
- `hot-paths` — 作为启动性能模式的并行初始化
