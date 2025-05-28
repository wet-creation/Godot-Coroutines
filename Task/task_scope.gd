
class_name TaskScope
extends Node

var active_tasks: Dictionary = {}

func launch_task_named(key: String, callable: Callable, args: Array = []) -> AsyncTask:
	var task := AsyncTask.new()
	if not active_tasks.has(key):
		active_tasks[key] = []
	active_tasks[key].append(task)

	task.start(callable, args)

	task._signal.connect(func():
		if active_tasks.has(key):
			active_tasks[key].erase(task)
			if active_tasks[key].is_empty():
				active_tasks.erase(key)
	)
	return task
	
	
func launch_task(callable: Callable, args: Array = []) -> AsyncTask:
	var task := AsyncTask.new()
	var key = callable.get_method()
	if not active_tasks.has(key):
		active_tasks[key] = []
	active_tasks[key].append(task)

	task.start(callable, args)

	task._signal.connect(func():
		active_tasks[key].erase(task)
		if active_tasks[key].is_empty():
			active_tasks.erase(key)
	)
	return task


func cancel_all_tasks_with_key(key: String):
	if active_tasks.has(key):
		for task in active_tasks[key]:
			task.cancel()
		active_tasks.erase(key)


func cancel_all_tasks():
	for tasks in active_tasks.values():
		for task in tasks:
			task.cancel()
	active_tasks.clear()
	
	
func cancel_latest_task(key: String):
	
	active_tasks[key].back().cancel()
	active_tasks[key].erase(active_tasks[key].back())
	 


func get_all_tasks(key: String) -> Array[AsyncTask]:
	return active_tasks.get(key, [])



func _exit_tree():
	cancel_all_tasks()
