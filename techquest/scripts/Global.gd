extends Node

# ─── Progressão de Níveis ──────────────────────────────────────────────────────
# Qual é o nível mais alto desbloqueado (1 a 6). Começa no nível 1.
var nivel_desbloqueado: int = 1
# Controla se a peça de cada nível já foi coletada (índice 0 = Level 1, ...)
var peca_coletada: Array[bool] = [false, false, false, false, false, false]

# Variável que diz quantas peças o jogador já pegou nas fases (começa em 0, vai até 6)
var pecas_coletadas: int = 0

# Variável que diz quantas peças já foram instaladas no gabinete
var pecas_colocadas: int = 0

# Guarda se a primeira conversa com o pai já foi concluída (começa como falso)
var dialogo_pai_feito: bool = false

# Itens específicos coletados
var tem_placa_mae: bool = false
var tem_processador: bool = false
var tem_hd: bool = false
var tem_placa_de_video: bool = false

# Sistema de carregamento
var cena_destino: String = ""
var icone_peca: String = ""

# Caminho do arquivo de save
const SAVE_PATH: String = "user://save_game.cfg"

# ─── Sistema de Áudio ────────────────────────────────────────────────────────
const AUDIO_WALK_DEFAULT_PATH := "res://assets/audios/andando.mp3"
const AUDIO_WALK_GRAMA_PATH := "res://assets/audios/andando_na_grama.mp3"
const AUDIO_MUSIC_MENU_PATH := "res://assets/audios/musica_menu.ogg"
const AUDIO_MUSIC_LEVEL_PATH := "res://assets/audios/musica_levels.mp3"
const AUDIO_PECAS_MONTANDO_PATH := "res://assets/audios/pecas_montando.wav"
const AUDIO_POP_UP_ABRINDO_PATH := "res://assets/audios/pop_up_abrindo.wav"
const AUDIO_NPC_FALANDO_PATH := "res://assets/audios/npc_falando.ogg"

var _music_player: AudioStreamPlayer
var _walking_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _dialog_player: AudioStreamPlayer

var _current_music: String = ""
var music_muted: bool = false
var _current_walk_is_grama: bool = false

var _walk_stream_grama: AudioStream = null
var _walk_stream_default: AudioStream = null

func _ready() -> void:
	carregar_jogo()
	_setup_audio()
	call_deferred("_check_startup_music")

func is_music_muted() -> bool:
	return music_muted

func toggle_music() -> void:
	music_muted = not music_muted
	_music_player.stream_paused = music_muted

func _setup_audio() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.volume_db = -6.0
	add_child(_music_player)

	_walking_player = AudioStreamPlayer.new()
	_walking_player.name = "WalkingPlayer"
	_walking_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_walking_player.volume_db = -6.0
	add_child(_walking_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_sfx_player)

	_dialog_player = AudioStreamPlayer.new()
	_dialog_player.name = "DialogPlayer"
	_dialog_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_dialog_player)

	# Pré-carrega streams de andar para evitar load() repetido
	var raw: AudioStream = load(AUDIO_WALK_DEFAULT_PATH)
	if raw:
		_walk_stream_default = raw.duplicate()
	raw = load(AUDIO_WALK_GRAMA_PATH)
	if raw:
		_walk_stream_grama = raw.duplicate()

# ─── Música ───────────────────────────────────────────────────────────────────

func play_menu_music() -> void:
	if _current_music == "menu":
		return
	_stop_music()
	var audio: AudioStream = load(AUDIO_MUSIC_MENU_PATH)
	if not audio:
		return
	var stream: AudioStreamOggVorbis = audio.duplicate()
	stream.loop = true
	_music_player.stream = stream
	_music_player.play()
	if music_muted:
		_music_player.stream_paused = true
	_current_music = "menu"

func play_level_music() -> void:
	if _current_music == "level":
		return
	_stop_music()
	var audio: AudioStream = load(AUDIO_MUSIC_LEVEL_PATH)
	if not audio:
		return
	var stream: AudioStreamMP3 = audio.duplicate()
	stream.loop = true
	_music_player.stream = stream
	_music_player.play()
	if music_muted:
		_music_player.stream_paused = true
	_current_music = "level"

func stop_music() -> void:
	if _current_music == "":
		return
	_stop_music()

func _stop_music() -> void:
	_music_player.stop()
	_music_player.stream = null
	_current_music = ""

# ─── Som de Andar ────────────────────────────────────────────────────────────

func is_walking_on_grass() -> bool:
	var scene_path := ""
	var current := get_tree().current_scene
	if current and current.scene_file_path:
		scene_path = current.scene_file_path
	# Level_02 e Level_03 usam som de grama
	return scene_path in [
		"res://Fases/Level_02.tscn",
		"res://Fases/Level_03.tscn"
	]

func play_walking_sound() -> void:
	var on_grass := is_walking_on_grass()
	if _walking_player.playing and on_grass == _current_walk_is_grama:
		return

	_walking_player.stop()
	if on_grass and _walk_stream_grama:
		var stream: AudioStreamMP3 = _walk_stream_grama.duplicate()
		stream.loop = true
		_walking_player.stream = stream
		_walking_player.play()
		_current_walk_is_grama = true
		return
	elif _walk_stream_default:
		var stream: AudioStreamMP3 = _walk_stream_default.duplicate()
		stream.loop = true
		_walking_player.stream = stream
		_walking_player.play()
		_current_walk_is_grama = false
		return

func stop_walking_sound() -> void:
	_walking_player.stop()

# ─── Efeitos Sonoros ─────────────────────────────────────────────────────────

func play_pecas_montando() -> void:
	_sfx_player.stop()
	var audio: AudioStream = load(AUDIO_PECAS_MONTANDO_PATH)
	if audio:
		_sfx_player.stream = audio
		_sfx_player.play()

func play_pop_up_abrindo() -> void:
	_sfx_player.stop()
	var audio: AudioStream = load(AUDIO_POP_UP_ABRINDO_PATH)
	if audio:
		_sfx_player.stream = audio
		_sfx_player.play()

# ─── Som de Diálogo ──────────────────────────────────────────────────────────

func start_dialog_sound() -> void:
	if _dialog_player.playing:
		return
	var audio: AudioStreamOggVorbis = load(AUDIO_NPC_FALANDO_PATH)
	if audio:
		var stream: AudioStreamOggVorbis = audio.duplicate()
		stream.loop = true
		_dialog_player.stream = stream
		_dialog_player.play()

func stop_dialog_sound() -> void:
	_dialog_player.stop()

# ─── Detecção de música na troca de cena ────────────────────────────────────

func _check_startup_music() -> void:
	var current := get_tree().current_scene
	if not current:
		return
	_apply_music_for_scene(current.scene_file_path)

func apply_music_for_current_scene() -> void:
	var current := get_tree().current_scene
	if not current:
		return
	_apply_music_for_scene(current.scene_file_path)

func _apply_music_for_scene(path: String) -> void:
	if path == "res://MenuInicial.tscn":
		play_menu_music()
	elif path.begins_with("res://Fases/Level_"):
		play_level_music()
	else:
		stop_music()

func carregar_fase(path: String, icone_path: String = "") -> void:
	cena_destino = path
	# Se for carregar o lobby (FaseInicial) e nenhum ícone foi passado, usa o ícone da casa
	if icone_path == "" and path == "res://Fases/FaseInicial.tscn":
		icone_peca = "res://assets/sprites/GUI/icone_casa.png"
	else:
		icone_peca = icone_path
	get_tree().change_scene_to_file("res://EstruturasTSCN/TelaCarregamento.tscn")

# ─── Save / Load ───────────────────────────────────────────────────────────────

func salvar_jogo() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progresso", "nivel_desbloqueado", nivel_desbloqueado)
	cfg.set_value("progresso", "pecas_coletadas", pecas_coletadas)
	cfg.set_value("progresso", "pecas_colocadas", pecas_colocadas)
	cfg.set_value("progresso", "dialogo_pai_feito", dialogo_pai_feito)
	cfg.set_value("progresso", "tem_placa_mae", tem_placa_mae)
	cfg.set_value("progresso", "tem_processador", tem_processador)
	cfg.set_value("progresso", "tem_hd", tem_hd)
	cfg.set_value("progresso", "tem_placa_de_video", tem_placa_de_video)
	# Salva o array de peças coletadas por nível
	for i in range(peca_coletada.size()):
		cfg.set_value("progresso", "peca_coletada_" + str(i), peca_coletada[i])
	cfg.save(SAVE_PATH)

func carregar_jogo() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return  # Arquivo não existe ainda; usa valores padrão
	
	nivel_desbloqueado = cfg.get_value("progresso", "nivel_desbloqueado", 1)
	pecas_coletadas = cfg.get_value("progresso", "pecas_coletadas", 0)
	pecas_colocadas = cfg.get_value("progresso", "pecas_colocadas", 0)
	dialogo_pai_feito = cfg.get_value("progresso", "dialogo_pai_feito", false)
	tem_placa_mae = cfg.get_value("progresso", "tem_placa_mae", false)
	tem_processador = cfg.get_value("progresso", "tem_processador", false)
	tem_hd = cfg.get_value("progresso", "tem_hd", false)
	tem_placa_de_video = cfg.get_value("progresso", "tem_placa_de_video", false)
	for i in range(peca_coletada.size()):
		peca_coletada[i] = cfg.get_value("progresso", "peca_coletada_" + str(i), false)

func reiniciar_progresso() -> void:
	# Reseta tudo para os valores iniciais
	nivel_desbloqueado = 1
	for i in range(peca_coletada.size()):
		peca_coletada[i] = false
	pecas_coletadas = 0
	pecas_colocadas = 0
	dialogo_pai_feito = false
	tem_placa_mae = false
	tem_processador = false
	tem_hd = false
	tem_placa_de_video = false
	# Apaga o arquivo de save
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove("save_game.cfg")
