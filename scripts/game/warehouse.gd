# Warehouse — mini almacén (capa 3, BIZ-5).
# Nodo de almacenamiento central. El jugador deposita producto cargado
# (E cerca del almacén con carried > 0) o recoge producto (E con
# carried < capacity y stock > 0). Actúa como buffer de logística:
# permite acumular producto de pickups/fábrica y distribuirlo después
# a los estantes. Conecta al loop sin romper la mecánica de carried.
# Puede estar locked al inicio (gate via UnlockPad + GameManager).
class_name Warehouse
extends Area2D

signal stock_changed(new_stock: int)
signal business_unlocked(business_id: String)

@export var business_id: String = "biz_warehouse"
@export var business_name: String = "Almacén"
@export var capacity: int = 20
@export var tint: Color = Color(0.7, 0.65, 0.45, 1.0)
@export var start_locked: bool = false
@export var unlock_zone_id: String = ""
@export var unlock_price: float = 0.0

var stock: int = 0
var _locked: bool = false
var _player_in_area: bool = false
var _player: Node = null

@onready var _body: ColorRect = $Body
@onready var _stock_label: Label = $StockLabel

func _ready() -> void:
	add_to_group("warehouses")
	_locked = start_locked
	if _locked and unlock_zone_id != "" and GameManager.is_zone_unlocked(unlock_zone_id):
		_locked = false
	_apply_state()
	if not GameManager.is_connected("zone_unlocked", _on_zone_unlocked):
		GameManager.zone_unlocked.connect(_on_zone_unlocked)
	_update_visual()

func is_locked() -> bool:
	return _locked

# Duck-typing: evita dependencia de class_name Player (LEARNINGS r2).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("can_carry") and body.has_method("add_carried") and body.has_method("remove_carried")

func _is_pad(n: Node) -> bool:
	return n != null and n.has_method("try_unlock") and n.has_signal("unlocked")

func _on_zone_unlocked(zone_id: String) -> void:
	if zone_id == unlock_zone_id and _locked:
		_locked = false
		_apply_state()
		emit_signal("business_unlocked", business_id)
		print("[Warehouse] %s unlocked (zone %s)" % [business_id, zone_id])

func _on_body_entered(body: Node) -> void:
	if not _is_player(body):
		return
	_player_in_area = true
	_player = body
	if not _player.is_connected("interact_pressed", _on_player_interact):
		_player.interact_pressed.connect(_on_player_interact)

func _on_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	if _player and _player.is_connected("interact_pressed", _on_player_interact):
		_player.interact_pressed.disconnect(_on_player_interact)
	_player_in_area = false
	_player = null

func _on_player_interact() -> void:
	if not _player_in_area or _player == null or _locked:
		return
	# Prioridad: si el jugador lleva producto, deposita (libera capacidad
	# de carga para seguir recogiendo). Si no lleva nada, recoge del stock.
	if _player.carried > 0:
		_deposit()
	else:
		_withdraw()

func _deposit() -> void:
	var space: int = capacity - stock
	if space <= 0:
		return
	var to_drop: int = _player.remove_carried(space)
	if to_drop <= 0:
		return
	stock += to_drop
	emit_signal("stock_changed", stock)
	_update_visual()
	_pop()

func _withdraw() -> void:
	if stock <= 0:
		return
	if not _player.can_carry():
		return
	var space: int = _player.carry_capacity - _player.carried
	var to_take: int = clamp(min(space, stock), 0, _player.carry_capacity)
	if to_take <= 0:
		return
	var taken: int = _player.add_carried(to_take)
	if taken > 0:
		stock -= taken
		emit_signal("stock_changed", stock)
		_update_visual()
		_pop()

func _pop() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.12, 0.9), 0.06).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _apply_state() -> void:
	# Apagar interacción si locked.
	set_deferred("monitoring", not _locked)
	for c in get_children():
		if _is_pad(c):
			if _locked and unlock_zone_id != "":
				c.zone_id = unlock_zone_id
				c.price = unlock_price
				c.visible = true
				c.set_deferred("monitoring", true)
			else:
				c.visible = false
				c.set_deferred("monitoring", false)
	_update_visual()

# API pública para smoke headless (no requiere input E ni physics tick).
func deposit(amount: int) -> int:
	var space: int = capacity - stock
	var to_drop: int = clamp(amount, 0, space)
	stock += to_drop
	emit_signal("stock_changed", stock)
	_update_visual()
	return to_drop

func withdraw(amount: int) -> int:
	var to_take: int = clamp(amount, 0, stock)
	stock -= to_take
	emit_signal("stock_changed", stock)
	_update_visual()
	return to_take

func _update_visual() -> void:
	var ratio: float = float(stock) / float(capacity) if capacity > 0 else 0.0
	if _locked:
		_body.color = Color(0.3, 0.3, 0.3, 0.4)
		_stock_label.text = "LOCKED"
		return
	_body.color = Color(tint.r - 0.2 + 0.3 * ratio, tint.g - 0.15 + 0.3 * ratio, tint.b - 0.1 + 0.2 * ratio, 0.55 + 0.45 * ratio)
	_stock_label.text = "Almacén\n%d/%d" % [stock, capacity]
