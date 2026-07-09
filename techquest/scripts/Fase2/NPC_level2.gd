extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogica.tscn")

const PORTRAIT_TRISTE = "res://assets/sprites/cenas/level02/NPCs/portraits/criancinha_triste.png"
const PORTRAIT_NORMAL = "res://assets/sprites/cenas/level02/NPCs/portraits/criancinha_normal.png"
const PORTRAIT_FELIZ = "res://assets/sprites/cenas/level02/NPCs/portraits/criancinha_feliz.png"

@onready var hud: CanvasLayer = CanvasLayer.new() # Vou criar um CanvasLayer programaticamente se não houver um no Level

var dialog_data = {
	0:{
		"faceset": PORTRAIT_TRISTE,
		"dialog": "Buaaaaa! Por favor, me ajude!",
		"title": "Criança"
	},
	1:{
		"faceset": PORTRAIT_TRISTE,
		"dialog": "Meu gatinho subiu na árvore e não consegue descer.",
		"title": "Criança"
	},
	2:{
		"faceset": PORTRAIT_NORMAL,
		"dialog": "Você pode ajudar ele a ficar seguro?",
		"title": "Criança"
	}
}

var win_dialog = {
	0:{
		"faceset": PORTRAIT_FELIZ,
		"dialog": "Olha! O gatinho está seguro agora!",
		"title": "Criança"
	}
}

var lose_dialog = {
	0:{
		"faceset": PORTRAIT_TRISTE,
		"dialog": "Acho que isso não ajudou muito... Pode tentar de novo?",
		"title": "Criança"
	}
}

var thanks_dialog = {
	0:{
		"faceset": PORTRAIT_FELIZ,
		"dialog": "Muito obrigada por salvar meu gatinho!",
		"title": "Criança"
	},
	1:{
		"faceset": PORTRAIT_NORMAL,
		"dialog": "Tome isto, eu achei perto da árvore.",
		"title": "Criança"
	},
	2:{
		"faceset": PORTRAIT_NORMAL,
		"dialog": "Parece uma peça de computador: um Processador!",
		"title": "Criança"
	}
}

var player_perto := false
var dialogo_ativo: Node = null
var gato_salvo := false

func _ready() -> void:
	add_child(hud)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if !player_perto:
		return

	if dialogo_ativo != null:
		return

	if Input.is_action_just_pressed("interagir"):
		if gato_salvo:
			_iniciar_dialogo_agradecimento()
		else:
			_iniciar_dialogo_inicial()

func _iniciar_dialogo_inicial() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dialog_data
	dialogo_ativo.tree_exited.connect(_on_dialog_finished)
	hud.add_child(dialogo_ativo)

func _iniciar_dialogo_agradecimento() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = thanks_dialog
	dialogo_ativo.tree_exited.connect(_on_thanks_finished)
	hud.add_child(dialogo_ativo)

func _on_thanks_finished() -> void:
	dialogo_ativo = null
	if not Global.peca_coletada[1]:
		Global.peca_coletada[1] = true
		Global.tem_processador = true
		Global.pecas_coletadas += 1
		Global.nivel_desbloqueado = max(Global.nivel_desbloqueado, 3)
		Global.salvar_jogo()
	Global.carregar_fase("res://Fases/FaseInicial.tscn")

func _on_dialog_finished() -> void:
	dialogo_ativo = null
	# Abre o minigame
	var minigame: Control = MINIGAME_LOGICA.instantiate()
	minigame.correct_value = "Verdadeiro"
	minigame.question_text = "O gato está seguro"
	minigame.finished.connect(_on_minigame_finished)
	hud.add_child(minigame)

func _on_minigame_finished(success: bool) -> void:
	if success:
		_salvar_gato()
		
	var result_dialog = win_dialog if success else lose_dialog
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = result_dialog
	dialogo_ativo.tree_exited.connect(func():
		dialogo_ativo = null
	)
	hud.add_child(dialogo_ativo)

func _salvar_gato() -> void:
	gato_salvo = true
	var gato = get_tree().current_scene.get_node_or_null("Gato")
	if gato:
		# Teleporta o gato para o lado da criança
		gato.global_position = global_position + Vector2(-30, 0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
