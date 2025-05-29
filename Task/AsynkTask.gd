class_name AsyncTask
extends RefCounted

signal _on_finish
signal _on_cancel

var result: Variant
var done := false
var deferred := DeferredResult.new()

var _cancelled := false
var _default_value: Variant = null
var _host: Object = Object.new()
var _on_cancel_callbacks: Array[Callable] = []

func _init(default_value = null) -> void:
	_default_value = default_value
	TaskLogger.on_created(self, get_reference_count())


func start(host: Object, task_func: Callable, args: Array = []):
	_host = host
	call_deferred("_run", task_func, args)


func _run(task_func: Callable, args: Array):
	TaskLogger.on_started(self, get_reference_count())
	if _cancelled:
		deferred.set_result(null)
		return

	result = await task_func.callv(args)

	if _cancelled:
		deferred.set_result(null)
		return
	
	done = true
	_on_finish.emit()
	deferred.set_result(result)
	TaskLogger.on_completed(self, get_reference_count())


func wait() -> Variant:
	return await deferred.await_result(_default_value)


func wait_async(callback: Callable):
	deferred.on_result(callback, _default_value)


func is_cancelled() -> bool:
	return _cancelled

func on_cancel(callback: Callable):
	if _cancelled:
		callback.call()
	else:
		_on_cancel_callbacks.append(callback)

func cancel():
	if done:
		return
	_cancelled = true
	for callback in _on_cancel_callbacks:
		callback.call()
	_on_finish.emit()
	TaskLogger.on_cancelled(self, get_reference_count())


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		TaskLogger.on_freed(self)

		
		
