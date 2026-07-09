extends Node2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogicaLevel4.tscn")

const PORTRAIT_ZELADOR = "res://assets/sprites/cenas/level04/NPCs/zelador/portrait_zelador.png"
const SPRITE_VASO = "res://assets/sprites/cenas/level04/objetos_de_cena/sprite_vaso.png"
const SPRITE_PIA = "res://assets/sprites/cenas/level04/objetos_de_cena/sprite_pia.png"

@onready var zelador: Area2D = $BanheiroLevel04/zelador
@onready var vaso_sprite: Sprite2D = $BanheiroLevel04/vaso/sprite
@onready var pia_sprite: Sprite2D = $BanheiroLevel04/pia/sprite
@onready var player: CharacterBody2D = $Player

var hud: CanvasLayer
var player_perto: bool = false
var banheiro_consertado: bool = false

var dialog_data: Dictionary = {
	0: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Ô, moço(a)! Aconteceu uma coisa horrível!",
		"title": "Zelador"
	},
	1: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Umas pessoas mal-intencionadas invadiram o banheiro e quebraram tudo! O vaso sanitário e a pia estão destruídos...",
		"title": "Zelador"
	},
	2: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Eu não sei consertar e nem tenho dinheiro pra chamar um encanador. Será que você pode me ajudar com a lógica?",
		"title": "Zelador"
	}
}

var success_dialog: Dictionary = {
	0: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Nossa! Você conseguiu consertar tudo! Muito obrigado mesmo!",
		"title": "Zelador"
	},
	1: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Eu achei esta peça aqui no banheiro, parece ser de computador. Tome, você merece!",
		"title": "Zelador"
	},
	2: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "É um HD! Agora vai poder completar seu computador!",
		"title": "Zelador"
	}
}

var partial_dialog: Dictionary = {
	0: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Parece que deu certo pela metade...",
		"title": "Zelador"
	}
}

var failure_dialog: Dictionary = {
	0: {
		"faceset": PORTRAIT_ZELADOR,
		"dialog": "Parece que algo não deu certo...",
		"title": "Zelador"
	}
}

func _ready() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	zelador.body_entered.connect(_on_zelador_body_entered)
	zelador.body_exited.connect(_on_zelador_body_exited)

func _process(_delta: float) -> void:
	if not player_perto:
		return

	if get_tree().paused:
		return

	if Input.is_action_just_pressed("interagir"):
		if banheiro_consertado:
			_iniciar_dialogo_agradecimento()
		else:
			_iniciar_dialogo_inicial()

func _iniciar_dialogo_inicial() -> void:
	var ds = DIALOG_SCREEN.instantiate()
	ds.data = dialog_data
	ds.tree_exited.connect(_on_initial_dialog_finished)
	hud.add_child(ds)

func _on_initial_dialog_finished() -> void:
	_open_minigame()

func _open_minigame() -> void:
	var minigame: Control = MINIGAME_LOGICA.instantiate()
	minigame.finished.connect(_on_minigame_finished)
	hud.add_child(minigame)

func _on_minigame_finished(result: String) -> void:
	# Aguarda um frame para garantir que o minigame foi completamente removido da árvore
	# antes de mostrar o diálogo de resultado. Isso evita que o _exit_tree() do minigame
	# (que chama get_tree().paused = false) sobrescreva o pause do diálogo.
	await get_tree().process_frame

	match result:
		"success":
			_consertar_tudo()
			_start_dialog(success_dialog, _finish_level)
		"partial":
			_consertar_parcial()
			_start_dialog(partial_dialog, func():
				pass
			)
		"failure":
			_start_dialog(failure_dialog, _restart_level)

func _consertar_tudo() -> void:
	vaso_sprite.texture = load(SPRITE_VASO)
	pia_sprite.texture = load(SPRITE_PIA)
	banheiro_consertado = true

func _consertar_parcial() -> void:
	var rng: int = randi() % 2
	if rng == 0:
		vaso_sprite.texture = load(SPRITE_VASO)
	else:
		pia_sprite.texture = load(SPRITE_PIA)

func _start_dialog(data: Dictionary, callback: Callable) -> void:
	var ds = DIALOG_SCREEN.instantiate()
	ds.data = data
	ds.tree_exited.connect(callback)
	hud.add_child(ds)

func _iniciar_dialogo_agradecimento() -> void:
	_start_dialog(success_dialog, _finish_level)

func _finish_level() -> void:
	if not Global.peca_coletada[3]:
		Global.peca_coletada[3] = true
		Global.tem_hd = true
		Global.pecas_coletadas += 1
		Global.nivel_desbloqueado = max(Global.nivel_desbloqueado, 5)
		Global.salvar_jogo()
	Global.carregar_fase("res://Fases/FaseInicial.tscn")

func _restart_level() -> void:
	get_tree().reload_current_scene()

func _on_zelador_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true

func _on_zelador_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
