extends CharacterBody2D

const VEL = 40.0

@onready var anim = $Animacao

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("andar_esq", "andar_dir", "andar_cima", "andar_baixo")
	velocity = direction * VEL

	if direction.x > 0:
		anim.play("andar_dir")
	elif direction.x < 0:
		anim.play("andar_esq")
	elif direction.y < 0:
		anim.play("andar_cima")
	elif direction.y > 0:
		anim.play("andar_baixo")
	else:
		anim.stop()

	move_and_slide()
