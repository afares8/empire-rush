# Shelf — estante/mostrador reponible (loop base, LOOP-4).
# Nodo Area2D con stock y capacity. El jugador entra en el área con
# producto cargado, presiona E y descarga 1 unidad (respeta capacity
# del estante y carried del jugador). Visual: fill level del cuerpo.
# Expone `take_item()` y señal `stock_changed` para que LOOP-5
# (cliente) compre del estante sin rework.
class_name Shelf
extends Area2D

signal stock_changed(new_stock: int)
signal stocked(amount: int)

@export var capacity: int = 6
@export var product_name: String = "camiseta"

var stock: int = 0
var locked: bool = false
var product_value: float = 5.0
var _player_in_area: bool = false
var _player: Node = null

@onready var _body: ColorRect = $Body
@onready var _stock_label: Label = $StockLabel

func _ready() -> void:
	_update_visual()

# Duck-typing: evita dependencia de class_name Player (orden de carga).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("remove_carried") and body.has_method("can_carry")

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
	if not _player_in_area or _player == null:
		return
	if locked:
		return
	if stock >= capacity:
		return
	if _player.carried <= 0:
		return
	var dropped: int = _player.remove_carried(1)
	if dropped <= 0:
		return
	stock += dropped
	emit_signal("stock_changed", stock)
	emit_signal("stocked", dropped)
	_update_visual()
	# Pop táctil al reponer.
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.15, 0.88), 0.06).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

# API para LOOP-5 (cliente): consume 1 unidad del estante.
# Devuelve cuántas realmente tomó (0 si vacío o locked).
func take_item(n: int = 1) -> int:
	if locked:
		return 0
	var to_take: int = clamp(n, 0, stock)
	if to_take <= 0:
		return 0
	stock -= to_take
	emit_signal("stock_changed", stock)
	_update_visual()
	return to_take

func is_empty() -> bool:
	return stock <= 0

func has_stock() -> bool:
	return stock > 0 and not locked

func _update_visual() -> void:
	# Fill level: de rojo apagado (vacío) a verde brillante (lleno).
	var ratio: float = float(stock) / float(capacity) if capacity > 0 else 0.0
	if locked:
		_body.color = Color(0.3, 0.3, 0.3, 0.4)
		_stock_label.text = "LOCKED"
		return
	_body.color = Color(0.85 - 0.45 * ratio, 0.35 + 0.55 * ratio, 0.3, 0.55 + 0.45 * ratio)
	_stock_label.text = "%d/%d" % [stock, capacity]
