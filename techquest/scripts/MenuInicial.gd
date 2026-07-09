extends Control

@onready var credits_panel: Panel = $CreditsPanel
@onready var volume_button: TextureButton = $VolumeButton

const VOLUME_SPRITESHEET: Texture2D = preload("res://assets/sprites/GUI/spr_icon_volume.png")
const FRAME_SIZE: int = 32

func _ready() -> void:
	credits_panel.hide()
	_configurar_estilo_credits()
	_atualizar_icone_volume()
	# Inicia música do menu
	Global.play_menu_music()

func _configurar_estilo_credits() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.88)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	credits_panel.add_theme_stylebox_override("panel", style)

# Continua com o progresso salvo atual
func _on_continuar_pressed() -> void:
	Global.carregar_fase("res://Fases/FaseInicial.tscn")

# Novo Jogo: reseta todo o progresso e começa do zero
func _on_novo_jogo_pressed() -> void:
	Global.reiniciar_progresso()
	Global.carregar_fase("res://Fases/FaseInicial.tscn")

func _on_creditos_pressed() -> void:
	credits_panel.show()

func _on_close_credits_pressed() -> void:
	credits_panel.hide()

func _on_sair_pressed() -> void:
	get_tree().quit()

func _atualizar_icone_volume() -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = VOLUME_SPRITESHEET
	if Global.is_music_muted():
		atlas.region = Rect2(FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
	else:
		atlas.region = Rect2(0, 0, FRAME_SIZE, FRAME_SIZE)
	volume_button.texture_normal = atlas

func _on_volume_button_pressed() -> void:
	Global.toggle_music()
	_atualizar_icone_volume()
