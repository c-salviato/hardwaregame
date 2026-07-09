extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")

@onready var hud = $HUD

# --- Variável para receber o Portal ---
@export var portal_da_fase: Area2D
# --------------------------------------------------

# ─── Diálogo final (PC 100% montado) ────────────────────────────────────────────
var dialog_final = {
	0:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "Filho, você conseguiu! O computador está completo e funcionando com todas as peças!",
		"title": "Pai"
	},
	1:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "A Placa Mãe é a base que conecta todas as outras peças do computador.",
		"title": "Pai"
	},
	2:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "O Processador é o cérebro, executando todos os cálculos e instruções.",
		"title": "Pai"
	},
	3:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "A Memória RAM guarda dados temporários para acesso rápido.",
		"title": "Pai"
	},
	4:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "O Disco Rígido (HD) armazena tudo de forma permanente.",
		"title": "Pai"
	},
	5:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "A Fonte de Alimentação fornece energia para tudo funcionar.",
		"title": "Pai"
	},
	6:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "E a Placa de Vídeo é responsável por mostrar as imagens na tela.",
		"title": "Pai"
	},
	7:{
		"faceset": "res://assets/sprites/player/player_portraits/player_feliz.png",
		"dialog": "Muito obrigado, papai! Gostei muito de aprender sobre computadores e lógica de programação nas minhas aventuras!",
		"title": "Filho"
	}
}
# ────────────────────────────────────────────────────────────────────────────────

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
		"dialog": "Preciso da sua ajuda para conseguir todas as peças",
		"title": "Pai"
	},
	11:{
		"faceset": "res://assets/sprites/cenas/lobby/NPCs/pai_portraits.png",
		"dialog": "vai precisar ajudar pessoas e resolver problemas de lógica para montar o computador.",
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
		
		# --- PC 100% montado: diálogo final com recapitulação ---
		if Global.pecas_colocadas == 6:
			dialogo_ativo = DIALOG_SCREEN.instantiate()
			dialogo_ativo.data = dialog_final
			dialogo_ativo.process_mode = Node.PROCESS_MODE_ALWAYS

			dialogo_ativo.tree_exited.connect(func():
				dialogo_ativo = null
				get_tree().paused = false
				# Vai para a tela de agradecimentos
				Global.carregar_fase("res://Fases/Agradecimentos.tscn")
			)

			hud.add_child(dialogo_ativo)
			get_tree().paused = true
			return
		# ---------------------------------------------------------------------------------

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
