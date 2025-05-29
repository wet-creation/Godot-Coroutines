
extends "res://addons/gut/test.gd"
class_name TaskScopeTest

var task_scope := preload("res://Task/task_scope.gd")
var async_task := preload("res://Task/async_task.gd")



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
	var result = await task.wait(self)
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
	var result = await task.wait(scope)
	assert_null(result)
	
# ✅ Проверка запуска нескольких задач с одним callable
func test_multiple_tasks_same_callable():
	var key := self.simple_task.get_method()
	var task1 := scope.launch_task(self.simple_task, ["A", 1])
	var task2 := scope.launch_task(self.simple_task, ["B", 1])

	assert_true(task1 != task2, "Tasks must be different instances")
	assert_eq(scope.get_task_count(key), 2, "Two tasks should be registered under same key")

	var result1 = await task1.wait(self)
	var result2 = await task2.wait(self)

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

# Вспомогательные задачи
func simple_task(name: String, delay: float) -> String:
	await get_tree().create_timer(delay).timeout
	return name + "_done"

func delayed_task(delay: float) -> String:
	await get_tree().create_timer(delay).timeout
	return "delayed"
