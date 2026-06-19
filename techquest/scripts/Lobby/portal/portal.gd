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

#toda essa função é pra quando tiver a fase conectada
func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interagir"):
		# Instancia a tela de seleção por cima da cena atual
		var tela = destination_scene.instantiate()
		canvas.add_child(tela)

func _on_body_entered(body: Node2D):
	print("entrou: ", body.name)
	if body.is_in_group("player"):
		player_inside = true
		print("jogador detectado!")

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_inside = false
