# Juice — singleton de feedback táctil (JUICE-1, capa 5).
# Centraliza partículas, cash volando al HUD, screen shake y sonidos
# placeholder generados proceduralmente (sin assets externos, apto
# HTML5). API pública:
#   Juice.register_camera(cam)
#   Juice.money_burst(world_pos)    # partículas verdes al recoger dinero
#   Juice.unlock_burst(world_pos)   # partículas doradas al desbloquear
#   Juice.fly_cash(from_world, amount)  # tween "+$N" subiendo y desvaneciendo
#   Juice.shake(amount, duration)   # screen shake suave
#   Juice.play_pickup()             # SFX moneda
#   Juice.play_unlock()             # SFX desbloqueo (sweep ascendente)
#   Juice.play_buy()                # SFX compra upgrade
extends Node

# --- Screen shake ---
var _shake_camera: Camera2D = null
var _shake_amount: float = 0.0
var _shake_time: float = 0.0
var _shake_duration: float = 0.25

# --- SFX (generados en runtime, sin assets externos) ---
var _sfx_players: Array = []
var _sfx_streams: Dictionary = {}
const _MAX_SFX_PLAYERS: int = 8

func _ready() -> void:
	_generate_sfx()

func register_camera(cam: Camera2D) -> void:
	_shake_camera = cam

# --- Partículas: burst al recoger dinero (CPUParticles2D, HTML5-safe) ---
func money_burst(world_pos: Vector2) -> void:
	_spawn_burst(world_pos, Color(0.3, 0.95, 0.4), 14, 70.0, 160.0)

# --- Partículas: burst dorado al desbloquear zona (POLISH-3) ---
func unlock_burst(world_pos: Vector2) -> void:
	_spawn_burst(world_pos, Color(1.0, 0.85, 0.2), 22, 90.0, 200.0)

func _spawn_burst(world_pos: Vector2, color: Color, amount: int, vmin: float, vmax: float) -> void:
	var p: CPUParticles2D = CPUParticles2D.new()
	p.position = world_pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.5
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = vmin
	p.initial_velocity_max = vmax
	p.gravity = Vector2(0, 220)
	p.scale_amount_min = 3.0
	p.scale_amount_max = 7.0
	p.color = color
	p.z_index = 50
	_add_to_world(p)
	# Auto-free tras lifetime + margen. create_timer es OK aquí: corre
	# en juego real (no headless --quit-after), donde sí es wall-clock.
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _add_to_world(node: Node) -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var world: Node = scene.get_node_or_null("World")
	if world:
		world.add_child(node)
	else:
		scene.add_child(node)

# --- Cash fly: tween "+$N" que sube, escala y desvanece (feel de volar al HUD) ---
func fly_cash(from_world: Vector2, amount: float) -> void:
	var label: Label = Label.new()
	label.text = "+$%d" % int(amount)
	label.position = from_world
	label.z_index = 100
	label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_add_to_world(label)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position:y", from_world.y - 70.0, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "scale", Vector2(1.5, 1.5), 0.55) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 0.55) \
		.set_trans(Tween.TRANS_SINE)
	tw.chain().tween_callback(label.queue_free)

# --- Screen shake suave (decae con el tiempo) ---
func shake(amount: float = 8.0, duration: float = 0.25) -> void:
	if _shake_camera == null:
		return
	_shake_amount = maxf(_shake_amount, amount)
	_shake_time = maxf(_shake_time, duration)
	_shake_duration = duration

func _process(delta: float) -> void:
	if _shake_camera != null and _shake_time > 0.0:
		_shake_time -= delta
		var decay: float = clampf(_shake_time / _shake_duration, 0.0, 1.0)
		var amt: float = _shake_amount * decay
		_shake_camera.offset = Vector2(randf_range(-amt, amt), randf_range(-amt, amt))
		if _shake_time <= 0.0:
			_shake_camera.offset = Vector2.ZERO
			_shake_amount = 0.0

# --- SFX generados proceduralmente (AudioStreamWAV, sin archivos) ---
func _generate_sfx() -> void:
	_sfx_streams["coin"] = _make_beep(880.0, 0.09, 0.45)
	_sfx_streams["unlock"] = _make_sweep(440.0, 880.0, 0.22, 0.5)
	_sfx_streams["buy"] = _make_beep(660.0, 0.07, 0.35)

func _make_beep(freq: float, dur: float, vol: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var n: int = int(sample_rate * dur)
	var data: PackedByteArray = PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-t * 8.0)
		var s: float = sin(t * freq * TAU) * env * vol
		var v: int = int(clampf(s, -1.0, 1.0) * 32767.0)
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _make_sweep(freq_start: float, freq_end: float, dur: float, vol: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var n: int = int(sample_rate * dur)
	var data: PackedByteArray = PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t: float = float(i) / float(sample_rate)
		var progress: float = float(i) / float(n)
		var freq: float = lerpf(freq_start, freq_end, progress)
		var env: float = exp(-t * 5.0)
		var s: float = sin(t * freq * TAU) * env * vol
		var v: int = int(clampf(s, -1.0, 1.0) * 32767.0)
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func play_pickup() -> void:
	_play_named("coin")

func play_unlock() -> void:
	_play_named("unlock")

func play_buy() -> void:
	_play_named("buy")

func _play_named(name: String) -> void:
	var stream: AudioStreamWAV = _sfx_streams.get(name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _get_sfx_player()
	if player:
		player.stream = stream
		player.play()

func _get_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if p is AudioStreamPlayer and not p.playing:
			return p
	if _sfx_players.size() < _MAX_SFX_PLAYERS:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		_sfx_players.append(p)
		return p
	return _sfx_players[0]
