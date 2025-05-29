extends GutTest

@onready var root := get_tree().root
var scope : TaskScope 

func before_each():
	scope = TaskScope.create(root)
	
func after_each():
	scope.free_scope()

func simulate_task(name: String, delay: float) -> AsyncTask:
	var task := AsyncTask.new(null)
	task.start(scope, func():
		await get_tree().create_timer(delay).timeout
		return name + "_done"
	)
	return task

func test_tasks_return_in_order():
	var task1 = simulate_task("A", 0.1)
	var task2 = simulate_task("B", 0.05)

	var waiter := MultiWaiter.create(root)
	var result := await waiter.wait_all([task1, task2])
	assert_eq(result[0], "A_done")
	assert_eq(result[1], "B_done")
	waiter.queue_free()

func test_cancellation_prevents_emit():
	var task1 = simulate_task("X", 0.2)
	var task2 = simulate_task("Y", 0.2)

	var waiter := MultiWaiter.create(root)
	waiter.add_task(task1)
	waiter.add_task(task2)
	
	waiter.cancel_all()

	await get_tree().create_timer(0.3).timeout
	assert_true(waiter._cancelled)
	assert_eq(waiter._results.size(), 0)
	waiter.queue_free()

func test_reset_clears_state():
	var task1 = simulate_task("P", 0.05)
	var task2 = simulate_task("Q", 0.05)

	var waiter := MultiWaiter.create(root)
	waiter.add_task(task1)
	waiter.add_task(task2)
	waiter.reset()

	assert_eq(waiter._tasks.size(), 0)
	assert_eq(waiter._results.size(), 0)
	assert_eq(waiter._pending, 0)
	waiter.queue_free()
	
func test_partial_cancel_behavior():
	var task1 = simulate_task("Short", 0.1)
	var task2 = simulate_task("Long", 1.0)

	var waiter := MultiWaiter.create(root)
	waiter.add_task(task1)
	waiter.add_task(task2)

	task2.cancel()  # cancel only one task

	await get_tree().create_timer(0.2).timeout
	assert_eq(waiter._results[0], "Short_done")
	assert_eq(waiter._results[1], null)
	waiter.queue_free()

func test_async_callback_result_collection():
	var task1 = simulate_task("Async1", 0.05)
	var task2 = simulate_task("Async2", 0.1)

	var waiter := MultiWaiter.create(root)
	var results := SharedValue.new([])

	waiter.tasks_ready.connect(func(values):
		results.value = values
	)
	
	waiter.add_task(task1)
	waiter.add_task(task2)

	await get_tree().create_timer(1).timeout
	assert_eq(results.value[0], "Async1_done")
	assert_eq(results.value[1], "Async2_done")
	waiter.queue_free()
