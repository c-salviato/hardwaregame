extends Node2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogica.tscn")

const PORTRAIT_TECNICO_NORMAL = "res://assets/sprites/cenas/level03/NPCs/tecnico/tecnico_normal.png"
const PORTRAIT_TECNICO_FELIZ = "res://assets/sprites/cenas/level03/NPCs/tecnico/tecnico_feliz.png"
const SPRITE_GOLEIRO_DEITADO = "res://assets/sprites/cenas/level03/NPCs/goleiro/goleiro_deitado_32x32.png"

@onready var tecnico: Area2D = $Gol/tecnico
@onready var goleiro_sprite: Sprite2D = $Gol/goleiro/goleiroSprite
@onready var bola: Area2D = $Gol/bola
@onready var area_penalti: Area2D = $Gol/area_do_penalti
@onready var player: CharacterBody2D = $Gol/Player
@onready var player_anim: AnimatedSprite2D = $Gol/Player/Animacao

var hud: CanvasLayer
var penalty_highlight: ColorRect
var logic_choice: String = ""
var dialog_done: bool = false
var player_near_tecnico: bool = false
var player_in_penalty: bool = false

var initial_dialog = {
	0: {
		"faceset": PORTRAIT_TECNICO_NORMAL,
		"dialog": "Escuta aqui, jogador! Não temos muito tempo. Você precisa bater esse pênalti AGORA!",
		"title": "Técnico"
	},
	1: {
		"faceset": PORTRAIT_TECNICO_NORMAL,
		"dialog": "Mas preste atenção: ou você chuta, ou você bate de cabeça. Os dois ao mesmo tempo não dá!",
		"title": "Técnico"
	},
	2: {
		"faceset": PORTRAIT_TECNICO_NORMAL,
		"dialog": "Agora vá para a marca do pênalti e decida o que vai fazer.",
		"title": "Técnico"
	}
}

var win_dialog = {
	0: {
		"faceset": PORTRAIT_TECNICO_FELIZ,
		"dialog": "Boa! Você me escutou e tomou a decisão certa. Belo gol!",
		"title": "Técnico"
	},
	1: {
		"faceset": PORTRAIT_TECNICO_FELIZ,
		"dialog": "Como prometido, aqui está a próxima peça para o seu computador: a memória RAM!",
		"title": "Técnico"
	}
}

var player_fail_dialog = {
	0: {
		"faceset": "res://assets/sprites/player/player_portraits/player_normal.png",
		"dialog": "AAAAH EU SABIA QUE CHUTAR E BATER DE CABEÇA NÃO IA DAR CERTO!",
		"title": "Jogador"
	}
}

func _ready() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	
	penalty_highlight = ColorRect.new()
	penalty_highlight.color = Color(1, 0, 0, 0.3)
	area_penalti.add_child(penalty_highlight)
	penalty_highlight.hide()
	
	# Garante que as máscaras de colisão estão corretas
	# O Player deve estar na layer 1 para ser detectado
	tecnico.collision_layer = 0
	tecnico.collision_mask = 1
	area_penalti.collision_layer = 0
	area_penalti.collision_mask = 1
	
	tecnico.body_entered.connect(_on_tecnico_body_entered)
	tecnico.body_exited.connect(_on_tecnico_body_exited)
	area_penalti.body_entered.connect(_on_penalty_area_entered)
	area_penalti.body_exited.connect(_on_penalty_area_exited)
	
	print("Level 3 Controller Ready. Tecnico Mask: ", tecnico.collision_mask)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interagir"):
		# Fallback de distância se os sinais falharem
		var dist = player.global_position.distance_to(tecnico.global_position)
		print("Interagir! Distância ao técnico: ", dist, " Near flag: ", player_near_tecnico)
		
		if (player_near_tecnico or dist < 80.0) and not dialog_done:
			_start_dialog(initial_dialog, _after_initial_dialog)
		elif player_in_penalty and logic_choice == "OU":
			area_penalti.set_deferred("monitoring", false)
			_perform_penalty_success()

func _start_dialog(data: Dictionary, callback: Callable) -> void:
	if get_tree().paused: return
	var ds = DIALOG_SCREEN.instantiate()
	ds.data = data
	ds.tree_exited.connect(callback)
	hud.add_child(ds)

func _after_initial_dialog() -> void:
	dialog_done = true
	var shape = area_penalti.get_node("CollisionShape2D").shape
	if shape is RectangleShape2D:
		penalty_highlight.size = shape.size
		penalty_highlight.position = -shape.size / 2
	penalty_highlight.show()

func _on_tecnico_body_entered(body: Node2D) -> void:
	print("Corpo entrou no técnico: ", body.name)
	if body.is_in_group("player") or body == player:
		player_near_tecnico = true

func _on_tecnico_body_exited(body: Node2D) -> void:
	print("Corpo saiu do técnico: ", body.name)
	if body.is_in_group("player") or body == player:
		player_near_tecnico = false

func _on_penalty_area_entered(body: Node2D) -> void:
	print("Corpo entrou na área: ", body.name)
	if body.is_in_group("player") or body == player:
		player_in_penalty = true
		if penalty_highlight.visible:
			penalty_highlight.hide()
			# Usa a variável de configuração
			bola.position = POS_BOLA_NO_TECNICO
			_open_logic_minigame()

func _on_penalty_area_exited(body: Node2D) -> void:
	print("Corpo saiu da área: ", body.name)
	if body.is_in_group("player") or body == player:
		player_in_penalty = false

func _open_logic_minigame() -> void:
	var minigame = MINIGAME_LOGICA.instantiate()
	minigame.question_text = "Bater o pênalti: Chutar ___ Cabecear"
	minigame.correct_value = "OU"
	
	var options = minigame.get_node("Options")
	options.get_node("Verdadeiro").text = "E"
	options.get_node("Verdadeiro").value = "E"
	options.get_node("Falso").text = "OU"
	options.get_node("Falso").value = "OU"
	
	minigame.finished.connect(_on_minigame_finished)
	hud.add_child(minigame)

func _on_minigame_finished(success: bool) -> void:
	if success:
		logic_choice = "OU"
	else:
		logic_choice = "E"
		_perform_penalty_fail()

# CONFIGURAÇÕES DE POSIÇÃO (Ajuste aqui conforme necessário)
# -----------------------------------------------------------------
# Posições locais relativas ao nó "Gol"
var POS_BOLA_NO_TECNICO: Vector2 = Vector2(-82, 58) # Onde a bola nasce
var POS_GOL_FINAL: Vector2 = Vector2(0, -80)        # Centro do gol no cenário (mais alto)

# Offsets (deslocamentos) em relação à posição do jogador
var OFFSET_CABECA: Vector2 = Vector2(-6, 76)        # Altura da cabeça
var OFFSET_PE: Vector2 = Vector2(-6, 80)             # Altura do pé
var ALTURA_ARCO_LANÇAMENTO: float = 50.0            # Quão alto a bola sobe no lançamento
# -----------------------------------------------------------------

func _perform_penalty_success() -> void:
	var is_head: bool = randf() < 0.5
	
	# 1. Primeiro Tween: Lançamento do Técnico para o Jogador
	var tween_to_player: Tween = create_tween()
	
	bola.position = POS_BOLA_NO_TECNICO
	
	var contact_point: Vector2 = player.position
	if is_head:
		contact_point += OFFSET_CABECA
	else:
		contact_point += OFFSET_PE
	
	var mid_point: Vector2 = (bola.position + contact_point) / 2
	mid_point.y -= ALTURA_ARCO_LANÇAMENTO
	
	# Animação de ida
	tween_to_player.tween_property(bola, "position:x", contact_point.x, 0.6).set_trans(Tween.TRANS_SINE)
	tween_to_player.parallel().tween_property(bola, "position:y", mid_point.y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_to_player.chain().tween_property(bola, "position:y", contact_point.y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Quando chegar no jogador, inicia o segundo movimento
	tween_to_player.finished.connect(func() -> void:
		# FORÇAMOS A POSIÇÃO para que não haja descendência residual
		bola.position = contact_point
		
		# 2. Segundo Tween: Chute DIRETO para o Gol
		var tween_to_goal: Tween = create_tween()
		
		# Feedback visual
		goleiro_sprite.texture = load(SPRITE_GOLEIRO_DEITADO)
		var impact_tween: Tween = create_tween()
		impact_tween.tween_property(bola, "scale", Vector2(1.2, 1.2), 0.05)
		impact_tween.chain().tween_property(bola, "scale", Vector2(1.0, 1.0), 0.05)
		
		var ball_goal_target: Vector2 = POS_GOL_FINAL + Vector2(randf_range(-30, 30), 0)
		
		# USAMOS TRANS_LINEAR PARA O CHUTE SER DIRETO PARA CIMA
		tween_to_goal.tween_property(bola, "position", ball_goal_target, 0.4).set_trans(Tween.TRANS_LINEAR)
		tween_to_goal.finished.connect(_on_goal_scored)
	)

func _on_goal_scored() -> void:
	_start_dialog(win_dialog, _finish_level)

func _finish_level() -> void:
	var g: Node = get_node("/root/Global")
	g.pecas_coletadas += 1
	g.carregar_fase("res://Fases/FaseInicial.tscn")

func _perform_penalty_fail() -> void:
	player.rotation_degrees = 90
	player.set_physics_process(false)
	
	var tween: Tween = create_tween()
	bola.position = tecnico.position
	
	var fail_target: Vector2 = player.position + Vector2(20, 10)
	var mid_point: Vector2 = (bola.position + fail_target) / 2
	mid_point.y -= 30
	
	tween.tween_property(bola, "position:x", fail_target.x, 0.5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(bola, "position:y", mid_point.y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(bola, "position:y", fail_target.y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween.finished
	_start_dialog(player_fail_dialog, _restart_level)

func _restart_level() -> void:
	get_tree().reload_current_scene()
