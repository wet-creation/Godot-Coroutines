class_name TaskLogger
extends Node

## Вызывать при создании задачи
static func on_created(task: Object, ref_count: int = 0):
	print("🟢 Created task", task, " Ref count:", ref_count)


## Вызывать при запуске
static func on_started(task: Object, ref_count: int = 0):
	print("▶️ Started task", task, " Ref count:", ref_count)


## Вызывать при завершении
static func on_completed(task: Object, ref_count: int = 0):
	print("✅ Completed task", task, " Ref count:", ref_count)


## Вызывать при отмене
static func on_cancelled(task: Object, ref_count: int = 0):
	print("🛑 Cancelled task", task, " Ref count:", ref_count)


## Вызывается через _notification в задаче
static func on_freed(task: Object, ref_count: int = 0):
	print("🧹 Freed task", task, " Ref count:", ref_count)
