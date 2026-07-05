# Factory — mini taller/fábrica (capa 3, BIZ-4).
# Cadena de producción: materia prima (auto-regen) → máquina
# (convierte raw→output a ritmo constante) → producto terminado
# (output_stock) → jugador recoge con E y lleva al estante.
# Visualmente distinto de Pickup: máquina gris con barra de progreso
# amarilla + pila de materia prima (raw) + pila de salida (output).
# Reutiliza Shelf + UnlockPad como hijos (mismo patrón que Business).
class_name Factory
extends Node2D

signal business_unlocked(business_id: String)
signal output_picked_up(amount: int)

@export var business_id: String = "biz_factory"
@export var business_name: String = "Taller"
@export var product_name: String = "camiseta"
@export var product_value: float = 8.0
@export var start_locked: bool = false
@export var unlock_zone_id: String = ""
@export var unlock_price: float = 0.0
@export var tint: Color = Color(0.6, 0.6, 0.85, 1.0)
@export var raw_capacity: int = 10
@export var raw_regen_per_sec: float = 0.8
@export var output_capacity: int = 8
@export var production_time: float = 2.0  # segundos por unidad

var raw_stock: float = 10.0
var output_stock: int = 0
var _progress: float = 0.0  # 0..production_time (segundos reales)
var _locked: bool = false
var _player_in_area: bool = false
var _player: Node = null
var _last_ms: int = 0  # wall-clock para robustez headless (LEARNINGS r5)

@onready var _machine: ColorRect = $Machine
@onready var _progress_fill: ColorRect = $ProgressFill
@onready var _raw_pile: ColorRect = $RawPile
@onready var _output_body: ColorRect = $OutputBody
@onready var _output_label: Label = $OutputLabel
@onready var _output_area: Area2D = $OutputArea

func _ready() -> void:
	add_to_group("factories")
	_locked = start_locked
	if _locked and unlock_zone_id != "" and GameManager.is_zone_unlocked(unlock_zone_id):
		_locked = false
	_apply_state()
	if not GameManager.is_connected("zone_unlocked", _on_zone_unlocked):
		GameManager.zone_unlocked.connect(_on_zone_unlocked)
	# Conectar el área de salida (recoger output) a este script.
	if not _output_area.is_connected("body_entered", _on_output_body_entered):
		_output_area.body_entered.connect(_on_output_body_entered)
	if not _output_area.is_connected("body_exited", _on_output_body_exited):
		_output_area.body_exited.connect(_on_output_body_exited)
	_update_visual()
	_last_ms = Time.get_ticks_msec()
	print("[Factory] %s ready, locked=%s zone=%s" % [business_id, _locked, unlock_zone_id])

func is_locked() -> bool:
	return _locked

# Duck-typing para evitar class_name cross-script (LEARNINGS r2).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("can_carry") and body.has_method("add_carried")

func _is_shelf(n: Node) -> bool:
	return n != null and n.has_method("take_item") and n.has_method("has_stock")

func _is_pad(n: Node) -> bool:
	return n != null and n.has_method("try_unlock") and n.has_signal("unlocked")

func get_shelves() -> Array:
	var out: Array = []
	for c in get_children():
		if _is_shelf(c):
			out.append(c)
	return out

func _on_zone_unlocked(zone_id: String) -> void:
	if zone_id == unlock_zone_id and _locked:
		_locked = false
		_apply_state()
		_last_ms = Time.get_ticks_msec()  # reset para evitar burst de producción
		emit_signal("business_unlocked", business_id)
		print("[Factory] %s unlocked (zone %s)" % [business_id, zone_id])

# Producción: usa _process con wall-clock (Time.get_ticks_msec) para ser
# robusto en headless --quit-after donde delta es diminuto (LEARNINGS r5).
func _process(_delta: float) -> void:
	if _locked:
		return
	var now_ms: int = Time.get_ticks_msec()
	var real_dt: float = (now_ms - _last_ms) / 1000.0
	_last_ms = now_ms
	if real_dt <= 0.0:
		return
	# Regenerar materia prima.
	if raw_stock < float(raw_capacity):
		raw_stock = min(float(raw_capacity), raw_stock + raw_regen_per_sec * real_dt)
	# Convertir raw → output si hay raw, espacio en output y no hay bloqueo.
	if raw_stock >= 1.0 and output_stock < output_capacity:
		_progress += real_dt
		if _progress >= production_time:
			_progress = 0.0
			raw_stock -= 1.0
			output_stock += 1
			_pop_output()
			_update_visual()
			print("[Factory] %s produced 1 (output=%d/%d raw=%.1f)" % [business_id, output_stock, output_capacity, raw_stock])
	else:
		# Sin raw o output lleno: el progreso decae suavemente (no se queda clavado).
		_progress = max(0.0, _progress - real_dt * 0.5)
	_update_progress_fill()

func _update_progress_fill() -> void:
	var ratio: float = _progress / production_time if production_time > 0.0 else 0.0
	# La barra crece de izquierda a derecha dentro de la máquina.
	var max_w: float = 56.0
	_progress_fill.size.x = max_w * ratio
	_progress_fill.color = Color(1.0, 0.85, 0.2, 0.9)

func _on_output_body_entered(body: Node) -> void:
	if not _is_player(body):
		return
	_player_in_area = true
	_player = body
	if not _player.is_connected("interact_pressed", _on_player_interact):
		_player.interact_pressed.connect(_on_player_interact)

func _on_output_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	if _player and _player.is_connected("interact_pressed", _on_player_interact):
		_player.interact_pressed.disconnect(_on_player_interact)
	_player_in_area = false
	_player = null

func _on_player_interact() -> void:
	if not _player_in_area or _player == null or _locked:
		return
	if output_stock <= 0:
		return
	if not _player.can_carry():
		return
	var taken: int = _player.add_carried(1)
	if taken > 0:
		output_stock -= taken
		_update_visual()
		emit_signal("output_picked_up", taken)

func _pop_output() -> void:
	# Pop táctil al producir una unidad.
	var tw: Tween = create_tween()
	tw.tween_property(_output_body, "scale", Vector2(1.2, 0.85), 0.06).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_output_body, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _apply_state() -> void:
	for c in get_children():
		if _is_shelf(c):
			c.locked = _locked
			c.product_name = product_name
			c.product_value = product_value
		elif _is_pad(c):
			if _locked and unlock_zone_id != "":
				c.zone_id = unlock_zone_id
				c.price = unlock_price
				c.visible = true
				c.set_deferred("monitoring", true)
			else:
				c.visible = false
				c.set_deferred("monitoring", false)
	# Área de salida y máquina se apagan si locked.
	_output_area.set_deferred("monitoring", not _locked)
	_machine.visible = not _locked
	_raw_pile.visible = not _locked
	_output_body.visible = not _locked
	_progress_fill.visible = not _locked
	_apply_tint()

func _apply_tint() -> void:
	if not _locked and _machine:
		_machine.color = Color(tint.r * 0.7, tint.g * 0.7, tint.b * 0.85, 0.9)

func _update_visual() -> void:
	# Pila de raw: altura escala con raw_stock.
	var raw_ratio: float = raw_stock / float(raw_capacity) if raw_capacity > 0 else 0.0
	_raw_pile.size = Vector2(24, 8 + 40 * raw_ratio)
	_raw_pile.position = Vector2(-72, -4 - _raw_pile.size.y / 2.0)
	_raw_pile.color = Color(0.5, 0.4, 0.3, 0.85)
	# Pila de output: brillo escala con output_stock.
	var out_ratio: float = float(output_stock) / float(output_capacity) if output_capacity > 0 else 0.0
	_output_body.color = Color(tint.r * 0.6 + 0.3 * out_ratio, tint.g * 0.6 + 0.3 * out_ratio, tint.b * 0.6 + 0.3 * out_ratio, 0.5 + 0.5 * out_ratio)
	_output_label.text = "%d/%d" % [output_stock, output_capacity]
