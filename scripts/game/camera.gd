# Camera — cámara top-down que sigue al jugador suavemente (LOOP-2).
# Look-ahead en la dirección de movimiento para que el jugador vea hacia
# dónde va. Zoom configurable para mostrar el puesto + zona bloqueada
# cercana. Mucho feel: smoothing exponencial, no lineal, para que se
# sienta cinematográfico sin lag perceptible.
class_name GameCamera
extends Camera2D

@export var follow_speed: float = 6.0  # mayor = más reactivo
@export var look_ahead: float = 70.0   # offset en dir de movimiento
@export var look_ahead_speed: float = 4.0
@export var zoom_target: Vector2 = Vector2(1.0, 1.0)

var _player: Node = null
var _look_ahead_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Buscar al jugador por ruta relativa (Camera2D está en World/).
	_player = get_node_or_null("../Player")
	if _player == null:
		push_warning("[Camera] Player no encontrado, cámara estática")
	position_smoothing_enabled = false  # hacemos el smoothing a mano
	zoom = zoom_target

func _physics_process(delta: float) -> void:
	if _player == null:
		_player = get_node_or_null("../Player")
		if _player == null:
			return

	# Look-ahead: offset en la dirección del facing/velocidad del jugador.
	var desired_la: Vector2 = Vector2.ZERO
	if "facing" in _player:
		desired_la = Vector2(_player.facing) * look_ahead
	elif "velocity" in _player:
		var v: Vector2 = _player.velocity
		if v.length() > 5.0:
			desired_la = v.normalized() * look_ahead
	_look_ahead_pos = _look_ahead_pos.lerp(desired_la, clampf(look_ahead_speed * delta, 0.0, 1.0))

	var target: Vector2 = Vector2(_player.position) + _look_ahead_pos
	# Smoothing exponencial (frame-rate independiente aprox).
	var t: float = clampf(follow_speed * delta, 0.0, 1.0)
	position = position.lerp(target, t)
