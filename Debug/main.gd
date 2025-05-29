extends Node2D

@onready var scope := TaskScope.create(self)


func _ready() -> void:

	var task1 := scope.launch_task(long_task,["task1",2])
	var task2 := scope.launch_task(long_task, ["task1",10])
	
	print("_ready finihed")
	var result1 = await task1.wait(scope)
	print("Got result:", result1)
	task1 = null
	var result2 = await task2.wait(scope, 55)
	if result2 == 55:
		get_tree().change_scene_to_file("res://Debug/new_scene.tscn")
	print("Got result2:", result2)
	
	
	
	
func add_delayed(a: int, b: int) -> int:
	await get_tree().create_timer(2).timeout
	return a + b

	
func test_long_task(message: String, delay: float) -> String:
	return await suspend_func(
		func():
		for i in range(delay, 0, -1):
			print(message," Wait:", i)
			await get_tree().create_timer(1).timeout
			if i == 5:
				scope.cancel_latest_task(long_task.get_method())
				return "cancel"
		return message + "_done"
	)
	
func long_task(message: String, delay: float) -> String:
	for i in range(delay, 0, -1):
		print(message," Wait:", i)
		await get_tree().create_timer(1).timeout
		if i == 5:
			scope.cancel_latest_task(long_task.get_method())
			return "cancel"
			
	return message + "_done"
	

func suspend_func(callable: Callable, args: Array = []) -> Variant:
	var result = await callable.callv(args)
	return result
