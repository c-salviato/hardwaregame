extends Control
class_name DialogScrenn

#dar aquela sensação de letras aparecendo bonito
var _step: float = 0.05

#identicar qual é o diálogo q estamos buscando para pular
var _id: int=0
var  data: Dictionary = {}
var _is_typing: bool = false

@export_category("Objetcs")
@export var _nome: Label = null
@export var _dialogo: RichTextLabel = null
@export var _faceset: TextureRect = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_inicia_dialogo()

func _exit_tree() -> void:
	get_tree().paused = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interagir"):
		if _is_typing:
			# Se estiver escrevendo, pula para o final do texto atual
			_dialogo.visible_ratio = 1
			_is_typing = false
		else:
			# Se já terminou de escrever, passa para o próximo diálogo
			_proximo_dialogo()

func _proximo_dialogo() -> void:
	_id += 1
	if _id == data.size():	
		queue_free()
		return
	_inicia_dialogo()

func _inicia_dialogo() -> void:
	_nome.text = data[_id]["title"]
	_dialogo.text = data[_id]["dialog"]
	_faceset.texture = load(data[_id]["faceset"])
	
	_dialogo.visible_characters = 0
	_is_typing = true
	
	# Loop para mostrar os caracteres um por um
	while _dialogo.visible_ratio < 1:
		if not _is_typing: # Interrompido pelo clique
			break
		await get_tree().create_timer(_step).timeout
		if not is_inside_tree(): # Prevenção de erro se o node for deletado
			return
		_dialogo.visible_characters += 1
	
	_dialogo.visible_ratio = 1 # Garante que está 100% visível
	_is_typing = false
		
