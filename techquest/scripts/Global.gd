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
var tem_hd: bool = false

# Sistema de carregamento
var cena_destino: String = ""
var icone_peca: String = ""

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
var _current_walk_is_grama: bool = false

var _walk_stream_grama: AudioStream = null
var _walk_stream_default: AudioStream = null

func _ready() -> void:
	_setup_audio()
	call_deferred("_check_startup_music")

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
	icone_peca = icone_path
	get_tree().change_scene_to_file("res://EstruturasTSCN/TelaCarregamento.tscn")
