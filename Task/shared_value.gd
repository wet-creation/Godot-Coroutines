class_name SharedValue
extends RefCounted

signal value_changed(value)

var value: Variant:
	set(val):
		value = val
		value_changed.emit(val)

func _init(val: Variant = null):
	value = val
