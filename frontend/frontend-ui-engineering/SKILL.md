---
name: frontend-ui-engineering
description: Builds production-quality UIs. Use when building or modifying user-facing interfaces. Use when creating components, implementing layouts, managing state, or when the output needs to look and feel production-quality rather than AI-generated.
---

# 前端 UI 工程

## 概述

构建可访问、高性能、视觉精良的生产级用户界面。目标是让 UI 看起来像是由顶级公司里懂设计的前端工程师构建的——而不是 AI 生成的。这意味着真正遵循设计系统、恰当的无障碍访问、富有思考的交互模式，以及没有通用的"AI 审美感"。

## 适用场景

- 构建新的 UI 组件或页面
- 修改现有的用户交互界面
- 实现响应式布局
- 添加交互性或状态管理
- 修复视觉或 UX 问题

## 组件架构

### 文件结构

将与组件相关的所有内容就近放置：

```
src/components/
  TaskList/
    TaskList.tsx          # 组件实现
    TaskList.test.tsx     # 测试
    TaskList.stories.tsx  # Storybook 故事（如有使用）
    use-task-list.ts      # 自定义 hook（如果状态复杂）
    types.ts              # 组件特定类型（如需）
```

### 组件模式

**优先组合而非配置：**

```tsx
// 好：可组合
<Card>
  <CardHeader>
    <CardTitle>任务</CardTitle>
  </CardHeader>
  <CardBody>
    <TaskList tasks={tasks} />
  </CardBody>
</Card>

// 避免：过度配置
<Card
  title="任务"
  headerVariant="large"
  bodyPadding="md"
  content={<TaskList tasks={tasks} />}
/>
```

**保持组件聚焦：**

```tsx
// 好：只做一件事
export function TaskItem({ task, onToggle, onDelete }: TaskItemProps) {
  return (
    <li className="flex items-center gap-3 p-3">
      <Checkbox checked={task.done} onChange={() => onToggle(task.id)} />
      <span className={task.done ? 'line-through text-muted' : ''}>{task.title}</span>
      <Button variant="ghost" size="sm" onClick={() => onDelete(task.id)}>
        <TrashIcon />
      </Button>
    </li>
  );
}
```

**数据获取与展示分离：**

```tsx
// 容器：处理数据
export function TaskListContainer() {
  const { tasks, isLoading, error } = useTasks();

  if (isLoading) return <TaskListSkeleton />;
  if (error) return <ErrorState message="加载任务失败" retry={refetch} />;
  if (tasks.length === 0) return <EmptyState message="暂无任务" />;

  return <TaskList tasks={tasks} />;
}

// 展示：处理渲染
export function TaskList({ tasks }: { tasks: Task[] }) {
  return (
    <ul role="list" className="divide-y">
      {tasks.map(task => <TaskItem key={task.id} task={task} />)}
    </ul>
  );
}
```

## 状态管理

**选择可行的最简方案：**

```
本地状态 (useState)             → 组件特定 UI 状态
状态提升                        → 2-3 个兄弟组件共享
Context                         → 主题、认证、语言（读多写少）
URL 状态 (searchParams)         → 筛选、分页、可分享的 UI 状态
服务端状态 (React Query、SWR)   → 带缓存机制的远程数据
全局 store (Zustand、Redux)     → 应用级共享的复杂客户端状态
```

**避免 prop 向下传递超过 3 层。** 如果你在通过不需要这些 props 的组件传递它们，引入 Context 或重构组件树。

## 设计系统遵循

### 避免 AI 审美感

AI 生成的 UI 有可识别的模式。全部避免：

| AI 默认做法 | 为何是问题 | 生产级做法 |
|---|---|---|
| 到处都是紫色/靛蓝色 | 模型默认选择视觉"安全"的调色板，让每个应用看起来都一个样 | 使用项目的实际调色板 |
| 过多的渐变色 | 渐变增加视觉噪音，与大多数设计系统冲突 | 扁平或匹配设计系统的微妙渐变 |
| 全是圆角 (rounded-2xl) | 最大圆角暗示"友好"但忽略了实际设计中圆角半径的层级 | 设计系统中一致的 border-radius |
| 通用的主视觉区 | 模板驱动的布局，与实际内容或用户需求无关联 | 内容优先的布局 |
| 类 lorem ipsum 的文案 | 占位文本掩盖了真实内容会暴露的布局问题（长度、折行、溢出） | 真实感的占位内容 |
| 到处是过大的内边距 | 等量的大内边距破坏视觉层级并浪费屏幕空间 | 一致的间距尺度 |
| 模板化的卡片网格 | 统一网格是一种忽略信息优先级和浏览模式的布局捷径 | 目的驱动的布局 |
| 阴影过重的设计 | 多层阴影增加与内容竞争的深度，在低端设备上拖慢渲染 | 微妙或不用阴影，除非设计系统指定 |

### 间距与布局

使用一致的间距尺度，不要臆造数值：

```css
/* 使用尺度：0.25rem 增量（或项目所用的任何尺度） */
/* 好 */  padding: 1rem;      /* 16px */
/* 好 */  gap: 0.75rem;       /* 12px */
/* 差 */  padding: 13px;      /* 不在任何尺度上 */
/* 差 */  margin-top: 2.3rem; /* 不在任何尺度上 */
```

### 字体排版

遵循字体层级：

```
h1 → 页面标题（每页一个）
h2 → 区块标题
h3 → 子区块标题
body → 默认文本
small → 次要/辅助文本
```

不要跳级。不要将标题样式用于非标题内容。

### 颜色

- 使用语义化颜色 token：`text-primary`、`bg-surface`、`border-default`——而非原始 hex 值
- 确保足够的对比度（普通文本 4.5:1，大文本 3:1）
- 不要仅依靠颜色传达信息（同时使用图标、文字或图案）

## 无障碍访问（WCAG 2.1 AA）

每个组件必须满足这些标准：

### 键盘导航

```tsx
// 每个可交互元素必须可通过键盘访问
<button onClick={handleClick}>点我</button>        // ✓ 默认可聚焦
<div onClick={handleClick}>点我</div>               // ✗ 不可聚焦
<div role="button" tabIndex={0} onClick={handleClick}    // ✓ 但优先使用 <button>
     onKeyDown={e => {
       if (e.key === 'Enter') handleClick();
       if (e.key === ' ') e.preventDefault();
     }}
     onKeyUp={e => {
       if (e.key === ' ') handleClick();
     }}>
  点我
</div>
```

### ARIA 标签

```tsx
// 为缺少可见文字的可交互元素添加标签
<button aria-label="关闭对话框"><XIcon /></button>

// 为表单输入添加标签
<label htmlFor="email">邮箱</label>
<input id="email" type="email" />

// 或在没有可见标签时使用 aria-label
<input aria-label="搜索任务" type="search" />
```

### 焦点管理

```tsx
// 内容变化时移动焦点
function Dialog({ isOpen, onClose }: DialogProps) {
  const closeRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (isOpen) closeRef.current?.focus();
  }, [isOpen]);

  // 打开时将焦点困在对话框内
  return (
    <dialog open={isOpen}>
      <button ref={closeRef} onClick={onClose}>关闭</button>
      {/* 对话框内容 */}
    </dialog>
  );
}
```

### 有意义的空状态和错误状态

```tsx
// 不要展示空白页面
function TaskList({ tasks }: { tasks: Task[] }) {
  if (tasks.length === 0) {
    return (
      <div role="status" className="text-center py-12">
        <TasksEmptyIcon className="mx-auto h-12 w-12 text-muted" />
        <h3 className="mt-2 text-sm font-medium">暂无任务</h3>
        <p className="mt-1 text-sm text-muted">创建一个新任务开始吧。</p>
        <Button className="mt-4" onClick={onCreateTask}>创建任务</Button>
      </div>
    );
  }

  return <ul role="list">...</ul>;
}
```

## 响应式设计

先设计移动端，再扩展：

```tsx
// Tailwind：移动优先响应式
<div className="
  grid grid-cols-1      /* 移动端：单列 */
  sm:grid-cols-2        /* 小屏：2 列 */
  lg:grid-cols-3        /* 大屏：3 列 */
  gap-4
">
```

在以下断点测试：320px、768px、1024px、1440px。

## 加载与过渡

```tsx
// 骨架屏加载（内容不使用加载轮）
function TaskListSkeleton() {
  return (
    <div className="space-y-3" aria-busy="true" aria-label="正在加载任务">
      {Array.from({ length: 3 }).map((_, i) => (
        <div key={i} className="h-12 bg-muted animate-pulse rounded" />
      ))}
    </div>
  );
}

// 乐观更新以获得感知速度
function useToggleTask() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: toggleTask,
    onMutate: async (taskId) => {
      await queryClient.cancelQueries({ queryKey: ['tasks'] });
      const previous = queryClient.getQueryData(['tasks']);

      queryClient.setQueryData(['tasks'], (old: Task[]) =>
        old.map(t => t.id === taskId ? { ...t, done: !t.done } : t)
      );

      return { previous };
    },
    onError: (_err, _taskId, context) => {
      queryClient.setQueryData(['tasks'], context?.previous);
    },
  });
}
```

## 参见

详细的无障碍要求和测试工具，参见 `references/accessibility-checklist.md`。

## 常见合理化借口

| 合理化借口 | 现实 |
|---|---|
| "无障碍是锦上添花" | 在许多司法管辖区这是法律要求，也是工程质量标准。 |
| "我们后面再做响应式" | 事后改造响应式设计比从一开始就做好难 3 倍。 |
| "设计还没定，先跳过样式" | 使用设计系统的默认值。无样式的 UI 给审查者带来糟糕的第一印象。 |
| "这只是一个原型" | 原型会变成生产代码。把基础做好。 |
| "AI 审美感暂时可以接受" | 它传递了低质量的信号。从一开始就使用项目的实际设计系统。 |

## 红旗

- 组件超过 200 行（拆分它们）
- 内联样式或随意的像素值
- 缺少错误状态、加载状态或空状态
- 未做键盘导航测试
- 仅用颜色作为状态的唯一指示器（无文字或图标的红/绿）
- 通用的 "AI 外观"（紫色渐变、过大的卡片、模板化布局）

## 验证

构建 UI 之后：

- [ ] 组件渲染没有控制台错误
- [ ] 所有可交互元素可通过键盘访问（用 Tab 遍历页面）
- [ ] 屏幕阅读器可以传达页面内容和结构
- [ ] 响应式：在 320px、768px、1024px、1440px 下正常工作
- [ ] 加载、错误和空状态全部处理
- [ ] 遵循项目的设计系统（间距、颜色、字体）
- [ ] 开发工具或 axe-core 中没有无障碍警告
