
extends "res://addons/gut/test.gd"
class_name TaskScopeTest

var task_scope := preload("res://Task/TaskScope.gd")
var async_task := preload("res://Task/AsynkTask.gd")



var scope: TaskScope

func before_each():
	scope = task_scope.create(self)

func after_each():
	if scope:
		scope.cancel_all_tasks()
		scope.queue_free()

# ✅ Проверка успешного выполнения задачи
func test_successful_task():
	var task := scope.launch_task_named("simple", self.simple_task, ["test", 1])
	var result = await task.wait()
	assert_eq(result, "test_done")
	assert_true(task.done)
	assert_false(task.is_cancelled())

# ✅ Проверка отмены задачи
func test_cancel_task():
	var task := scope.launch_task_named("cancel_test", self.delayed_task, [2])
	scope.cancel_all_tasks_with_key("cancel_test")
	await get_tree().create_timer(2.5).timeout  # дождёмся потенциального выполнения
	assert_true(task.is_cancelled())
	assert_false(task.done)


# ✅ Проверка wait() при удалённом хосте
func test_wait_safe_with_dead_host():
	var task := scope.launch_task_named("dead", self.delayed_task, [2])
	scope.queue_free()  # удаляем scope
	var result = await task.wait()
	assert_null(result)
	
# ✅ Проверка запуска нескольких задач с одним callable
func test_multiple_tasks_same_callable():
	var key := self.simple_task.get_method()
	var task1 := scope.launch_task(self.simple_task, ["A", 1])
	var task2 := scope.launch_task(self.simple_task, ["B", 1])

	assert_true(task1 != task2, "Tasks must be different instances")
	assert_eq(scope.get_task_count(key), 2, "Two tasks should be registered under same key")

	var result1 = await task1.wait()
	var result2 = await task2.wait()

	assert_eq(result1, "A_done")
	assert_eq(result2, "B_done")
	assert_eq(scope.get_task_count(key), 0, "All tasks should auto-remove after completion")

# ✅ Проверка отмены одной из нескольких задач
func test_cancel_one_of_multiple_tasks():
	var key := self.simple_task.get_method()
	var task1 := scope.launch_task(self.simple_task, ["A", 2])
	var task2 := scope.launch_task(self.simple_task, ["B", 2])

	task1.cancel()

	await get_tree().create_timer(2.5).timeout

	assert_true(task1.is_cancelled(), "Task1 should be cancelled")
	assert_false(task1.done, "Task1 should not be done")
	assert_true(task2.done, "Task2 should complete normally")
	assert_eq(scope.get_task_count(key), 0, "Both tasks should be removed")

# ✅ Проверка полной отмены задач по ключу
func test_cancel_all_by_callable_key():
	var key := self.simple_task.get_method()
	scope.launch_task(self.simple_task, ["X", 2])
	scope.launch_task(self.simple_task, ["Y", 2])

	scope.cancel_all_tasks_with_key(key)
	
	await get_tree().create_timer(2.5).timeout

	assert_eq(scope.get_task_count(key), 0, "All tasks should be cancelled and removed")

func test_wait_async_invokes_callback():
	var task := scope.launch_task(simple_task, ["async", 1])
	var result = SharedValue.new()
	task.wait_async(
		func(res):
			result.value = res
	)
	await get_tree().create_timer(1.2).timeout
	assert_eq(result.value, "async_done")
	
func test_wait_returns_default_when_host_invalid():
	var task := scope.launch_task(simple_task, ["ghost", 1])
	scope.queue_free()  # инвалидируем host (scope)
	var result = await task.wait("default_val")
	assert_eq(result, "default_val")

func test_cancel_latest_task_works():
	var key := simple_task.get_method()
	scope.launch_task_named(key, simple_task, ["t1", 2])
	scope.launch_task_named(key, simple_task, ["t2", 2])
	scope.cancel_latest_task(key)
	await get_tree().create_timer(1.5).timeout
	assert_eq(scope.get_task_count(key), 1)

func test_free_scope_cancels_all_and_removes_node():
	var key := simple_task.get_method()
	scope.launch_task_named(key, simple_task, ["a", 2])
	scope.launch_task_named(key, simple_task, ["b", 2])
	scope.free_scope()
	await get_tree().create_timer(0.5).timeout
	assert_false(is_instance_valid(scope))

func test_on_cancel_callback_is_called():
	var task := scope.launch_task(simple_task, ["cancel_me", 0.1])
	var is_canceled = SharedValue.new(false)
	
	task.cancel()
	task.on_cancel(
		func(): 
			print("After Canceling...")
			is_canceled.value = true
	)
	await get_tree().create_timer(1.5).timeout
	assert_true(is_canceled.value)

func test_on_cancel_callback_not_called_if_not_cancelled():
	var task := scope.launch_task(simple_task, ["no_cancel", 1])
	var cancel_called := SharedValue.new(false)
	
	task.on_cancel(func(): cancel_called.value = true)
	var res = await task.wait()
	
	assert_false(cancel_called.value)
	assert_eq(res,"no_cancel_done")

func test_on_cancel_and_wait_async_together():
	var task := scope.launch_task(simple_task, ["combo", 1])
	var cancel_called := SharedValue.new(false)
	var async_result = SharedValue.new()
	
	task.on_cancel(func(): cancel_called.value = true)
	task.wait_async(func(res): 
		print(res)
		async_result.value = res
		, "was_cancelled")
	
	task.cancel()
	await get_tree().create_timer(2).timeout
	
	assert_true(cancel_called.value, "on_cancel was not called")
	assert_eq(async_result.value, "was_cancelled")


# Вспомогательные задачи
func simple_task(name: String, delay: float) -> String:
	await get_tree().create_timer(delay).timeout
	print(name, "_done")
	return name + "_done"

func delayed_task(delay: float) -> String:
	await get_tree().create_timer(delay).timeout
	return "delayed"
