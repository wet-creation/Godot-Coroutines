class_name TaskScope
extends Node

var active_tasks: Dictionary = {}


static func create(owner: Node) -> TaskScope:
	var scope = TaskScope.new()
	owner.add_child(scope)
	return scope

func launch_task_named(key: String, callable: Callable, args: Array = [], default_value: Variant = null) -> AsyncTask:
	var task: AsyncTask = AsyncTask.new(default_value)
	if not active_tasks.has(key):
		active_tasks[key] = []
	active_tasks[key].append(task)

	task.start(self, callable, args)
	task._on_finish.connect(
		func():
			if active_tasks.has(key):
				active_tasks[key].erase(task)
				if active_tasks[key].is_empty():
					active_tasks.erase(key)
		
	)
	return task


func launch_task(callable: Callable, args: Array = [], default_value: Variant = null) -> AsyncTask:
	var key := callable.get_method()
	return launch_task_named(key, callable, args, default_value)


func cancel_all_tasks_with_key(key: String):
	if active_tasks.has(key):
		for task in active_tasks[key]:
			task.cancel()
		


func cancel_all_tasks():
	for tasks in active_tasks.values():
		for task in tasks:
			task.cancel()
	active_tasks.clear()
	print(active_tasks)


func cancel_latest_task(key: String):
	active_tasks[key].back().cancel()


func get_task_count(key: String) -> int:
	if active_tasks.has(key):
		return active_tasks[key].size()
	return 0

	
func is_task_running(task: AsyncTask) -> bool:
	for tasks in active_tasks.values():
		if task in tasks:
			return true
	return false


func get_all_tasks(key: String) -> Array[AsyncTask]:
	return active_tasks.get(key, [])


func free_scope():
	cancel_all_tasks()
	queue_free()


	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print(" Scope deleted ")
	
func _exit_tree():
	cancel_all_tasks()
