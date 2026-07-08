extends Control

@onready var credits_panel: Panel = $CreditsPanel

func _ready() -> void:
	credits_panel.hide()
	# Inicia música do menu
	Global.play_menu_music()

func _on_jogar_pressed() -> void:
	Global.carregar_fase("res://Fases/FaseInicial.tscn")

func _on_creditos_pressed() -> void:
	credits_panel.show()

func _on_close_credits_pressed() -> void:
	credits_panel.hide()
