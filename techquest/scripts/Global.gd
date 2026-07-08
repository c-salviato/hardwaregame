extends Node

# Variável que diz quantas peças o jogador já pegou nas fases (começa em 0, vai até 6)
var pecas_coletadas: int = 0

# Variável que diz quantas peças já foram instaladas no gabinete
var pecas_colocadas: int = 0

# Guarda se a primeira conversa com o pai já foi concluída (começa como falso)
var dialogo_pai_feito: bool = false

# Itens específicos coletados
var tem_placa_mae: bool = false
var tem_processador: bool = false
# Sistema de carregamento
var cena_destino: String = ""
var icone_peca: String = ""

func carregar_fase(path: String, icone_path: String = "") -> void:
	cena_destino = path
	icone_peca = icone_path
	get_tree().change_scene_to_file("res://EstruturasTSCN/TelaCarregamento.tscn")
