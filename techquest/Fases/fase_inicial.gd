extends Node2D
class_name LevelInical
const _DIALOG_SCREEN: PackedScene = preload("res://Dialogo/DialogScreen.tscn")
#aqui a gente cria os diálogos
var _dialog_data: Dictionary ={
	0:{
			"faceset": "res://icon.svg",
			"dialog": "Olá, como você está?",
			"title": "portal falante?????"
	},
	1:{
			"faceset": "res://icon.svg",
			"dialog": "Isso aqui não passa de um teste...",
			"title": "portal falante?????"
	},
	2:{
			"faceset": "res://icon.svg",
			"dialog": "Como o mundo é louco, um portal falante",
			"title": "portal falante?????"
	}
}
@export_category("Objects")
@export var _hud: CanvasLayer=null
var _dialogo_ativo = null
func _process(delta: float) -> void:
	if _dialogo_ativo != null:
		return
	if Input.is_action_just_pressed("ui_select"):
		_dialogo_ativo = _DIALOG_SCREEN.instantiate() 
		_dialogo_ativo.data = _dialog_data
		_dialogo_ativo.tree_exited.connect(func(): _dialogo_ativo = null)
		_hud.add_child(_dialogo_ativo)  
		
