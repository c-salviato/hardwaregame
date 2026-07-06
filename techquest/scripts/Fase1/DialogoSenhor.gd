extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogica.tscn")

@onready var hud = $HUD
#precisa mudar pro dialogo certo
var dialog_data = {
	0:{
		"faceset": "res://icon.svg",
		"dialog": "Olá, pequeno herói!",
		"title": "Senhor"
	},
	1:{
		"faceset": "res://icon.svg",
		"dialog": "Eu preciso atravessar a rua",
		"title": "Senhor"
	},
	2:{
		"faceset": "res://icon.svg",
		"dialog": "mas estou com medo desses carros.",
		"title": "Senhor"
	},
	3:{
		"faceset": "res://icon.svg",
		"dialog": "Você pode me ajudar?",
		"title": "Senhor"
	},
}

var win_dialog = {
	0:{
		"faceset": "res://icon.svg",
		"dialog": "Parabéns! Você acertou. Realmente não há carros passando agora.",
		"title": "Senhor"
	}
}

var lose_dialog = {
	0:{
		"faceset": "res://icon.svg",
		"dialog": "Ops, acho que você se enganou no conector lógico. Tente novamente!",
		"title": "Senhor"
	}
}

var player_perto := false
var dialogo_ativo = null

func _ready():
	#casos de teste no terminal pra testar caso de erro
	print("VO:", self)
	print("Senhor parent:", get_parent())
	print("HUD:", hud)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if !player_perto:
		return

	if dialogo_ativo != null:
		return

	if Input.is_action_just_pressed("interagir"):
		dialogo_ativo = DIALOG_SCREEN.instantiate()
		dialogo_ativo.data = dialog_data

		dialogo_ativo.tree_exited.connect(_on_dialog_finished)

		hud.add_child(dialogo_ativo)

func _on_dialog_finished():
	dialogo_ativo = null
	# Inicia o minigame após o diálogo inicial
	var minigame = MINIGAME_LOGICA.instantiate()
	minigame.finished.connect(_on_minigame_finished)
	hud.add_child(minigame)

func _on_minigame_finished(success: bool):
	if success:
		# Notifica o TrafficManager e remove a barreira
		var level = get_tree().current_scene
		if level.has_node("TrafficManager"):
			level.get_node("TrafficManager").stop_spawning()
		if level.has_node("CrosswalkBarrier"):
			level.get_node("CrosswalkBarrier").queue_free()

	var result_dialog = win_dialog if success else lose_dialog
	
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = result_dialog
	
	dialogo_ativo.tree_exited.connect(func():
		dialogo_ativo = null
	)
	
	hud.add_child(dialogo_ativo)

func _on_body_entered(body):
	if body.name == "Player":
		player_perto = true

func _on_body_exited(body):
	if body.name == "Player":
		player_perto = false
