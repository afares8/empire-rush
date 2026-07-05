# Player — personaje jugador controlable (loop base, LOOP-1).
# Movimiento top-down con WASD. Visual placeholder (ColorRect) con
# bob + squash/stretch al caminar para sentirse táctil.
# Emite `interact_pressed` para que pickup/estante/pad se conecten.
class_name Player
extends CharacterBody2D

signal interact_pressed
signal moved(velocity: Vector2)
signal carry_changed(carried: int)

@export var move_speed: float = 220.0
@export var acceleration: float = 1800.0
@export var friction: float = 1600.0
@export var carry_capacity: int = 3

var facing: Vector2 = Vector2.DOWN
var is_walking: bool = false
var carried: int = 0

@onready var _body: ColorRect = $Body
@onready var _head: ColorRect = $Head
@onready var _shadow: ColorRect = $Shadow
@onready var _carry_box: ColorRect = $CarryBox
@onready var _carry_label: Label = $CarryLabel
var _bob_t: float = 0.0
var _base_body_y: float = 0.0
var _base_head_y: float = 0.0

func _ready() -> void:
	_base_body_y = _body.position.y
	_base_head_y = _head.position.y
	# Sombra más ancha que el cuerpo para dar profundidad isométrica.
	_shadow.size = Vector2(34, 12)
	_shadow.color = Color(0.0, 0.0, 0.0, 0.35)
	_shadow.position = Vector2(-_shadow.size.x / 2.0, 22)
	_update_carry_visual()

func _physics_process(delta: float) -> void:
	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Normalizar diagonales para que no sean más rápidas.
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	if input_vec != Vector2.ZERO:
		velocity = velocity.move_toward(input_vec * move_speed, acceleration * delta)
		facing = input_vec.normalized() if input_vec.length() > 0.01 else facing
		if not is_walking:
			_start_walk()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if is_walking and velocity.length() < 5.0:
			_stop_walk()

	move_and_slide()

	if velocity.length() > 5.0:
		_update_bob(delta)
		emit_signal("moved", velocity)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		emit_signal("interact_pressed")

# --- Animación placeholder (sin sprites) ---

func _start_walk() -> void:
	is_walking = true
	# Pequeño squash al arrancar para dar "empuje" táctil.
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.08, 0.92), 0.08).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_SINE)

func _stop_walk() -> void:
	is_walking = false
	_bob_t = 0.0
	_body.position.y = _base_body_y
	_head.position.y = _base_head_y
	_body.scale = Vector2(1.0, 1.0)

func _update_bob(delta: float) -> void:
	# Bob vertical senoidal mientras camina. Frecuencia escala con velocidad.
	var freq: float = 12.0 * (velocity.length() / move_speed)
	_bob_t += delta * freq
	var bob: float = sin(_bob_t) * 1.8
	_body.position.y = _base_body_y + bob
	_head.position.y = _base_head_y + bob
	# Lean lateral muy sutil en el eje de movimiento para sensación de peso.
	var lean: float = cos(_bob_t) * 0.04
	_body.scale.x = 1.0 + lean
	_body.scale.y = 1.0 - lean

# --- Carga de producto (loop base, LOOP-3) ---

func can_carry() -> bool:
	return carried < carry_capacity

# Recibe n unidades del pickup. Devuelve cuántas realmente cargó
# (respeta capacidad). Feedback táctil: pop del carry box.
func add_carried(n: int) -> int:
	var space: int = carry_capacity - carried
	var to_add: int = clamp(n, 0, space)
	if to_add <= 0:
		return 0
	carried += to_add
	emit_signal("carry_changed", carried)
	_update_carry_visual()
	# Pop de scale al recibir producto para que se sienta táctil.
	var tw: Tween = create_tween()
	tw.tween_property(_carry_box, "scale", Vector2(1.25, 1.25), 0.07).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_carry_box, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	return to_add

# Descarga (para LOOP-4 estante). Devuelve cuántas soltó.
func remove_carried(n: int) -> int:
	var to_remove: int = clamp(n, 0, carried)
	if to_remove <= 0:
		return 0
	carried -= to_remove
	emit_signal("carry_changed", carried)
	_update_carry_visual()
	return to_remove

func _update_carry_visual() -> void:
	var has: bool = carried > 0
	_carry_box.visible = has
	_carry_label.visible = has
	_carry_label.text = "x%d" % carried
