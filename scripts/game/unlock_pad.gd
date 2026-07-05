# UnlockPad — pad de desbloqueo de zona (loop base, LOOP-7).
# Area2D con zone_id, price y visual de pulso amarillo. El jugador se
# acerca, ve el precio y un prompt "E para desbloquear $N". Al presionar
# E con Cash >= price, descuenta Cash y registra la zona en GameManager.
# Emite `unlocked(zone_id)` para que MissionGuide/otros reaccionen.
# API pública `try_unlock()` para smoke headless (physics no corre en
# --quit-after, ver LEARNINGS r5).
class_name UnlockPad
extends Area2D

signal unlocked(zone_id: String)

@export var zone_id: String = "zone_1"
@export var price: float = 50.0

var _player_in_area: bool = false
var _player: Node = null
var _done: bool = false

@onready var _body: ColorRect = $Body
@onready var _price_label: Label = $PriceLabel
@onready var _prompt_label: Label = $PromptLabel

func _ready() -> void:
	add_to_group("unlock_pads")
	_price_label.text = "$%d" % int(price)
	_prompt_label.text = "E para desbloquear"
	_prompt_label.visible = false
	if GameManager.is_zone_unlocked(zone_id):
		_mark_done()
	else:
		_start_pulse()

# Duck-typing: evita dependencia de class_name Player (orden de carga).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("add_carried")

func _on_body_entered(body: Node) -> void:
	if _done or not _is_player(body):
		return
	_player_in_area = true
	_player = body
	_prompt_label.visible = true
	if not _player.is_connected("interact_pressed", _on_player_interact):
		_player.interact_pressed.connect(_on_player_interact)

func _on_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	if _player and _player.is_connected("interact_pressed", _on_player_interact):
		_player.interact_pressed.disconnect(_on_player_interact)
	_player_in_area = false
	_player = null
	_prompt_label.visible = false

func _on_player_interact() -> void:
	try_unlock()

# API pública para smoke headless (no requiere input E ni physics tick).
func try_unlock() -> bool:
	if _done:
		return false
	if Economy.cash < price:
		return false
	if not Economy.spend_cash(price):
		return false
	GameManager.unlock_zone(zone_id)
	_mark_done()
	emit_signal("unlocked", zone_id)
	print("[UnlockPad] zona %s desbloqueada por $%d" % [zone_id, int(price)])
	return true

func _mark_done() -> void:
	_done = true
	_prompt_label.visible = false
	_body.color = Color(0.3, 0.9, 0.4, 0.5)
	_price_label.text = "OK"
	# Pop táctil al desbloquear.
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.3, 1.3), 0.08) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12) \
		.set_trans(Tween.TRANS_SINE)

# Pulso suave para llamar la atención del jugador (meta cercana visible).
func _start_pulse() -> void:
	var tw: Tween = create_tween()
	tw.set_loops()
	tw.tween_property(_body, "color", Color(1.0, 0.85, 0.2, 0.85), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_body, "color", Color(0.95, 0.75, 0.15, 0.55), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
