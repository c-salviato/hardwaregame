extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")


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
