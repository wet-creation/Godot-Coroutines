extends Node2D

var scope := TaskScope.new()


func _ready() -> void:
	var task1 := scope.launch_task(long_task,["task1",2])
	var task2 := scope.launch_task(long_task,["task2",10])
	
	print("_ready finihed")
	var result1 = await task1.wait(self)
	print("Got result:", result1)
	var result2 = await task2.wait(self)
	print("Got result:", result2)
	
	
	
	
func add_delayed(a: int, b: int) -> int:
	await get_tree().create_timer(2).timeout
	return a + b

	
func long_task(message: String, delay: float) -> String:
	for i in range(delay, 0, -1):
		print(message," Wait:", i)
		await get_tree().create_timer(1).timeout
		if i == 5:
			scope.cancel_latest_task(long_task.get_method())
			get_tree().change_scene_to_file("res://Debug/new_scene.tscn")
			return ""
			
	return message + "_done"

func suspend_func(callable: Callable, args: Array = []) -> Variant:
	var result = await callable.callv(args)
	return result
