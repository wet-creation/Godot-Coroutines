class_name MultiWaiter
extends Node

## Emits when all added tasks finish.
signal tasks_ready(values: Array)

## Internal task state
var _pending := 0
var _results: Array          =  []
var _cancelled               := false
var _tasks: Array[AsyncTask] =  []

func _init() -> void:
	_results = []
	_tasks = []

static func create(owner: Node) -> MultiWaiter:
	var waiter = MultiWaiter.new()
	owner.add_child(waiter)
	return waiter

## Add an AsyncTask. Result will appear in same order as tasks were added.
func add_task(task: AsyncTask):
	if _cancelled:
		return
	var index := _results.size()
	_results.append(null) # reserve slot
	_pending += 1
	_tasks.append(task)

	task.wait_async(func(res):
		if _cancelled:
			return
		_results[index] = res
		_pending -= 1
		if _pending == 0:
			tasks_ready.emit(_results)
	)

## Cancel all tasks and prevent ready signal from being emitted
func cancel_all():
	_cancelled = true
	for task in _tasks:
		if not task.is_cancelled():
			task.cancel()
	_tasks.clear()
	_results.clear()
	_pending = 0

func reset():
	_cancelled = false
	_results.clear()
	_tasks.clear()
	_pending = 0

## Static utility to wait for all tasks, returns array of results in order
func wait_all(tasks: Array[AsyncTask] = []) -> Array:
	if !tasks.is_empty():
		for task in tasks:
			add_task(task)
	var result := await _wait_ready()
	return result

func _wait_ready() -> Array:
	await tasks_ready
	return _results
