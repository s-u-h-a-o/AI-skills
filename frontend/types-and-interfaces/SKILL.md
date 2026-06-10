---
name: types-and-interfaces
description: |
  Teaches Claude Code's type design: discriminated unions for output data shapes, Zod schemas as the single source of truth for tool inputs, DeepImmutable for AppState, and z.infer<> to derive TypeScript types from schemas. Use this when designing new types, adding AppState fields, or defining tool input schemas. The core discipline: define shape once, derive all other representations from it.
---

# 类型与接口

## 模式

Claude Code 统一使用三种类型模式：**对输出数据形状使用 discriminated union**（工具可返回多种结果之一时的 Zod `outputSchema`），**Zod schema 作为工具输入的单一真相源**（schema 同时驱动运行时验证和 TypeScript 类型，通过 `z.infer<>`），以及 **DeepImmutable 包装器**用于 AppState 以防止意外修改。

核心纪律是：定义一次形状，推导所有其他表示。工具输入的 Zod schema 在 `inputSchema` 中定义一次。TypeScript 类型 `z.infer<typeof inputSchema>` 从中推导。LLM 的 JSON schema 从中推导。运行时验证使用它。不存在第二个 `interface FooInput` 来偏离 schema。

## 为什么重要

LLM 输出 JSON。JSON 必须在运行时验证。TypeScript 类型捕获编译期问题。如果这两者分别定义，它们会偏离：TypeScript 接口说 `limit?: number` 但运行时验证器没有检查它是 number，导致运行时崩溃。Zod 通过同时作为运行时验证器和 `z.infer<>` 类型的来源来解决这个问题。

输出数据类型的 discriminated union（例如文件读取返回 text、image、pdf 或 file_unchanged）使穷尽处理由编译器强制执行。TypeScript 编译器在每个 `case` 分支中收窄类型。这消除了整整一类遗漏分支的 bug。对于错误，工具通过抛出而非返回错误变体——成功/错误的边界是抛出异常的契约，而非 `ToolResult` 的形状。

AppState 使用 `DeepImmutable<T>` 阻止任何人直接修改状态。所有状态变更必须通过 `setAppState(prev => next)`，使状态转换可追踪且原子化。

## 如何应用

1. **工具输入**：始终使用 Zod。使用 `utils/lazySchema.ts` 中的 `lazySchema()` 包装器推迟解析直到首次访问（更快启动）。使用 `z.strictObject`（而非 `z.object`）拒绝未知键。用 `type MyInput = z.infer<typeof inputSchema>` 推导 TypeScript 类型。
2. **工具输出形状**：当工具可以返回多种结果之一时，使用 `z.discriminatedUnion` 定义 Zod `outputSchema`。用 `type Output = z.infer<typeof outputSchema>` 推导 TypeScript 类型。
3. **AppState 字段**：添加到 `AppStateStore.ts` 的 `AppState` 类型中。该类型是 `DeepImmutable<{...}>`——嵌套对象也是深度不可变的。你不能 `.push()` 数组；必须用展开。
4. **消息类型**：使用已有的 discriminated union。在不理解规范化流水线的情况下不要添加新消息类型——消息在到达 API 之前经历多次转换。
5. **避免 `any`**：对在调用处类型确实未知的值使用 `unknown`，然后用类型守卫收窄。

## 源码示例

```typescript
// Source: src/Tool.ts (ToolResult——工具返回数据或抛出，没有 error 变体)
export type ToolResult<T> = {
  data: T
  newMessages?: (UserMessage | AssistantMessage | AttachmentMessage | SystemMessage)[]
  contextModifier?: (context: ToolUseContext) => ToolUseContext
  mcpMeta?: { _meta?: Record<string, unknown>; structuredContent?: Record<string, unknown> }
}

// 工具通过抛出来表示错误——而非返回 { type: 'error' }。
// 成功的调用返回 { data: result }：
return { data: result }

// Source: src/tools/FileReadTool/FileReadTool.ts (输出数据的 discriminated union)
import { lazySchema } from '../../utils/lazySchema.js'
import { z } from 'zod'

// outputSchema 使用 discriminatedUnion 因为文件读取可能产生多种结果
const outputSchema = lazySchema(() =>
  z.discriminatedUnion('type', [
    z.object({
      type: z.literal('text'),
      file: z.object({ filePath: z.string(), content: z.string(), numLines: z.number() }),
    }),
    z.object({
      type: z.literal('image'),
      file: z.object({ filePath: z.string(), /* ... */ }),
    }),
    z.object({
      type: z.literal('pdf'),
      file: z.object({ filePath: z.string(), /* ... */ }),
    }),
    z.object({
      type: z.literal('file_unchanged'),
      file: z.object({ filePath: z.string() }),
    }),
  ])
)
type OutputSchema = ReturnType<typeof outputSchema>
export type Output = z.infer<OutputSchema>

// TypeScript 在每个分支中收窄类型——不需要类型转换：
if (output.type === 'text') {
  console.log(output.file.content)  // TypeScript 知道这里的 content 是 string
}

// Source: src/tools/FileReadTool/FileReadTool.ts (Zod inputSchema 作为单一真相源)
// lazySchema() 推迟解析——不在模块加载时执行
const inputSchema = lazySchema(() =>
  z.strictObject({  // strictObject 拒绝未知键
    file_path: z.string().describe('要读取的文件的绝对路径'),
    offset: z.number().int().nonnegative().optional()
      .describe('开始读取的行号'),
    limit: z.number().int().positive().optional()
      .describe('最大读取行数'),
  })
)
type InputSchema = ReturnType<typeof inputSchema>
export type Input = z.infer<InputSchema>
// 等价于：{ file_path: string; offset?: number; limit?: number }

// Source: src/state/AppStateStore.ts (DeepImmutable AppState)
export type AppState = DeepImmutable<{
  settings: SettingsJson
  verbose: boolean
  tasks: Record<string, TaskState>  // DeepImmutable 递归地使其只读
  // ...
}>

// 修改是不可能的：
// state.verbose = true  // TypeScript 错误：不能赋值给只读属性

// 正确：推导新状态
context.setAppState(prev => ({ ...prev, verbose: true }))

// Source: src/Task.ts (TaskStatus 字符串字面量联合类型)
export type TaskStatus = 'pending' | 'running' | 'completed' | 'failed' | 'killed'

// TypeScript 强制 switch 中的穷尽检查：
function handleStatus(status: TaskStatus) {
  switch (status) {
    case 'pending': return '待处理'
    case 'running': return '运行中'
    case 'completed': return '已完成'
    case 'failed': return '失败'
    case 'killed': return '已终止'
    // 不需要 default——TypeScript 知道所有情况都已覆盖
  }
}
```

`lazySchema()` 包装器值得注意：Zod schema 构造在解析时做了重要工作（构建验证器函数）。在模块加载时调用它会增加启动延迟。`lazySchema()` 将构造器包裹在一个仅在首次访问时执行的 thunk 中，首次访问通常发生在首次工具调用时——此时启动已经完成。

## 应用到你的代码

**修复前** — 可能偏离的分离接口和运行时验证：
```typescript
// TypeScript 类型与运行时验证器分别定义
interface SearchInput {
  query: string
  maxResults?: number
  caseSensitive?: boolean
}

// 运行时验证器分别定义——可能与上面的接口偏离
function validateSearchInput(input: unknown): SearchInput {
  if (typeof input !== 'object') throw new Error('不是对象')
  if (typeof (input as any).query !== 'string') throw new Error('query 必须是 string')
  return input as SearchInput  // 危险的转换
}
```

**修复后** — Zod 作为单一真相源：
```typescript
import { lazySchema } from '../../utils/lazySchema.js'
import { z } from 'zod'

// 一次定义同时驱动 TypeScript 类型和运行时验证
const inputSchema = lazySchema(() =>
  z.strictObject({  // 拒绝未知键——使用 z.strictObject，而非 z.object
    query: z.string().min(1).describe('要搜索的文本'),
    maxResults: z.number().int().positive().max(1000).optional()
      .describe('最大结果数（默认：100）'),
    caseSensitive: z.boolean().optional()
      .describe('是否精确匹配大小写（默认：false）'),
  })
)

// 类型从 schema 推导——没有需要单独维护的接口
type InputSchema = ReturnType<typeof inputSchema>
type SearchInput = z.infer<InputSchema>
// { query: string; maxResults?: number; caseSensitive?: boolean }

// Schema 验证并类型化结果——不需要类型转换
const parsed = inputSchema.parse(rawInput)  // 无效时抛出 ZodError
const safe = inputSchema.safeParse(rawInput)  // 返回 { success, data } 或 { success: false, error }
```

## 需要此模式的信号

- TypeScript 接口和手动验证函数为同一数据形状并存
- 返回多种结果的工具没有带 discriminated union 的 `outputSchema`
- AppState 通过直接赋值修改（`state.field = value`）而非通过 `setAppState`
- 工具输入类型定义为普通 TypeScript 接口而非从 Zod schema 推导
- `as any` 或不安全的类型转换出现在本应使用 Zod 验证的地方

## 过度应用的信号

- 内部纯函数参数始终用已知类型调用，不需要 Zod 验证
- 简单的字符串字面量联合类型（`'left' | 'right'`）不需要 Zod schema——直接使用联合类型
- 不要把每个内部辅助函数的返回类型都包裹在 discriminated union 中；在系统/模块边界使用 discriminated union

## 配合使用

- `tool-definition` — Zod schema 作为 Tool 接口中的 `inputSchema` 和 `outputSchema`
- `error-handling` — 工具对错误抛出异常；ToolResult 只携带成功数据
- `domain-model` — AppState 的 DeepImmutable 类型形状
