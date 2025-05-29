extends Node2D

@onready var scope := TaskScope.create(self)
@onready var waiter := MultiWaiter.create(self)

var valueFromTask: SharedValue = SharedValue.new()
func _ready() -> void:
	print("_ready scope launch")
	var task1   := scope.launch_task(long_task, ["task1", 4], "canceled")
	var task2   := scope.launch_task(long_task, ["task2", 3])
	waiter.add_task(task1)
	waiter.add_task(task2)
	#task1.wait_async(
	#func(result): 
		#print("Result from async task1:", result)
	#)

	#waiter.tasks_ready.connect(
		#func(array: Array):
			#var tas1Res = array[0]
			#var tas2Res = array[1]
			#valueFromTask.value = tas2Res
			#print("_ready finihed ", tas1Res)
			#print("_ready finihed ", tas2Res)
			#get_tree().change_scene_to_file("res://Debug/new_scene.tscn")
	#)
	task1.cancel()
	var array =  await waiter.wait_all()
	var tas1Res = array[0]
	var tas2Res = array[1]
	print("_ready finihed ", tas1Res)
	print("_ready finihed ", tas2Res)
	get_tree().change_scene_to_file("res://Debug/new_scene.tscn")
	
	#
	#task2.wait_async(
	#func(result): 
		#print("Result from async task2:", result)
		#get_tree().change_scene_to_file("res://Debug/new_scene.tscn")
	#)
	#task1.on_cancel(func(): print("hello"))
	#await get_tree().create_timer(2).timeout
	#task1.cancel()
	#var tas1Res = await task1.wait()
	#var tas2Res = await task2.wait()
	#
	#
	#print("_ready finihed ", tas1Res)
	#print("_ready finihed ", tas2Res)

func while_long_task(message: String, delay: float):
	var time = 0
	while (true):
		await get_tree().create_timer(1).timeout
		time+=1
		print(message, ":", time)


func long_task(message: String, delay: float) -> String:
	for i in range(delay, 0, -1):
		print(message, " Wait:", i)
		await get_tree().create_timer(1).timeout
		#if i == 2 && !scope.active_tasks.is_empty():
			#scope.cancel_latest_task(long_task.get_method())
			#return "cancel"

	return message + "_done"


func suspend_func(callable: Callable, args: Array = []) -> Variant:
	var result = await callable.callv(args)
	return result
