extends Area2D
class_name Car

@export var speed: float = 80.0
var direction: Vector2 = Vector2.LEFT

func setup(dir: Vector2, spd: float, is_right_side: bool) -> void:
	direction = dir
	speed = spd
	z_index = 10 
	var anim: AnimatedSprite2D = $AnimatedSprite2D
	if is_right_side:
		anim.play("right")
	else:
		anim.play("left")

func _process(delta: float) -> void:
	position += direction * speed * delta
	z_index = 100 
	# print("Car pos=", position)
	
	# Despawn if out of bounds
	if position.x < -200 or position.x > 500:
		queue_free()
