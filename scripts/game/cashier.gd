# Cashier — empleado cajero (capa 4, AUTO-1).
# Contratable en un pad (Area2D con precio). Una vez contratado, los
# clientes que compran en los estantes del negocio objetivo pagan
# automáticamente al Economy (sin soltar MoneyDrop al piso). Es la
# primera automatización: el jugador ya no necesita recoger el dinero
# de ese negocio a mano. "Mi imperio trabaja por mí" (BLUEPRINT §32).
#
# No reusa UnlockPad: el estado de "contratado" es local del Cashier
# (no registra zona en GameManager) para no interferir con
# MissionGuide, que escucha zone_unlocked para avanzar sus beats.
class_name Cashier
extends Area2D

signal hired(business_id: String)

@export var target_business_id: String = "biz_market"
@export var hire_price: float = 100.0
@export var cashier_name: String = "Cajero"

var _hired: bool = false
var _player_in_area: bool = false
var _player: Node = null
var _target_shelves: Array = []
var _target_business: Node = null

@onready var _body: ColorRect = $Body
@onready var _price_label: Label = $PriceLabel
@onready var _prompt_label: Label = $PromptLabel

func _ready() -> void:
	add_to_group("cashiers")
	_price_label.text = "$%d" % int(hire_price)
	_prompt_label.text = "E para contratar cajero"
	_prompt_label.visible = false
	# Resolver estantes del negocio objetivo tras un frame para que
	# todos los hijos del Business ya estén listos.
	call_deferred("_resolve_target_shelves")
	if not _hired:
		_start_pulse()

func _resolve_target_shelves() -> void:
	_target_shelves = []
	_target_business = null
	var parent_world: Node = get_parent()
	if parent_world == null:
		return
	for c in parent_world.get_children():
		if c.has_method("is_locked") and "business_id" in c and c.business_id == target_business_id:
			_target_business = c
			for s in c.get_children():
				if s.has_method("take_item") and s.has_method("has_stock"):
					_target_shelves.append(s)
			break
	_apply_state()
	# Re-mostrar el pad cuando el negocio objetivo se desbloquee.
	if _target_business and _target_business.has_signal("business_unlocked") \
			and not _target_business.is_connected("business_unlocked", _on_business_unlocked):
		_target_business.business_unlocked.connect(_on_business_unlocked)

func _on_business_unlocked(_bid: String) -> void:
	_apply_state()

func is_hired() -> bool:
	return _hired

func get_target_shelves() -> Array:
	return _target_shelves

# Duck-typing: evita dependencia de class_name Player (orden de carga).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("add_carried")

func _on_body_entered(body: Node) -> void:
	if _hired or not _is_player(body):
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
	try_hire()

# API pública para smoke headless (no requiere input E ni physics tick).
func try_hire() -> bool:
	if _hired:
		return false
	if Economy.cash < hire_price:
		return false
	if not Economy.spend_cash(hire_price):
		return false
	# Si los estantes objetivo aún no se resolvieron (call_deferred pendiente),
	# resolver ahora para que _apply_state marque las shelves correctamente.
	if _target_shelves.is_empty():
		_resolve_target_shelves()
	_hired = true
	_apply_state()
	emit_signal("hired", target_business_id)
	print("[Cashier] contratado para %s por $%d" % [target_business_id, int(hire_price)])
	return true

func _apply_state() -> void:
	# Marcar los estantes del negocio objetivo con servicio de cajero.
	for s in _target_shelves:
		if "has_cashier" in s:
			s.has_cashier = _hired
	# Si el negocio objetivo está bloqueado y aún no se contrató, el
	# cajero no está disponible (no se puede cobrar en un negocio cerrado).
	var biz_locked: bool = _target_business != null \
		and _target_business.has_method("is_locked") \
		and _target_business.is_locked()
	if biz_locked and not _hired:
		visible = false
		set_deferred("monitoring", false)
		_prompt_label.visible = false
		return
	visible = true
	set_deferred("monitoring", true)
	if _hired:
		_body.color = Color(0.3, 0.85, 0.45, 0.9)
		_price_label.text = "CAJERO ✓"
		_prompt_label.visible = false
		# Pop táctil al contratar.
		var tw: Tween = create_tween()
		tw.tween_property(_body, "scale", Vector2(1.3, 1.3), 0.08) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12) \
			.set_trans(Tween.TRANS_SINE)
	else:
		_price_label.text = "$%d" % int(hire_price)

# Pulso suave para llamar la atención del jugador (meta cercana visible).
func _start_pulse() -> void:
	var tw: Tween = create_tween()
	tw.set_loops()
	tw.tween_property(_body, "color", Color(0.55, 0.8, 0.95, 0.85), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_body, "color", Color(0.4, 0.65, 0.85, 0.55), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
