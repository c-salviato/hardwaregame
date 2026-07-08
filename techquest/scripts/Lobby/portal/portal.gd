extends Area2D

#caminho q vai levar o jogador pra seleção de fases
@export var destination_scene: PackedScene
#var pra ver se o jogador ta dentro do portal
var player_inside: bool = false

@onready var sprite_portal = $AnimatedSprite2D
# referência ao CanvasLayer que vai segurar a tela de seleção
@onready var canvas = $CanvasLayer

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	sprite_portal.play("default")
	set_process_input(true)
	
	# Verifica se o portal deve estar ativo ao carregar a cena
	if Global.dialogo_pai_feito:
		show()
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		# Esconde o portal visualmente
		hide() 
		# Desativa toda a física e processamento dele (desliga as colisões e o script)
		process_mode = Node.PROCESS_MODE_DISABLED

#toda essa função é pra quando tiver a fase conectada
func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interagir"):
		# Para o som de andar ao pausar para a seleção de fase
		Global.stop_walking_sound()
		# Instancia a tela de seleção por cima da cena atual
		var tela = destination_scene.instantiate()
		# Conecta o sinal de troca de fase para usar o sistema de carregamento
		if tela.has_signal("fase_selecionada"):
			tela.fase_selecionada.connect(_on_fase_selecionada)
		canvas.add_child(tela)
		# Pausa o jogo assim que a tela de seleção aparecer
		get_tree().paused = true

func _on_fase_selecionada(fase_path: String, icone_path: String):
	get_tree().paused = false
	Global.carregar_fase(fase_path, icone_path)

func _on_body_entered(body: Node2D):
	print("entrou: ", body.name)
	if body.is_in_group("player"):
		player_inside = true
		print("jogador detectado!")

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_inside = false
		
func ativar_portal():
	show() # Torna o portal visível novamente
	process_mode = Node.PROCESS_MODE_INHERIT # Reativa as colisões e a interatividade
