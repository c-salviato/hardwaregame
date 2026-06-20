extends Control
class_name DialogScrenn

#dar aquela sensação de letras aparecendo bonito
var _step: float = 0.05

#identicar qual é o diálogo q estamos buscando para pular
var _id: int=0
var  data: Dictionary = {}

@export_category("Objetcs")
@export var _nome: Label = null
@export var _dialogo: RichTextLabel = null
@export var _faceset: TextureRect = null

func _ready() -> void:
	_inicia_dialogo()
	
func _process(delta: float) -> void:
	#se apertar enter e o dialogo n estiver 100% visivel, a gente diminue o tempo do step pra acelerar
	if Input.is_action_just_pressed("interagir") and _dialogo.visible_ratio <1:
		_step = 0.01
		return
	_step = 0.05
	#pula pro próximo diálogo
	if Input.is_action_just_pressed("interagir"):
		_id+=1
		#mata o objeto do dialogo
		if _id == data.size():	
			queue_free()
			return
			
		_inicia_dialogo()

func _inicia_dialogo() -> void:
	_nome.text = data[_id]["title"]
	_dialogo.text= data[_id]["dialog"]
	_faceset.texture = load(data[_id]["faceset"])
	
	#limpa os caracteres q tão aparecendo
	_dialogo.visible_characters=0
	#enquanto o dialogo não estiver 100% mostrado
	while _dialogo.visible_ratio <1:
		#cria o temporizador, pra ficar mostrando a msg dependendo do tempo (step)
		await get_tree().create_timer(_step).timeout
		_dialogo.visible_characters +=1
		
