extends Control

# lista com o caminho de cada cena de fase na ordem
# ajusta os caminhos conforme seus arquivos
@export var fases: Array[String] = [
	"res://Fases/Level_01.tscn",
	"res://Fases/Level_02.tscn",
	"res://Fases/Level_03.tscn",
	"res://Fases/Level_04.tscn",
	"res://Fases/Level_05.tscn",
	"res://Fases/Level_06.tscn",
]

func _ready():
	# percorre os 6 botões e conecta o clique de cada um
	#tem que ir atualizando conforme coloca as fases

	for i in range(fases.size()):
		var num_fase = i + 1
		# busca o botão pelo nome — Fase1, Fase2, etc
		var botao = get_node("FundoMenu/CenterContainer/GridContainer/Fase" + str(num_fase)) as TextureButton
		# conecta o sinal pressed passando o índice pra saber qual fase abrir
		botao.pressed.connect(_on_fase_selecionada.bind(i))
		
		# Bloqueia níveis que ainda não foram desbloqueados
		_atualizar_estado_botao(botao, num_fase)

func _atualizar_estado_botao(botao: TextureButton, num_fase: int) -> void:
	if num_fase <= Global.nivel_desbloqueado:
		botao.disabled = false
		botao.modulate = Color.WHITE
	else:
		botao.disabled = true
		botao.modulate = Color(0.3, 0.3, 0.3, 0.6)  # Escurecido / bloqueado

# chamada quando qualquer botão de fase for clicado
func _on_fase_selecionada(indice: int):
	# usa o índice pra pegar o caminho certo na lista e trocar de cena
	get_tree().paused = false
	
	# Mapeia os ícones de acordo com a fase
	var icones_pecas = [
		"res://assets/sprites/GUI/menu_portal/spritesheet_motherboard.png",
		"res://assets/sprites/GUI/menu_portal/spritesheet_cpu.png",
		"res://assets/sprites/GUI/menu_portal/spritesheet_ram.png",
		"res://assets/sprites/GUI/menu_portal/spritesheet_hd.png",
		"res://assets/sprites/GUI/menu_portal/spritesheet_fonte.png",
		"res://assets/sprites/GUI/menu_portal/spritesheet_gpu.png"
	]
	
	var icone = ""
	if indice < icones_pecas.size():
		icone = icones_pecas[indice]
		
	Global.carregar_fase(fases[indice], icone)
