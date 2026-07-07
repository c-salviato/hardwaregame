extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogica.tscn")

const SPRITE_IDLE_UP = preload("res://assets/sprites/cenas/level01/NPCs/velho/velho_idle_up.png")
const SPRITE_WALK_UP_1 = preload("res://assets/sprites/cenas/level01/NPCs/velho/velho_walk_up_01.png")
const SPRITE_WALK_UP_2 = preload("res://assets/sprites/cenas/level01/NPCs/velho/velho_walk_up_02.png")
const SPRITE_IDLE_RIGHT = preload("res://assets/sprites/cenas/level01/NPCs/velho/velho_idle_right.png")

@onready var hud: CanvasLayer = $HUD
@onready var sprite: Sprite2D = $VelhoIdleRight

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
var dialogo_ativo: Node = null
var esta_atravessando := false
var atravessou_com_sucesso := false
var tempo_animacao := 0.0
var walk_speed := 10.0
var target_y := 75.0 # Posição do outro lado da calçada (global)

@onready var collision_body: StaticBody2D = $StaticBody2D

var thanks_dialog = {
	0:{
		"faceset": "res://icon.svg",
		"dialog": "Muito obrigado por me ajudar a atravessar!",
		"title": "Senhor"
	},
	1:{
		"faceset": "res://icon.svg",
		"dialog": "Como agradecimento, tome esta Placa Mãe para o seu computador.",
		"title": "Senhor"
	},
	2:{
		"faceset": "res://icon.svg",
		"dialog": "Boa sorte na sua jornada!",
		"title": "Senhor"
	}
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if esta_atravessando:
		_process_walk(delta)
		return

	if !player_perto:
		return

	if dialogo_ativo != null:
		return

	if Input.is_action_just_pressed("interagir"):
		if atravessou_com_sucesso:
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
	Global.tem_placa_mae = true
	Global.pecas_coletadas += 1
	# Volta para o lobby
	get_tree().change_scene_to_file("res://Fases/FaseInicial.tscn")

func _process_walk(delta: float) -> void:
	tempo_animacao += delta
	
	# Movimento para cima
	global_position.y -= walk_speed * delta
	
	# Alternância de animação (0.2s por frame)
	if int(tempo_animacao * 6) % 2 == 0:
		sprite.texture = SPRITE_WALK_UP_1
	else:
		sprite.texture = SPRITE_WALK_UP_2
		
	# Chegou ao destino?
	if global_position.y <= target_y:
		global_position.y = target_y
		esta_atravessando = false
		atravessou_com_sucesso = true
		sprite.texture = SPRITE_IDLE_RIGHT
		# Reativa colisão no destino para permitir interação
		if collision_body:
			collision_body.process_mode = Node.PROCESS_MODE_INHERIT

func _on_dialog_finished() -> void:
	dialogo_ativo = null
	# Inicia o minigame após o diálogo inicial
	var minigame: Control = MINIGAME_LOGICA.instantiate()
	minigame.finished.connect(_on_minigame_finished)
	hud.add_child(minigame)

func _on_minigame_finished(success: bool) -> void:
	if success:
		# Notifica o TrafficManager e remove a barreira
		var level: Node2D = get_tree().current_scene
		if level.has_node("TrafficManager"):
			level.get_node("TrafficManager").stop_spawning()
		if level.has_node("CrosswalkBarrier"):
			level.get_node("CrosswalkBarrier").queue_free()

	var result_dialog = win_dialog if success else lose_dialog
	
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = result_dialog
	
	dialogo_ativo.tree_exited.connect(func():
		dialogo_ativo = null
		if success:
			_iniciar_travessia()
	)
	
	hud.add_child(dialogo_ativo)

func _iniciar_travessia() -> void:
	# Desativa colisão para não prender o player ou ser empurrado
	if collision_body:
		collision_body.process_mode = Node.PROCESS_MODE_DISABLED
		
	sprite.texture = SPRITE_IDLE_UP
	# Pequeno delay de 1 segundo antes de começar a andar para mostrar o idle_up
	await get_tree().create_timer(1.0).timeout
	esta_atravessando = true
	tempo_animacao = 0.0

func _on_body_entered(body):
	if body.name == "Player":
		player_perto = true

func _on_body_exited(body):
	if body.name == "Player":
		player_perto = false
