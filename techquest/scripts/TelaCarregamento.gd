extends Control

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var icone_sprite: Sprite2D = $IconePeca

func _ready() -> void:
	animation.play("loading")
	
	if Global.icone_peca != "":
		var tex: Texture2D = load(Global.icone_peca)
		if tex:
			# Configura o ícone para mostrar apenas a metade esquerda (1 de 2 colunas)
			icone_sprite.texture = tex
			icone_sprite.hframes = 2
			icone_sprite.frame = 0
			icone_sprite.show()
	else:
		icone_sprite.hide()
		
	# Timer de no mínimo 2 segundos
	await get_tree().create_timer(2.5).timeout
	
	if Global.cena_destino != "":
		get_tree().change_scene_to_file(Global.cena_destino)
