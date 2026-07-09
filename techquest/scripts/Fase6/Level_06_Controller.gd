extends Node2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")
const MINIGAME_LOGICA = preload("res://Fases/MinigameLogicaLevel6.tscn")

const PORTRAIT_PROFESSORA = "res://assets/sprites/cenas/level06/NPCs/professora_portrait.png"
const PORTRAIT_GAROTO = "res://assets/sprites/player/player_portraits/player_normal.png"

@onready var professora: Area2D = $CenarioSalaDeAula/Professora
@onready var player: CharacterBody2D = $CenarioSalaDeAula/Player

var hud: CanvasLayer
var player_perto: bool = false
var dialogo_inicial_feito: bool = false
var minigame_completo: bool = false
var dialogo_ativo: Node = null

# ─── Diálogo Inicial (Professora explicando o problema) ─────────────────────

var dialog_data: Dictionary = {
	0: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Olá, querido aluno! Que bom que você veio me visitar!",
		"title": "Professora"
	},
	1: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Estou preparando uma aula de lógica para meus alunos e quero montar uma frase bem legal para motivá-los.",
		"title": "Professora"
	},
	2: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "A frase é: 'O aluno que estuda _ faz os exercícios tira nota __ que a média, isso é __'",
		"title": "Professora"
	},
	3: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Mas estou com dificuldade para preencher os espaços com os conectores lógicos corretos!",
		"title": "Professora"
	},
	4: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Você pode me ajudar a escolher os conectores lógicos certos para completar a frase?",
		"title": "Professora"
	}
}

# ─── Diálogo de Vitória (Acertou ✅) ────────────────────────────────────────

var success_dialog: Dictionary = {
	0: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Parabéns! 'O aluno que estuda E faz os exercícios tira nota MAIOR que a média, isso é VERDADEIRO'!",
		"title": "Professora"
	},
	1: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Essa é uma ótima sugestão de frase! Meus alunos vão adorar!",
		"title": "Professora"
	},
	2: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Como agradecimento, encontrei esta peça perdida na sala. É uma Placa de Vídeo! Acho que vai ser útil para o seu computador.",
		"title": "Professora"
	}
}

# ─── Diálogo de Erro (Errou ❌) ─────────────────────────────────────────────

var failure_dialog: Dictionary = {
	0: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Hmm, essa combinação não parece formar uma frase muito boa para motivar os alunos...",
		"title": "Professora"
	},
	1: {
		"faceset": PORTRAIT_PROFESSORA,
		"dialog": "Vamos tentar novamente! Precisamos encontrar os conectores certos!",
		"title": "Professora"
	}
}


func _ready() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	professora.body_entered.connect(_on_professora_body_entered)
	professora.body_exited.connect(_on_professora_body_exited)


func _process(_delta: float) -> void:
	if not player_perto:
		return

	if get_tree().paused:
		return

	if Input.is_action_just_pressed("interagir"):
		if dialogo_inicial_feito and not minigame_completo:
			return  # Minigame já foi aberto, aguardando resultado
		elif minigame_completo:
			_iniciar_dialogo_vitoria()
		else:
			_iniciar_dialogo_inicial()


# ─── Diálogo Inicial ─────────────────────────────────────────────────────────

func _iniciar_dialogo_inicial() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dialog_data
	dialogo_ativo.tree_exited.connect(_on_dialogo_inicial_finalizado)
	hud.add_child(dialogo_ativo)


func _on_dialogo_inicial_finalizado() -> void:
	dialogo_ativo = null
	dialogo_inicial_feito = true
	_abrir_minigame()


# ─── Minigame ────────────────────────────────────────────────────────────────

func _abrir_minigame() -> void:
	var minigame: Control = MINIGAME_LOGICA.instantiate()
	minigame.finished.connect(_on_minigame_finalizado)
	hud.add_child(minigame)


func _on_minigame_finalizado(result: String) -> void:
	await get_tree().process_frame

	match result:
		"success":
			minigame_completo = true
			_iniciar_dialogo_vitoria()
		_:
			_iniciar_dialogo_e_reiniciar(failure_dialog)


# ─── Diálogo Vitória ─────────────────────────────────────────────────────────

func _iniciar_dialogo_vitoria() -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = success_dialog
	dialogo_ativo.tree_exited.connect(_on_dialogo_vitoria_finalizado)
	hud.add_child(dialogo_ativo)


func _on_dialogo_vitoria_finalizado() -> void:
	dialogo_ativo = null
	_finalizar_fase()


# ─── Diálogo de erro + reinício ──────────────────────────────────────────────

func _iniciar_dialogo_e_reiniciar(dialog: Dictionary) -> void:
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dialog
	dialogo_ativo.tree_exited.connect(_reiniciar_fase)
	hud.add_child(dialogo_ativo)


func _reiniciar_fase() -> void:
	dialogo_ativo = null
	get_tree().reload_current_scene()


# ─── Finalizar Fase ──────────────────────────────────────────────────────────

func _finalizar_fase() -> void:
	if not Global.peca_coletada[5]:
		Global.peca_coletada[5] = true
		Global.tem_placa_de_video = true
		Global.pecas_coletadas += 1
		Global.nivel_desbloqueado = max(Global.nivel_desbloqueado, 6)
		Global.salvar_jogo()
	Global.carregar_fase("res://Fases/FaseInicial.tscn")


# ─── Sinais de Colisão ───────────────────────────────────────────────────────

func _on_professora_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true


func _on_professora_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
