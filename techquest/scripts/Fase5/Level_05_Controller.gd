extends Node2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogicaLevel5.tscn")

const PORTRAIT_TRABALHADOR = "res://assets/sprites/cenas/level05/NPCs/trabalhador_48x48.png"
const PORTRAIT_TRABALHADOR_FELIZ = "res://assets/sprites/cenas/level05/NPCs/trabalhador_feliz_48x48.png"
const PORTRAIT_GAROTO = "res://assets/sprites/player/player_portraits/player_normal.png"
const SPRITE_CAMIONETE_GRANDE = "res://assets/sprites/cenas/level05/objetos_de_cena/camionete_grande.png"
const SPRITE_CAMIONETE_DIFERENTE = "res://assets/sprites/cenas/level05/objetos_de_cena/camionete_diferente.png"
const SPRITE_CAMIONETE_PEQUENA = "res://assets/sprites/cenas/level05/objetos_de_cena/camionete_pequena.png"

@onready var trabalhador: Area2D = $CenarioMinerios/trabalhador
@onready var camionete: Area2D = $CenarioMinerios/camionete
@onready var camionete_sprite: Sprite2D = $CenarioMinerios/camionete/Sprite2D
@onready var ouro1: Area2D = $CenarioMinerios/ouro1
@onready var ouro2: Area2D = $CenarioMinerios/ouro2
@onready var player: CharacterBody2D = $Player

var hud: CanvasLayer
var player_perto_trabalhador: bool = false
var player_perto_camionete: bool = false
var player_perto_ouro: bool = false
var dialogo_inicial_feito: bool = false
var minigame_completo: bool = false
var dialogo_ativo: Node = null

# ─── Diálogo Inicial (Trabalhador reclamando) ─────────────────────────────────

var dialog_data: Dictionary = {
	0: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Oi, muleque! O patrão botou eu pra catar esses minerais tudo, mas a camionete é pequena demais!",
		"title": "Trabalhador"
	},
	1: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Num vai cabê tudo aqui não, e a cidade é longe pra caramba, num dá pra ficá indo e vortando toda hora.",
		"title": "Trabalhador"
	},
	2: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Tô sem ideia do que fazê... Cê num tem uma ideia não, muleque? O que cê faria com a camionete?",
		"title": "Trabalhador"
	}
}

# ─── Diálogo de Vitória (MAIOR ✅) ────────────────────────────────────────────

var success_dialog: Dictionary = {
	0: {
		"faceset": PORTRAIT_TRABALHADOR_FELIZ,
		"dialog": "UAI! Mió de mais da conta! Uma mega camionete! Agora cabe tudo e mais um pouco!",
		"title": "Trabalhador"
	},
	1: {
		"faceset": PORTRAIT_TRABALHADOR_FELIZ,
		"dialog": "Vô te falá, cê é bão mermo hein! Resolveu meu problemão!",
		"title": "Trabalhador"
	},
	2: {
		"faceset": PORTRAIT_TRABALHADOR_FELIZ,
		"dialog": "Toma aqui, achei esse trem perto dos minerais. Parece uma peça de computador: uma Fonte de Alimentação!",
		"title": "Trabalhador"
	}
}

# ─── Diálogo: IGUAL ───────────────────────────────────────────────────────────

var dialog_igual: Dictionary = {
	0: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Uai, cê não fez nada! A camionete tá do mesmo jeito!",
		"title": "Trabalhador"
	},
	1: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Eu preciso que ela fique MAIOR, muleque! MAIOR! Num é igual não!",
		"title": "Trabalhador"
	}
}

# ─── Diálogo: DIFERENTE ───────────────────────────────────────────────────────

var dialog_diferente: Dictionary = {
	0: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Oxente! Até que ficou bonitinha assim, mas num ficou maior!",
		"title": "Trabalhador"
	},
	1: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Continua do mesmo tamanho. Num adianta de nada! Tem que sê MAIOR!",
		"title": "Trabalhador"
	}
}

# ─── Diálogo: MENOR ───────────────────────────────────────────────────────────

var dialog_menor: Dictionary = {
	0: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Pô, muleque! Ao invés de ficá maior, ela ficou menor ainda!",
		"title": "Trabalhador"
	},
	1: {
		"faceset": PORTRAIT_TRABALHADOR,
		"dialog": "Você transformou minha camionete em uma camionete de brinquedo! Precisa sê MAIOR, não MENOR!",
		"title": "Trabalhador"
	}
}

# ─── Diálogo do Ouro ────────────────────────────────────────────────

var dialog_ouro: Dictionary = {
	0: {
		"faceset": PORTRAIT_GAROTO,
		"dialog": "Isso parece valioso...",
		"title": "Garoto"
	}
}


func _ready() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	# Configura detecção de colisão
	trabalhador.collision_layer = 0
	trabalhador.collision_mask = 1

	ouro1.collision_layer = 0
	ouro1.collision_mask = 1
	ouro2.collision_layer = 0
	ouro2.collision_mask = 1

	trabalhador.body_entered.connect(_on_trabalhador_body_entered)
	trabalhador.body_exited.connect(_on_trabalhador_body_exited)
	camionete.body_entered.connect(_on_camionete_body_entered)
	camionete.body_exited.connect(_on_camionete_body_exited)
	ouro1.body_entered.connect(_on_ouro_body_entered)
	ouro1.body_exited.connect(_on_ouro_body_exited)
	ouro2.body_entered.connect(_on_ouro_body_entered)
	ouro2.body_exited.connect(_on_ouro_body_exited)

	# Camionete começa sem interação (só após o diálogo inicial)
	camionete.set_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interagir"):
		if dialogo_ativo != null:
			return

		if player_perto_ouro:
			_iniciar_dialogo_ouro()
		elif player_perto_trabalhador and not dialogo_inicial_feito:
			_iniciar_dialogo_inicial()
		elif player_perto_camionete and dialogo_inicial_feito and not minigame_completo:
			_abrir_minigame()
		elif player_perto_trabalhador and minigame_completo:
			_iniciar_dialogo_vitoria()


# ─── Diálogo Inicial ──────────────────────────────────────────────────────────

func _iniciar_dialogo_inicial() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dialog_data
	dialogo_ativo.tree_exited.connect(_on_dialogo_inicial_finalizado)
	hud.add_child(dialogo_ativo)


func _on_dialogo_inicial_finalizado() -> void:
	dialogo_ativo = null
	dialogo_inicial_feito = true
	# Agora habilita interação com a camionete
	camionete.set_process(true)


# ─── Minigame ─────────────────────────────────────────────────────────────────

func _abrir_minigame() -> void:
	var minigame: Control = MINIGAME_LOGICA.instantiate()
	minigame.finished.connect(_on_minigame_finalizado)
	hud.add_child(minigame)


func _on_minigame_finalizado(conector: String) -> void:
	await get_tree().process_frame

	match conector:
		"MAIOR":
			_transformar_camionete(SPRITE_CAMIONETE_GRANDE)
			minigame_completo = true
			_iniciar_dialogo_vitoria()
		"IGUAL":
			# Sprite permanece o mesmo
			_iniciar_dialogo_e_reiniciar(dialog_igual)
		"DIFERENTE":
			_transformar_camionete(SPRITE_CAMIONETE_DIFERENTE)
			_iniciar_dialogo_e_reiniciar(dialog_diferente)
		"MENOR":
			_transformar_camionete(SPRITE_CAMIONETE_PEQUENA)
			_iniciar_dialogo_e_reiniciar(dialog_menor)


func _transformar_camionete(sprite_path: String) -> void:
	camionete_sprite.texture = load(sprite_path)


# ─── Diálogo Vitória (MAIOR) ──────────────────────────────────────────────────

func _iniciar_dialogo_vitoria() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = success_dialog
	dialogo_ativo.tree_exited.connect(_on_dialogo_vitoria_finalizado)
	hud.add_child(dialogo_ativo)


func _on_dialogo_vitoria_finalizado() -> void:
	dialogo_ativo = null
	_finalizar_fase()


# ─── Diálogo de erro + reinício ───────────────────────────────────────────────

func _iniciar_dialogo_e_reiniciar(dialog: Dictionary) -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dialog
	dialogo_ativo.tree_exited.connect(_reiniciar_fase)
	hud.add_child(dialogo_ativo)


func _reiniciar_fase() -> void:
	dialogo_ativo = null
	get_tree().reload_current_scene()


# ─── Finalizar Fase (MAIOR) ───────────────────────────────────────────────────

func _finalizar_fase() -> void:
	Global.tem_placa_de_video = true
	Global.pecas_coletadas += 1
	Global.carregar_fase("res://Fases/FaseInicial.tscn")


# ─── Sinais de Colisão ────────────────────────────────────────────────────────

func _on_trabalhador_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto_trabalhador = true


func _on_trabalhador_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto_trabalhador = false


func _on_camionete_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto_camionete = true


func _on_camionete_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto_camionete = false


# ─── Ouro ────────────────────────────────────────────────────────────

func _iniciar_dialogo_ouro() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dialog_ouro
	dialogo_ativo.tree_exited.connect(_on_dialogo_ouro_finalizado)
	hud.add_child(dialogo_ativo)


func _on_dialogo_ouro_finalizado() -> void:
	dialogo_ativo = null


func _on_ouro_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto_ouro = true


func _on_ouro_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto_ouro = false
