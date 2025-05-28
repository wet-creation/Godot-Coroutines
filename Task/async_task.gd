class_name AsyncTask
extends Object

var result: Variant
var done := false
signal _signal
var _cancelled := false

func start(task_func: Callable, args: Array = []):
	call_deferred("_run", task_func, args)

func _run(task_func: Callable, args: Array):
	if _cancelled:
		_signal.emit()
		return
	result = await task_func.callv(args)
	if _cancelled:
		_signal.emit()
		return
	done = true
	_signal.emit()

## if host is cleared returns null
func wait(host: Object) -> Variant:
	if not is_instance_valid(host):
		return null
	print("waiting...")
	await _signal
	print("done...")
	
	if is_instance_valid(host):
		return result
	return null

func is_cancelled() -> bool:
	return _cancelled

func cancel():
	_cancelled = true
