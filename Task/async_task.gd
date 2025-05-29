class_name AsyncTask
extends RefCounted

var result: Variant
var done := false
signal _on_finish
var _cancelled := false


func start(task_func: Callable, args: Array = []):
	call_deferred("_run", task_func, args)
	TaskLogger.on_created(self, get_reference_count())

func _run(task_func: Callable, args: Array):
	TaskLogger.on_started(self, get_reference_count())
	if _cancelled:
		return
	result = await task_func.callv(args)
	if _cancelled:
		return
	done = true
	TaskLogger.on_completed(self, get_reference_count())
	
	_on_finish.emit()
	


## if host is cleared returns default_value
func wait(host: Object, default_value: Variant = null) -> Variant:
	if not is_instance_valid(host):
		return default_value
	await _on_finish
	if !done and _cancelled:
		return default_value
		
	if is_instance_valid(host):
		return result
	
	return default_value

func is_cancelled() -> bool:
	return _cancelled

func cancel():
	_cancelled = true
	_on_finish.emit()
	TaskLogger.on_cancelled(self, get_reference_count())

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		TaskLogger.on_freed(self)

		
		
