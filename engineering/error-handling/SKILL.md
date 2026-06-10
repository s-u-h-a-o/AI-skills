---
name: error-handling
description: |
  Teaches Claude Code's error philosophy: tool call() throws typed errors, the framework catches them and formats them for the LLM as structured tool result content, and custom error types carry structured context at system boundaries. Use this whenever writing a tool, utility function, or service that can fail. The distinction between "errors the LLM should see" and "errors that crash the session" is the core insight.
---

# 错误处理

## 模式

Claude Code 有两类错误。**会话级错误**（Session errors）是不可恢复的故障，会导致进程崩溃或中止当前会话（网络配置问题、认证失败、状态损坏）。**工具级错误**（Tool errors）是可预期的失败，应展示给 LLM，使其能够推理、重试或向用户解释情况。

基本原则：`tool.call()` 对可预期的失败抛出类型化错误。框架捕获这些错误，调用 `src/utils/toolErrors.ts` 中的 `formatError(error)`，并将格式化后的字符串以 `is_error: true` 的 `tool_result` 块传递给 LLM。只有真正不可恢复的基础设施故障才应作为未处理异常传播到框架之外。

## 为什么重要

LLM 处于对话循环中。如果工具抛出原始的、未格式化的异常，框架必须决定向模型展示什么——堆栈跟踪毫无用处。通过抛出类型化错误（`ShellError`、`AbortError`、`Error`），工具为框架提供了足够结构来生成清晰易读的消息。例如，`FileReadTool` 抛出的文件未找到错误让 LLM 能够建议正确的路径或请用户检查。

这也意味着用户看到的是一个连贯的解释，而非错误弹窗。LLM 会在其下一条回复中将技术错误翻译为自然语言。

自定义错误类型（`ShellError`、`AbortError`）用于系统边界——它们携带结构化上下文（退出码、stderr、中断标志），`formatError` 利用这些构建正确的消息。

## 如何应用

1. 在 `call()` 内部将所有 I/O 包裹在 try-catch 中。先捕获特定错误类型，然后重新抛出或让其传播。
2. 对可预期的非 shell 失败，使用 `throw new Error(message)`。包含足够上下文让 LLM 采取行动：尝试了什么、什么失败了、用户可以检查什么。
3. 对于 ENOENT（文件未找到）：使用 `utils/errors.js` 中的 `isENOENT()` 检测，并抛出 `new Error("文件未找到：/path。文件是否存在？")`。
4. 对于命令失败：抛出 `new ShellError(stdout, stderr, code, interrupted)`——`formatError` 自动组装退出码和 stderr。
5. 对于用户取消：抛出 `new AbortError()`——`formatError` 将其映射为干净的中断消息。
6. 当错误携带格式化逻辑所需的结构化数据时，定义自定义错误类型。

## 源码示例

```typescript
// Source: src/tools/BashTool/BashTool.tsx
if (result.preSpawnError) {
  throw new Error(result.preSpawnError)  // 预生成失败 → 普通 Error
}
if (interpretationResult.isError && !isInterrupt) {
  throw new ShellError('', outputWithSbFailures, result.code, result.interrupted)
  // ShellError 携带结构化上下文；formatError 构建 LLM 消息
}

// Source: src/utils/toolErrors.ts — 框架在捕获后调用此函数
export function formatError(error: unknown): string {
  if (error instanceof AbortError) {
    return error.message || INTERRUPT_MESSAGE_FOR_TOOL_USE
  }
  if (!(error instanceof Error)) return String(error)
  const parts = getErrorParts(error)
  return parts.filter(Boolean).join('\n').trim() || 'Command failed with no output'
  // 超过 10 000 字符则截断
}

export function getErrorParts(error: Error): string[] {
  if (error instanceof ShellError) {
    return [`Exit code ${error.code}`, error.interrupted ? '...' : '', error.stderr, error.stdout]
  }
  return [error.message]
}

// Source: src/tools/FileReadTool/FileReadTool.ts
import { isENOENT } from '../../utils/errors.js'  // 非 utils/file.js

} catch (error) {
  if (isENOENT(error)) {
    throw new Error(`文件未找到：${file_path}。文件是否存在？`)
  }
  throw error  // 重新抛出来知错误——框架会处理
}
```

关于中止错误的分支需要注意：当用户按下 Ctrl+C 时，`AbortError` 会传播到所有正在进行的异步调用。工具必须让其传播（或抛出新的 `AbortError`），以便 `formatError` 返回干净的"已中断"消息。

## 应用到你的代码

**修复前** — 工具返回错误的形状而非抛出：
```typescript
async call(args, context, canUseTool) {
  try {
    const response = await fetch(args.url)
    if (!response.ok) {
      return { type: 'error', error: `HTTP ${response.status}` }  // 错误形状：ToolResult 没有 error 变体
    }
    return { type: 'success', data: await response.text() }       // 错误形状：ToolResult 上没有 'type' 字段
  } catch (err) {
    return { type: 'error', error: String(err) }                  // 错误：吞掉 AbortError，错误的形状
  }
}
```

**修复后** — 工具抛出类型化错误：
```typescript
async call(args, context, canUseTool) {
  try {
    const response = await fetch(args.url, {
      signal: context.abortController.signal,  // WHY: 让 AbortError 在 Ctrl+C 时传播
    })

    if (!response.ok) {
      // WHY: 抛出 Error 使 formatError 向 LLM 呈现可读消息
      throw new Error(`HTTP ${response.status} ${response.statusText} 请求 ${args.url}`)
    }

    return { data: await response.text() }  // WHY: ToolResult<T> 就是 { data: T }
  } catch (err) {
    if (err instanceof AbortError) throw err  // WHY: 让框架干净地处理取消
    // WHY: 网络错误（DNS 失败、超时）以带上下文的普通 Error 重新抛出
    throw new Error(`网络错误 请求 ${args.url}：${err instanceof Error ? err.message : String(err)}`)
  }
}
```

## 需要此模式的信号

- 工具的 `call()` 返回 `{ type: 'error', error: ... }`——`ToolResult<T>` 上没有 error 变体；应抛出错误
- 日志中出现来自工具执行的未处理 Promise rejection
- LLM 收到原始堆栈跟踪作为工具结果内容
- 错误消息说"出了点问题"却没有文件路径、退出码或可操作的提示
- `isENOENT` 从 `utils/file.js` 导入——正确来源是 `utils/errors.js`
- `AbortError` 被捕获并吞掉——Ctrl+C 导致错误弹窗而非干净取消

## 过度应用的信号

- 仅被其他工具内部调用的工具函数不需要特殊的错误处理——它们可以自由抛出；调用方工具会捕获
- 会话级错误（认证失败、Claude API 不可达）应作为异常传播到会话处理器，而非被吞为工具错误
- 不要为来自你掌控的内部调用的不可能的错误情况编写详尽的 catch 分支

## 配合使用

- `tool-definition` — ToolResult 类型及错误在返回值中的位置
- `permission-system` — 将权限拒绝作为特定错误情况处理
- `async-concurrency` — 工具被取消时的 AbortError 处理
