extends Node2D
class_name TrafficManager

@export var car_scene: PackedScene = preload("res://Fases/Car.tscn")
@export var spawn_interval: float = 1.2

var is_spawning: bool = true
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
	_timer.start()

func stop_spawning() -> void:
	is_spawning = false
	_timer.stop()

func _on_timeout() -> void:
	if not is_spawning:
		return
	
	_spawn_car(false)
	_spawn_car(true)

func _spawn_car(from_left: bool) -> void:
	var car = car_scene.instantiate()
	add_child(car)
	
	if from_left:
		# Bottom Lane (Left to Right)
		car.position = Vector2(-50, 135)
		car.setup(Vector2.RIGHT, 100.0, true)
	else:
		# Top Lane (Right to Left)
		car.position = Vector2(300, 110)
		car.setup(Vector2.LEFT, 100.0, false)
