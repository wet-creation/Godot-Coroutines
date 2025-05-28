
extends "res://addons/gut/test.gd"
class_name TaskScopeTest

var task_scope := preload("res://Task/task_scope.gd")
var async_task := preload("res://Task/async_task.gd")



var scope: TaskScope

func before_each():
	scope = task_scope.new()
	add_child(scope)

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

# Вспомогательные задачи
func simple_task(name: String, delay: float) -> String:
	await get_tree().create_timer(delay).timeout
	return name + "_done"

func delayed_task(delay: float) -> String:
	await get_tree().create_timer(delay).timeout
	return "delayed"
