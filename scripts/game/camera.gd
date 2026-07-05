# Camera — cámara top-down que sigue al jugador suavemente (LOOP-2).
# Zoom out suficiente para ver el puesto + una zona bloqueada cercana.
# Lerp suave para que el seguimiento se sienta cinemático, no rígido.
class_name FollowCamera
extends Camera2D

@export var target_path: NodePath = ^""
@export var follow_speed: float = 6.0  # mayor = más rígido
@export var look_ahead: float = 60.0   # adelanta la cámara en la dir de movimiento

var _target: Node2D = null
var _desired_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if target_path != ^"":
		_target = get_node_or_null(target_path)
	if _target:
		_desired_pos = _target.position
		global_position = _desired_pos
		make_current()

func _physics_process(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		return
	# Look-ahead suave basado en facing/velocity del player si lo expone.
	var ahead: Vector2 = Vector2.ZERO
	if _target.has_method("get") and _target.get("velocity"):
		var v: Vector2 = _target.velocity
		if v.length() > 5.0:
			ahead = v.normalized() * look_ahead
	_desired_pos = _target.position + ahead
	# Lerp exponencial (frame-rate independiente).
	var t: float = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(_desired_pos, t)
