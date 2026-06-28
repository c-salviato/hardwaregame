extends Area2D

const DIALOG_SCREEN = preload("res://EstruturasTSCN/DialogScreen.tscn")

# Criamos um encaixe para você arrastar o nó HUD no Inspetor
@onready var hud = $HUD

var player_perto := false
var dialogo_ativo = null

# Diálogo padrão de quando o jogador interage, mas não tem peça nova
var dialog_sem_peca = {
	0: {
		"faceset": "res://assets/sprites/player/player_portraits/player_normal.png", 
		"dialog": "Ainda faltam peças. Preciso ir no portal e encontra-las.", 
		"title": "Player"
	}
}

# Diálogo para quando o PC já estiver pronto
var dialog_completo = {
	0: {
		"faceset": "res://assets/sprites/player/player_portraits/player_feliz.png", 
		"dialog": "O computador está 100% montado e pronto para funcionar!", 
		"title": "Player"
	}
}

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if !player_perto:
		return

	if dialogo_ativo != null:
		return

	if Input.is_action_just_pressed("interagir"):
		
		# --- NOVIDADE: Só permite interagir se o diálogo do pai já tiver acontecido ---
		if !Global.dialogo_pai_feito:
			return # Se não conversou com o pai ainda, ignora o clique do jogador
		# -----------------------------------------------------------------------------
		
		verificar_e_interagir()

func verificar_e_interagir():
	var dados_dialogo = {}

	# Verifica o status das peças usando o nosso script Global
	if Global.pecas_colocadas == 6:
		# Já colocou todas as 6 peças
		dados_dialogo = dialog_completo
		
	elif Global.pecas_coletadas > Global.pecas_colocadas:
		# O jogador tem mais peças coletadas do que colocadas (ou seja, tem peça nova no inventário)
		Global.pecas_colocadas += 1 # Registra que a peça foi colocada
		dados_dialogo = obter_dialogo_peca(Global.pecas_colocadas)
		
	else:
		# O jogador não pegou nenhuma peça nova ainda
		dados_dialogo = dialog_sem_peca

	# Mostra o diálogo na tela pausando o jogo (mesma lógica do Pai)
	mostrar_dialogo(dados_dialogo)


func mostrar_dialogo(dados: Dictionary):
	dialogo_ativo = DIALOG_SCREEN.instantiate()
	dialogo_ativo.data = dados
	dialogo_ativo.process_mode = Node.PROCESS_MODE_ALWAYS

	dialogo_ativo.tree_exited.connect(func():
		dialogo_ativo = null
		get_tree().paused = false
	)

	hud.add_child(dialogo_ativo)
	get_tree().paused = true


# Função auxiliar que gera o texto dependendo de qual peça está sendo colocada
func obter_dialogo_peca(numero_peca: int) -> Dictionary:
	var nome_peca = ""
	match numero_peca:
		1: nome_peca = "a Placa Mãe"
		2: nome_peca = "o Processador"
		3: nome_peca = "a Memória RAM"
		4: nome_peca = "o Disco Rígido (HD)"
		5: nome_peca = "a Fonte de Alimentação"
		6: nome_peca = "a Placa de Vídeo"

	return {
		0: {
			"faceset": "res://assets/sprites/player/player_portraits/player_feliz.png", 
			"dialog": "Eu instalei " + nome_peca + " no gabinete!", 
			"title": "Player"
		}
	}


func _on_body_entered(body):
	if body.name == "Player":
		player_perto = true

func _on_body_exited(body):
	if body.name == "Player":
		player_perto = false
