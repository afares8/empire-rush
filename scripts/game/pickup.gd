# Pickup — fuente de producto en el mapa (loop base, LOOP-3).
# Nodo Area2D con stock que se regenera. El jugador entra en el área,
# presiona E y carga 1 unidad (respeta carry_capacity del jugador).
# Visual: cuerpo ColorRect cuyo fill refleja el stock disponible.
class_name Pickup
extends Area2D

signal picked_up(amount: int)

@export var max_stock: int = 5
@export var regen_per_sec: float = 1.0
@export var product_name: String = "camiseta"

var stock: float = 5.0
var _player_in_area: bool = false
var _player: Node = null

@onready var _body: ColorRect = $Body
@onready var _stock_label: Label = $StockLabel

func _ready() -> void:
	stock = float(max_stock)
	_update_visual()
	_refresh_stock_label_pos()

func _physics_process(delta: float) -> void:
	if stock < float(max_stock):
		stock = min(float(max_stock), stock + regen_per_sec * delta)
		_update_visual()

# Duck-typing: evita dependencia de class_name Player (orden de carga).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("can_carry") and body.has_method("add_carried")

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
	if stock < 1.0:
		return
	if not _player.can_carry():
		return
	var taken: int = _player.add_carried(1)
	if taken > 0:
		stock -= float(taken)
		_update_visual()
		emit_signal("picked_up", taken)
		# Pop táctil al recoger.
		var tw: Tween = create_tween()
		tw.tween_property(_body, "scale", Vector2(1.18, 0.85), 0.06).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _update_visual() -> void:
	# El brillo del cuerpo refleja cuánto stock queda.
	var ratio: float = stock / float(max_stock) if max_stock > 0 else 0.0
	_body.color = Color(0.35, 0.55, 0.9, 0.4 + 0.6 * ratio)
	_stock_label.text = "%d/%d" % [int(ceil(stock)), max_stock]

func _refresh_stock_label_pos() -> void:
	_stock_label.position = Vector2(-22, -56)
