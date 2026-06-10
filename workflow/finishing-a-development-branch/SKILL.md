---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# 收尾开发分支

## 概述

通过呈现清晰选项并处理所选工作流来指导开发工作的完成。

**核心原则：** 验证测试 → 检测环境 → 呈现选项 → 执行选择 → 清理。

**开始时声明：** "我正在使用 finishing-a-development-branch skill 来完成此工作。"

## 流程

### 步骤 1：验证测试

**呈现选项前，验证测试通过：**

```bash
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：** 停止。不能继续。
**如果测试通过：** 继续步骤 2。

### 步骤 2：检测环境

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

| 状态 | 菜单 | 清理 |
|------|------|------|
| `GIT_DIR == GIT_COMMON`（普通仓库） | 标准 4 选项 | 无 worktree 需清理 |
| `GIT_DIR != GIT_COMMON`，命名分支 | 标准 4 选项 | 基于来源 |
| `GIT_DIR != GIT_COMMON`，detached HEAD | 精简 3 选项（无 merge） | 无清理（外部管理） |

### 步骤 3：确定基分支

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

### 步骤 4：呈现选项

**普通仓库和命名分支 worktree——呈现这 4 个选项：**

```
实现完成。你想做什么？

1. 本地合并回 <base-branch>
2. 推送并创建 Pull Request
3. 保持分支原样（我后面处理）
4. 丢弃此工作

选哪个？
```

**Detached HEAD——呈现这 3 个选项：**

```
1. 推送为新分支并创建 Pull Request
2. 保持原样（我后面处理）
3. 丢弃此工作
```

### 步骤 5：执行选择

#### 选项 1：本地合并
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git checkout <base-branch>
git pull
git merge <feature-branch>
<test command>  # 在合并结果上验证测试
```
然后：清理 worktree（步骤 6），删除分支。

#### 选项 2：推送并创建 PR
```bash
git push -u origin <feature-branch>
gh pr create --title "<title>" --body "..."
```
不要清理 worktree——用户需要它来迭代 PR 反馈。

#### 选项 3：保持原样
报告并保留 worktree。

#### 选项 4：丢弃
先确认："这将永久删除分支、所有提交和 worktree。输入 'discard' 确认。"
确认后：清理 worktree，强制删除分支。

### 步骤 6：清理工作区

**仅对选项 1 和 4 运行。**

如果 worktree 路径在 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 下：Superpowers 创建了此 worktree——我们负责清理。
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune
```

否则，宿主环境拥有此工作区。不要移除它。

## 快速参考

| 选项 | Merge | Push | 保留 Worktree | 清理分支 |
|------|-------|------|---------------|----------|
| 1. 本地合并 | 是 | - | - | 是 |
| 2. 创建 PR | - | 是 | 是 | - |
| 3. 保持原样 | - | - | 是 | - |
| 4. 丢弃 | - | - | - | 是（强制） |

## 常见错误

**跳过测试验证** — 合并破坏性代码，创建失败的 PR。始终在提供选项前验证测试。

**清理选项 2 的 worktree** — 移除用户 PR 迭代需要的 worktree。仅对选项 1 和 4 清理。

**删除分支前未移除 worktree** — `git branch -d` 因 worktree 仍引用分支而失败。先 merge、移除 worktree、再删除分支。

**从 worktree 内部运行 git worktree remove** — 当 CWD 在被移除的 worktree 内时命令静默失败。始终先 `cd` 到主仓库根目录。

**清理 harness 拥有的 worktree** — 移除 harness 创建的 worktree 导致 phantom 状态。仅清理我们能识别来源的 worktree。

**丢弃无确认** — 意外删除工作。要求输入 "discard" 确认。

## 红旗

**永远不要：**
- 在测试失败时继续
- 不在结果上验证测试就合并
- 无确认就删除工作
- 无明确请求就强制推送
- 合并成功确认前移除 worktree
- 清理非你创建的 worktree
- 从 worktree 内部运行 `git worktree remove`

**始终要：**
- 提供选项前验证测试
- 呈现菜单前检测环境
- 呈现 4 个选项（或 detached HEAD 时 3 个）
- 选项 4 需要输入确认
- 仅对选项 1 和 4 清理 worktree
- worktree 移除前 `cd` 到主仓库根目录
- 移除后运行 `git worktree prune`
