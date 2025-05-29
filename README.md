# 🌀 Godot Async Task Framework

An asynchronous coroutine management system for Godot 4 using GDScript. It enables structured execution, cancellation, and synchronization of async functions, keeping task references and results in order.

---

## 📦 Components

### ✅ `AsyncTask`

A container for running one async operation:

- `await task.wait()` — wait for result
- `task.cancel()` — cancel execution
- `task.wait_async(callback)` — non-blocking callback on result
- `task.on_cancel(callback)` — receive notification on cancel

### 🔁 `TaskScope`

A node-scoped task manager:

- `launch_task(callable, args)` — starts and tracks an async task
- `cancel_all_tasks()` — cancels all active tasks
- `cancel_latest_task(key)` — cancels the most recent task by function name
- `get_all_tasks(key)` — gets all tasks by name

Intended to be added as a `Node` to the scene tree.

### 🔗 `MultiWaiter`

Groups multiple `AsyncTask`s and waits for all to complete in order:

- `add_task(task)` — adds a task and stores result index
- `await wait_all()` — waits until all tasks complete
- `tasks_ready` — signal with all results
- `cancel_all()` — cancels all tasks in progress
- `reset()` — resets internal state

---

## 🚀 Example

```gdscript
var scope := TaskScope.new()
add_child(scope)

var task1 = scope.launch_task(my_func, ["Task A", 1])
var task2 = scope.launch_task(my_func, ["Task B", 2])

var waiter := MultiWaiter.create(self)
waiter.add_task(task1)
waiter.add_task(task2)

waiter.tasks_ready.connect(func(results):
    print("Results:", results)
)
```

---

## 🧪 Tests

Included tests (via [GUT](https://github.com/bitwes/Gut)):

- ✅ Preserves result order
- ✅ Partial and full task cancellation
- ✅ Async callback usage
- ✅ State reset correctness

---

## 📁 Project Layout

```
res://addons/async_tasks/
├── async_task.gd
├── task_scope.gd
├── multi_waiter.gd
└── tests/
    └── test_multi_waiter.gd
```

---

## 🛠 Setup

1. Copy the contents of `addons/async_tasks/` into your Godot project.
2. Add `TaskScope` to any node that should manage async execution.
3. Use `MultiWaiter` to coordinate async results in batch.

---

## 🔖 License

MIT — free for personal and commercial use.
