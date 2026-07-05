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

# EMP-1: preload para evitar el issue de class_name cross-script
# (LEARNINGS r2).
const EmployeeRarity = preload("res://scripts/game/employee_rarity.gd")

signal hired(business_id: String)

@export var target_business_id: String = "biz_market"
@export var hire_price: float = 100.0
@export var cashier_name: String = "Cajero"
# EMP-1: rareza del empleado ("common"/"rare"/"epic"/"legendary").
# Afecta color, precio final, multiplicador de valor de venta y
# texto visible de habilidad.
@export var rarity: String = "common"

var _hired: bool = false
var _player_in_area: bool = false
var _player: Node = null
var _target_shelves: Array = []
var _target_business: Node = null
# EMP-1: rareza resuelta (enum) + multiplicador de potencia.
var _rarity_enum: int = 0
var _value_mult: float = 1.0
# Precio efectivo tras aplicar multiplicador de rareza.
var _effective_price: float = 100.0

@onready var _body: ColorRect = $Body
@onready var _price_label: Label = $PriceLabel
@onready var _prompt_label: Label = $PromptLabel
@onready var _rarity_label: Label = $RarityLabel

func _ready() -> void:
	add_to_group("cashiers")
	_resolve_rarity()
	_price_label.text = "$%d" % int(_effective_price)
	_prompt_label.text = "E para contratar cajero"
	_prompt_label.visible = false
	# Etiqueta de rareza + habilidad visible siempre (EMP-1 criterio).
	if _rarity_label:
		_rarity_label.text = "%s · %s" % [EmployeeRarity.name_of(_rarity_enum), EmployeeRarity.cashier_ability_of(_rarity_enum)]
		_rarity_label.add_theme_color_override("font_color", EmployeeRarity.color_of(_rarity_enum))
	# Tint del cuerpo con el color de rareza.
	_body.color = EmployeeRarity.color_of(_rarity_enum)
	# Resolver estantes del negocio objetivo tras un frame para que
	# todos los hijos del Business ya estén listos.
	call_deferred("_resolve_target_shelves")
	if not _hired:
		_start_pulse()

# EMP-1: resuelve la rareza desde el string exportado y deriva
# multiplicador de potencia + precio efectivo.
func _resolve_rarity() -> void:
	_rarity_enum = EmployeeRarity.from_string(rarity)
	_value_mult = EmployeeRarity.power_mult_of(_rarity_enum)
	_effective_price = hire_price * EmployeeRarity.price_mult_of(_rarity_enum)

func get_value_mult() -> float:
	return _value_mult

func get_rarity_enum() -> int:
	return _rarity_enum

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
	if Economy.cash < _effective_price:
		return false
	if not Economy.spend_cash(_effective_price):
		return false
	# Si los estantes objetivo aún no se resolvieron (call_deferred pendiente),
	# resolver ahora para que _apply_state marque las shelves correctamente.
	if _target_shelves.is_empty():
		_resolve_target_shelves()
	_hired = true
	_apply_state()
	emit_signal("hired", target_business_id)
	print("[Cashier] contratado (%s) para %s por $%d (mult x%.2f)" % [EmployeeRarity.name_of(_rarity_enum), target_business_id, int(_effective_price), _value_mult])
	return true

func _apply_state() -> void:
	# Marcar los estantes del negocio objetivo con servicio de cajero +
	# el multiplicador de valor de venta por rareza (EMP-1).
	for s in _target_shelves:
		if "has_cashier" in s:
			s.has_cashier = _hired
		if "cashier_value_mult" in s:
			s.cashier_value_mult = _value_mult if _hired else 1.0
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
		# EMP-1: al contratar, el cuerpo adopta el color de rareza más
		# brillante para distinguir empleados contratados por rareza.
		var rc: Color = EmployeeRarity.color_of(_rarity_enum)
		_body.color = Color(rc.r, rc.g, rc.b, 0.95)
		_price_label.text = "CAJERO ✓"
		_prompt_label.visible = false
		# Pop táctil al contratar.
		var tw: Tween = create_tween()
		tw.tween_property(_body, "scale", Vector2(1.3, 1.3), 0.08) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12) \
			.set_trans(Tween.TRANS_SINE)
	else:
		_price_label.text = "$%d" % int(_effective_price)

# Pulso suave para llamar la atención del jugador (meta cercana visible).
# EMP-1: el pulso oscila entre el color de rareza y una versión atenuada.
func _start_pulse() -> void:
	var rc: Color = EmployeeRarity.color_of(_rarity_enum)
	var dim: Color = Color(rc.r * 0.6, rc.g * 0.6, rc.b * 0.6, 0.55)
	var tw: Tween = create_tween()
	tw.set_loops()
	tw.tween_property(_body, "color", Color(rc.r, rc.g, rc.b, 0.85), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_body, "color", dim, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
