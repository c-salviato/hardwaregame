extends Control
class_name MinigameLogica

signal finished(result: bool)

@onready var slot: TargetSlot = %TargetSlot
@onready var feedback_label: Label = $Feedback
@onready var question_label: Label = $Card/HBoxContainer/Label

var correct_value: String = "Falso"
var question_text: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	feedback_label.hide()
	slot.item_dropped.connect(_on_item_dropped)
	if question_text != "":
		question_label.text = question_text
	# Toca som de pop-up abrindo
	Global.play_pop_up_abrindo()
	# Pausa o jogo enquanto o pop-up estiver aberto
	get_tree().paused = true

func _on_item_dropped(_value: String) -> void:
	feedback_label.show()

func _exit_tree() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interagir"):
		if slot.current_value == "":
			return
			
		var is_correct: bool = slot.current_value == correct_value
		finished.emit(is_correct)
		queue_free()
