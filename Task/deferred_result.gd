class_name DeferredResult
extends RefCounted

var result: Variant = null
var done := false
signal _on_resolved

func set_result(value: Variant):
	if done:
		return
	result = value
	done = true
	_on_resolved.emit()

func await_result(default_value = null) -> Variant:
	if done:
		return result if result != null else default_value
	await _on_resolved
	return result if result != null else default_value

func on_result(callback: Callable, default_value = null):
	call_deferred("_internal_callback", callback, default_value)

func _internal_callback(callback: Callable, default_value: Variant):
	var res = await await_result(default_value)
	callback.call(res)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("DeferredResult", self, " cleared")
