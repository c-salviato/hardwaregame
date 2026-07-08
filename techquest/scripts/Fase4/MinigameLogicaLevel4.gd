extends Control
class_name MinigameLogicaLevel4

signal finished(result: String)

@onready var slot1: TargetSlot = %slot1
@onready var slot2: TargetSlot = %slot2
@onready var feedback_label: Label = $Feedback

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	feedback_label.hide()
	slot1.item_dropped.connect(_on_item_dropped)
	slot2.item_dropped.connect(_on_item_dropped)
	# Toca som de pop-up abrindo
	Global.play_pop_up_abrindo()
	# Pausa o jogo enquanto o pop-up estiver aberto
	get_tree().paused = true

func _on_item_dropped(_value: String) -> void:
	if slot1.current_value != "" and slot2.current_value != "":
		feedback_label.show()

func _exit_tree() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interagir"):
		if slot1.current_value == "" or slot2.current_value == "":
			return

		var result: String
		if slot1.current_value == "E" and slot2.current_value == "Falso":
			result = "success"
		elif slot1.current_value == "OU" and slot2.current_value == "Falso":
			result = "partial"
		else:
			result = "failure"

		finished.emit(result)
		queue_free()
