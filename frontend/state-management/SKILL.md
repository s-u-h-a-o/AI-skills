---
name: state-management
description: |
  Use when reading or writing shared application state from a tool, task, or service.
  Triggered when: accessing state outside a React component, updating a field in a
  shared state store, writing a helper that modifies task or session state, or
  understanding why direct mutation causes stale UI or race conditions.
---

# 状态管理

## 模式

共享可变状态包裹在深度不可变类型中。直接修改是编译错误。所有更新通过单一 setter 进行，该 setter 接收一个纯函数 `(prev: State) => State`。返回相同引用意味着"没有变化"，并跳过下游工作——不重新渲染、不做 diff。

reducer 函数是原子的：整个状态对象在一次操作中被替换。部分更新通过展开运算符表达——未变化的字段从 `prev` 继承；只有变化的字段是新值。这使得每次转换都是显式的、可追踪的、竞态安全的。

## 为什么重要

Claude Code 的 AppState 是一个大型对象——UI 标志、权限上下文、任务记录、会话配置——在并发运行的工具、在终端中渲染的 React 组件和后台任务 worker 之间共享。没有不可变性契约，正在更新 `tasks` 的工具可能与正在中间状态读取 `toolPermissionContext` 的 UI 组件发生竞态，导致撕裂读取。

`DeepImmutable<T>` 包装器在类型层面杜绝了这种可能性。TypeScript 拒绝直接赋值给任何嵌套字段。改变状态的唯一方式是通过 reducer，它原子性地替换整个对象。引用相等性短路（当没有变化时 `return prev`）阻止调度器为无操作更新安排重新渲染——当多个任务快速连续调用 `setAppState` 时这一点尤为重要。

## 如何应用

1. 通过 `context.getAppState()` 读取状态——返回当前不可变快照。
2. 通过 `context.setAppState(prev => next)` 写入状态。始终返回新对象；永远不要修改 `prev`。
3. 对于嵌套更新（如 `tasks` 内部的字段），在每一层展开：`{ ...prev, tasks: { ...prev.tasks, [id]: updated } }`。
4. 当更新是条件性的且条件为假时，原样返回 `prev`——这是引用相等性的无操作信号。
5. 对同一子对象的重复嵌套更新，提取一个处理展开和无操作检查的辅助函数——如果更新器返回相同引用，原样返回 `prev` 以避免不必要地触发订阅者。
6. 永远不要从模块级变量访问状态。状态始终来自 `context.getAppState()`。

## 源码示例

```typescript
// Source: src/state/AppStateStore.ts
export type AppState = DeepImmutable<{
  verbose: boolean
  tasks: Record<string, TaskState>
  toolPermissionContext: ToolPermissionContext
  // ... 还有约 100 个字段
}>
// DeepImmutable 使每个字段和嵌套字段变为只读。
// 直接修改——state.verbose = true——是 TypeScript 错误。

// Source: src/utils/task/framework.ts
type SetAppState = (updater: (prev: AppState) => AppState) => void

export function updateTaskState<T extends TaskState>(
  taskId: string,
  setAppState: SetAppState,
  updater: (task: T) => T,
): void {
  setAppState(prev => {
    const task = prev.tasks?.[taskId] as T | undefined
    if (!task) return prev                 // 无操作：任务未找到

    const updated = updater(task)
    if (updated === task) return prev      // 无操作：更新器返回相同引用

    return {
      ...prev,
      tasks: { ...prev.tasks, [taskId]: updated },
    }
  })
}

// Source: src/tasks/stopTask.ts
setAppState(prev => {
  const prevTask = prev.tasks[taskId]
  if (!prevTask || prevTask.notified) {
    return prev   // 返回相同引用——不触发重新渲染
  }
  return {
    ...prev,
    tasks: {
      ...prev.tasks,
      [taskId]: { ...prevTask, notified: true },
    },
  }
})
```

`updateTaskState` 中的 `if (updated === task) return prev` 检查设计精巧但很重要。没有它，每次调用 `setAppState` 都会触发订阅者，即使什么都没改变——在一个每秒有几十个任务轮询状态的系统中，这会让 React 渲染调度器不堪重负。

## 应用到你的代码

**修复前** — 直接修改状态并存储在模块级变量中：
```typescript
// 错误：模块级状态——跨调用共享，导致陈旧读取
let taskStatuses: Record<string, string> = {}

async call(args, context) {
  taskStatuses[args.taskId] = 'running'       // 直接修改，无广播
  await doWork(args)
  taskStatuses[args.taskId] = 'completed'     // UI 永远看不到这个
  return { data: 'done' }
}
```

**修复后** — 通过 context 进行原子 reducer 更新：
```typescript
async call(args, context) {
  // WHY: setAppState 原子性地广播给所有订阅者
  context.setAppState(prev => ({
    ...prev,
    tasks: {
      ...prev.tasks,
      [args.taskId]: { ...prev.tasks[args.taskId], status: 'running' },
    },
  }))

  await doWork(args)

  // WHY: 条件不满足时原样返回 prev——跳过重新渲染
  context.setAppState(prev => {
    const task = prev.tasks[args.taskId]
    if (!task || task.status !== 'running') return prev
    return {
      ...prev,
      tasks: {
        ...prev.tasks,
        [args.taskId]: { ...task, status: 'completed' },
      },
    }
  })

  return { data: 'done' }
}
```

## 需要此模式的信号

- 工具将会话状态存储在模块级变量或闭包中——跨调用会产生陈旧数据
- 组件读取了由工具更新但显示仍为旧值的状态
- 两个并发工具更新同一字段产生不一致结果
- `call()` 内部的状态更新在下一次完整渲染周期之前未反映到 UI 中

## 过度应用的信号

- 工具内部纯计算（局部变量、中间结果）不需要 `setAppState`——只有需要在当前调用之外继续存在或需要对其他工具或 UI 可见的值才需要
- 不要在紧凑循环中为进度更新调用 `setAppState`——批量处理或改用 `onProgress` 回调
- 不要对属于任务磁盘支持输出文件的数据使用 AppState——大输出放到磁盘，不放内存

## 配合使用

- `domain-model` — AppState 在整个系统模型中的位置
- `task-system` — 任务生命周期转换是最常见的 AppState 更新模式
- `async-concurrency` — 并发工具安全地读写状态
- `tool-definition` — 如何从 `call()` 访问 `context.getAppState()` 和 `context.setAppState()`
