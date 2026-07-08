extends CharacterBody2D

const VEL = 40.0

@onready var anim = $Animacao
@onready var global_audio: Node = get_node("/root/Global")

func _ready() -> void:
	# Atualiza música para a cena atual
	global_audio.apply_music_for_current_scene()

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("andar_esq", "andar_dir", "andar_cima", "andar_baixo")
	velocity = direction * VEL

	if direction.length() > 0:
		global_audio.play_walking_sound()
	else:
		global_audio.stop_walking_sound()

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
