# Client — cliente NPC que compra del estante (loop base, LOOP-5).
# Ciclo: spawn → camina al estante → browse → si hay stock compra
# (take_item) → deja dinero físico en el piso → camina a la salida
# → despawn. Si no hay stock tras esperar, se va frustrado.
# El dinero lo suelta como MoneyDrop (recogible por el jugador en
# contacto, ver money_drop.gd). Conecta estante → dinero → jugador.
# Usa _process (no _physics_process): movimiento directo por delta,
# sin move_and_slide. En headless --quit-after los physics ticks
# no corren; _process sí.
class_name Client
extends Node2D

signal bought(value: float)
signal left()

@export var walk_speed: float = 130.0
@export var wait_for_stock_max: float = 5.0
@export var product_value: float = 5.0

var target_shelf: Node = null
var exit_pos: Vector2 = Vector2.ZERO
var _state: String = "to_shelf"
var _target_pos: Vector2 = Vector2.ZERO
var _wait_time: float = 0.0
var _last_ms: int = 0

@onready var _body: ColorRect = $Body
@onready var _face: ColorRect = $Face

func _ready() -> void:
	_update_target_for_state()
	_last_ms = Time.get_ticks_msec()

# API para el spawner: asigna estante objetivo y puntos de spawn/exit.
func setup(p_shelf: Node, p_spawn: Vector2, p_exit: Vector2) -> void:
	target_shelf = p_shelf
	exit_pos = p_exit
	position = p_spawn
	_state = "to_shelf"
	_update_target_for_state()

func _process(_delta: float) -> void:
	# Delta real basado en wall-clock: en headless --quit-after el FPS
	# no está capped y el delta del engine es diminuto, haciendo el
	# movimiento imperceptible. Tiempo real es robusto en cualquier modo.
	var now_ms: int = Time.get_ticks_msec()
	var real_delta: float = (now_ms - _last_ms) / 1000.0
	_last_ms = now_ms
	match _state:
		"to_shelf":
			_walk(real_delta)
			if _reached_target():
				_state = "browse"
				_wait_time = 0.0
		"browse":
			_wait_time += real_delta
			if target_shelf and target_shelf.has_method("has_stock") and target_shelf.has_stock():
				_do_buy()
			elif _wait_time >= wait_for_stock_max:
				_state = "to_exit"
				_update_target_for_state()
		"to_exit":
			_walk(real_delta)
			if _reached_target():
				_despawn()
	_update_facing()

func _walk(delta: float) -> void:
	_update_target_for_state()
	var dir: Vector2 = _target_pos - position
	var dist: float = dir.length()
	if dist < 1.5:
		position = _target_pos
		return
	var step: float = walk_speed * delta
	position += dir.normalized() * min(step, dist)

func _update_target_for_state() -> void:
	if _state == "to_shelf":
		_target_pos = _queue_pos()
	elif _state == "to_exit":
		_target_pos = exit_pos

func _queue_pos() -> Vector2:
	if target_shelf:
		return target_shelf.position + Vector2(0, 60)
	return position

func _reached_target() -> bool:
	return position.distance_to(_target_pos) < 1.5

func _do_buy() -> void:
	if target_shelf == null or not target_shelf.has_method("take_item"):
		_state = "to_exit"
		_update_target_for_state()
		return
	var taken: int = target_shelf.take_item(1)
	if taken <= 0:
		_state = "to_exit"
		_update_target_for_state()
		return
	# Usar el product_value del estante (configurado por el Business)
	# si está disponible; si no, el del cliente.
	var val: float = product_value
	if "product_value" in target_shelf and target_shelf.product_value > 0.0:
		val = target_shelf.product_value
	_spawn_money_drop(taken, val)
	emit_signal("bought", val * float(taken))
	print("[Client] bought %d unit(s) from %s, dropped $%d" % [taken, target_shelf.name, int(val * float(taken))])
	# Pop táctil al comprar.
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.2, 0.8), 0.07).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE)
	_state = "to_exit"
	_update_target_for_state()

func _spawn_money_drop(units: int, val: float) -> void:
	var drop_scn: PackedScene = preload("res://scenes/MoneyDrop.tscn")
	var drop: Node = drop_scn.instantiate()
	drop.position = position + Vector2(randf_range(-18.0, 18.0), 24.0)
	drop.value = val * float(units)
	get_parent().add_child(drop)

func _despawn() -> void:
	emit_signal("left")
	queue_free()

func _update_facing() -> void:
	var dirx: float = (_target_pos - position).x
	if abs(dirx) > 1.0:
		_face.scale.x = sign(dirx)
