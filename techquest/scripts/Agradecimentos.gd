extends Control
class_name Agradecimentos

func _ready() -> void:
	Global.stop_music()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interagir"):
		get_tree().quit()
