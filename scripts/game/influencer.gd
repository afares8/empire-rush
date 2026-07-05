# Influencer — empleado de marketing (capa 4, EMP-1).
# Tercer tipo de empleado con rareza (BLUEPRINT §13: "Maya Marketing —
# atrae 10% más clientes"). Contratable en un pad (Area2D con precio).
# Una vez contratado, registra su multiplicador de poder (según rareza)
# en el grupo "influencers". ClientSpawner lee el multiplicador combinado
# de todos los influencers contratados y reduce spawn_interval en esa
# proporción (más clientes por minuto = más ventas = más cash).
#
# No reusa UnlockPad ni GameManager.unlock_zone: el estado "contratado"
# es local del Influencer para no interferir con MissionGuide (igual que
# Cashier/Stocker, LEARNINGS r13 #1).
class_name Influencer
extends Area2D

# EMP-1: preload para evitar el issue de class_name cross-script
# (LEARNINGS r2).
const EmployeeRarity = preload("res://scripts/game/employee_rarity.gd")

signal hired()

@export var influencer_name: String = "Influencer"
@export var hire_price: float = 300.0
# EMP-1: rareza del empleado ("common"/"rare"/"epic"/"legendary").
@export var rarity: String = "rare"

var _hired: bool = false
var _player_in_area: bool = false
var _player: Node = null
# EMP-1: rareza resuelta (enum) + multiplicador de poder + precio efectivo.
var _rarity_enum: int = 0
var _power_mult: float = 1.0
var _effective_price: float = 300.0

@onready var _body: ColorRect = $Body
@onready var _price_label: Label = $PriceLabel
@onready var _prompt_label: Label = $PromptLabel
@onready var _rarity_label: Label = $RarityLabel

func _ready() -> void:
	add_to_group("influencers")
	_resolve_rarity()
	_price_label.text = "$%d" % int(_effective_price)
	_prompt_label.text = "E para contratar influencer"
	_prompt_label.visible = false
	if _rarity_label:
		_rarity_label.text = "%s · %s" % [EmployeeRarity.name_of(_rarity_enum), EmployeeRarity.influencer_ability_of(_rarity_enum)]
		_rarity_label.add_theme_color_override("font_color", EmployeeRarity.color_of(_rarity_enum))
	_body.color = EmployeeRarity.color_of(_rarity_enum)
	if not _hired:
		_start_pulse()

func _resolve_rarity() -> void:
	_rarity_enum = EmployeeRarity.from_string(rarity)
	_power_mult = EmployeeRarity.power_mult_of(_rarity_enum)
	_effective_price = hire_price * EmployeeRarity.price_mult_of(_rarity_enum)

func is_hired() -> bool:
	return _hired

func get_rarity_enum() -> int:
	return _rarity_enum

func get_power_mult() -> float:
	return _power_mult

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
	_hired = true
	_apply_state()
	emit_signal("hired")
	print("[Influencer] contratado (%s) por $%d (power_mult x%.2f)" % [EmployeeRarity.name_of(_rarity_enum), int(_effective_price), _power_mult])
	return true

func _apply_state() -> void:
	if _hired:
		var rc: Color = EmployeeRarity.color_of(_rarity_enum)
		_body.color = Color(rc.r, rc.g, rc.b, 0.95)
		_price_label.text = "INFLUENCER ✓"
		_prompt_label.visible = false
		var tw: Tween = create_tween()
		tw.tween_property(_body, "scale", Vector2(1.3, 1.3), 0.08) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12) \
			.set_trans(Tween.TRANS_SINE)
	else:
		_price_label.text = "$%d" % int(_effective_price)

func _start_pulse() -> void:
	var rc: Color = EmployeeRarity.color_of(_rarity_enum)
	var dim: Color = Color(rc.r * 0.6, rc.g * 0.6, rc.b * 0.6, 0.55)
	var tw: Tween = create_tween()
	tw.set_loops()
	tw.tween_property(_body, "color", Color(rc.r, rc.g, rc.b, 0.85), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_body, "color", dim, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
