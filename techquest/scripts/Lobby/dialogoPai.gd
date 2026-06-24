extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")


@onready var hud = $HUD

var dialog_data = {
	0:{
		"faceset": "res://icon.svg",
		"dialog": "Papai, o que é isso?",
		"title": "Filho"
	},
	1:{
		"faceset": "res://icon.svg",
		"dialog": "Isso é um gabinete, filho.",
		"title": "Pai"
	},
	2:{
		"faceset": "res://icon.svg",
		"dialog": "É aqui que ficam as peças do computador",
		"title": "Pai"
	},
	3:{
		"faceset": "res://icon.svg",
		"dialog": "Cada peça tem uma função importante.",
		"title": "Pai"
	},
	4:{
		"faceset": "res://icon.svg",
		"dialog": "Algumas ajudam o computador a funcionar",
		"title": "Pai"
	},
	5:{
		"faceset": "res://icon.svg",
		"dialog": "já outras guardam informações",
		"title": "Pai"
	},
	6:{
		"faceset": "res://icon.svg",
		"dialog": "e algumas fazem as imagens aparecerem na tela.",
		"title": "Pai"
	},
	7:{
		"faceset": "res://icon.svg",
		"dialog": "Quando todas estão juntas, o computador funciona",
		"title": "Pai"
	},
	8:{
		"faceset": "res://icon.svg",
		"dialog": "Uau! Isso é muito legal.",
		"title": "Filho"
	},
	9:{
		"faceset": "res://icon.svg",
		"dialog": "É sim! Mas ainda faltam algumas peças.",
		"title": "Pai"
	},
	10:{
		"faceset": "res://icon.svg",
		"dialog": "Preciso da sua ajuda para resolver mistérios",
		"title": "Pai"
	},
	11:{
		"faceset": "res://icon.svg",
		"dialog": "e encontrá-las para montar o computador.",
		"title": "Pai"
	},
	12:{
		"faceset": "res://icon.svg",
		"dialog": "Pode deixar comigo, papai!",
		"title": "Filho"
	}
}

var player_perto := false
var dialogo_ativo = null

func _ready():
	print("Pai:", self)
	print("Pai parent:", get_parent())
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
