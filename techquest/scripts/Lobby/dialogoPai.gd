extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")

@onready var hud = $HUD

# --- Variável para receber o Portal ---
@export var portal_da_fase: Area2D
# --------------------------------------------------

var dialog_data = {
	0:{
		"faceset": "res://assets/sprites/player/player_portraits/player_normal.png",
		"dialog": "Papai, o que é isso?",
		"title": "Filho"
	},
	1:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "Isso é um gabinete, filho.",
		"title": "Pai"
	},
	2:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "É aqui que ficam as peças do computador",
		"title": "Pai"
	},
	3:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "Cada peça tem uma função importante.",
		"title": "Pai"
	},
	4:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "Algumas ajudam o computador a funcionar",
		"title": "Pai"
	},
	5:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "já outras guardam informações",
		"title": "Pai"
	},
	6:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "e algumas fazem as imagens aparecerem na tela.",
		"title": "Pai"
	},
	7:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "Quando todas estão juntas, o computador funciona",
		"title": "Pai"
	},
	8:{
		"faceset": "res://assets/sprites/player/player_portraits/player_surpreso.png",
		"dialog": "Uau! Isso é muito legal.",
		"title": "Filho"
	},
	9:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "É sim! Mas ainda faltam algumas peças.",
		"title": "Pai"
	},
	10:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "Preciso da sua ajuda para resolver mistérios",
		"title": "Pai"
	},
	11:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "e encontrá-las para montar o computador.",
		"title": "Pai"
	},
	12:{
		"faceset": "res://assets/sprites/player/player_portraits/player_feliz.png",
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
		
		# --- Bloqueia o diálogo se já conversou antes E o PC não está pronto ---
		if Global.dialogo_pai_feito and Global.pecas_colocadas < 6:
			return # Sai da função aqui mesmo e ignora o botão de interagir
		# ---------------------------------------------------------------------------------

		dialogo_ativo = DIALOG_SCREEN.instantiate()
		dialogo_ativo.data = dialog_data
		dialogo_ativo.process_mode = Node.PROCESS_MODE_ALWAYS

		dialogo_ativo.tree_exited.connect(func():
			dialogo_ativo = null
			get_tree().paused = false
			
			# --- Salva no Global que o primeiro diálogo foi feito ---
			Global.dialogo_pai_feito = true
			# --------------------------------------------------------------------
			
			if portal_da_fase:
				portal_da_fase.ativar_portal()
		)

		hud.add_child(dialogo_ativo)
		get_tree().paused = true

func _on_body_entered(body):
	if body.name == "Player":
		player_perto = true

func _on_body_exited(body):
	if body.name == "Player":
		player_perto = false
