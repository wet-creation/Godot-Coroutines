# 🌀 Godot-Coroutines

A small coroutine management framework for Godot 4.x written in GDScript. It provides structured handling of asynchronous operations through awaitable tasks, safe cancellation, task scoping, and batch coordination — all with automatic memory cleanup.

---

## 🚀 Key Features

- 🔄 `AsyncTask`: A coroutine container that supports cancellation and result delivery
- 🧠 `DeferredResult`: A lightweight promise-like wrapper used internally by `AsyncTask`
- 📦 `TaskScope`: Launch and manage tasks within a scene-based scope
- 🧩 `MultiWaiter`: Collect results from multiple async tasks in declared order
- 🔔 `SharedValue`: Emits a signal whenever a value is updated
- 📋 `TaskLogger`: Optional logging utility for lifecycle tracking

---

## 📘 Components Overview

### ✅ `AsyncTask`

A self-contained task handler that executes a coroutine via `callv`.

**Main Features:**

- `wait()` – await task result synchronously
- `wait_async(callback)` – use callback instead of await
- `cancel()` – stops execution and emits `_on_cancel`
- `on_cancel(callback)` – subscribe to cancellation
- Automatically calls `TaskLogger` hooks if enabled

### 🔁 `DeferredResult`

Used internally by `AsyncTask`, provides a small promise-like interface for awaiting or reacting to results.

- `set_result(value)`
- `await_result(default)`
- `on_result(callback, default)`

### 🔂 `TaskScope`

A scene node for managing active tasks. Useful for launching and auto-cancelling tasks when scenes change or nodes are freed.

```gdscript
var scope := TaskScope.create(self)
var task := scope.launch_task(my_func, ["arg"], "default")
```

- `launch_task(callable, args, default_value)`
- `cancel_all_tasks()`
- `cancel_latest_task(key)`
- `get_all_tasks(key)`

### 🧩 `MultiWaiter`

Handles multiple async tasks and emits a single signal when all complete. Ensures the order of results matches the order tasks were added.

```gdscript
var waiter = MultiWaiter.create(self)
waiter.add_task(task1)
waiter.add_task(task2)
waiter.tasks_ready.connect(func(results): print(results))
```

Or use `await wait_all(tasks)` to get results directly.

### 📢 `SharedValue`

A `RefCounted` wrapper around a value that emits `value_changed(value)` when updated.

```gdscript
var shared = SharedValue.new(42)
shared.value_changed.connect(func(v): print("New value:", v))
shared.value = 100
```

### 📝 `TaskLogger`

Hook-based logger that outputs lifecycle events to the console:

- `on_created`
- `on_started`
- `on_completed`
- `on_cancelled`
- `on_freed`

---

## 📁 Project Structure

```
res://addons/async_tasks/
├── async_task.gd
├── deferred_result.gd
├── multi_waiter.gd
├── shared_value.gd
├── task_logger.gd
└── task_scope.gd
```

---

## 🛠 Installation

1. Copy all `.gd` files to `res://addons/async_tasks/` in your project
2. Use `TaskScope` to launch and track async tasks
3. Use `MultiWaiter` when awaiting multiple tasks
4. Optionally enable `TaskLogger` to trace behavior

---

## 🔖 License

MIT License — free for personal and commercial projects.
