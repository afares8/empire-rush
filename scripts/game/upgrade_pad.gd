# UpgradePad — pad de mejora reutilizable (capa 4, UPG-1/2/3).
# Area2D con tipo de upgrade, nivel actual y precio escalado por nivel.
# El jugador se acerca, ve el nombre, nivel y precio; presiona E para
# comprar si Cash >= precio. Sube de nivel, escala el precio y aplica
# el efecto. API pública `try_buy()` para smoke headless (physics no
# corre en --quit-after, ver LEARNINGS r5).
#
# Tipos soportados:
# - "speed":         +12% move_speed base del Player por nivel.
# - "carry":         +2 carry_capacity base del Player por nivel.
# - "shelf_cap":     +3 capacity en TODOS los estantes activos por nivel.
# - "cashier_speed": reduce browse_time de clientes (lo lee el spawner
#                    vía GameManager.get_upgrade_level). Caja más rápida.
# - "production":    -10% production_time de TODAS las fábricas por nivel.
#
# No reusa UnlockPad: el estado de "nivel" es local del UpgradePad.
# Registra el nivel en GameManager solo si el método existe (forward-
# compat con SAVE-1); no falla si no está.
class_name UpgradePad
extends Area2D

signal purchased(upgrade_type: String, new_level: int)

@export var upgrade_type: String = "speed" # "speed"|"carry"|"shelf_cap"|"cashier_speed"|"production"
@export var upgrade_name: String = "Velocidad"
@export var base_price: float = 80.0
@export var max_level: int = 5
@export var price_growth: float = 1.6 # precio_n = base * growth^(nivel)

var _level: int = 0
var _player_in_area: bool = false
var _player: Node = null

@onready var _body: ColorRect = $Body
@onready var _price_label: Label = $PriceLabel
@onready var _name_label: Label = $NameLabel
@onready var _level_label: Label = $LevelLabel
@onready var _prompt_label: Label = $PromptLabel

func _ready() -> void:
	add_to_group("upgrade_pads")
	_name_label.text = upgrade_name
	_prompt_label.text = "E para mejorar"
	_prompt_label.visible = false
	_refresh()
	if not is_maxed():
		_start_pulse()

# Precio del siguiente nivel (nivel 0 = base, sube geométrico).
func next_price() -> float:
	return base_price * pow(price_growth, float(_level))

func is_maxed() -> bool:
	return _level >= max_level

func get_level() -> int:
	return _level

# Duck-typing: evita dependencia de class_name Player (orden de carga).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("add_carried")

func _on_body_entered(body: Node) -> void:
	if is_maxed() or not _is_player(body):
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
	try_buy()

# API pública para smoke headless (no requiere input E ni physics tick).
func try_buy() -> bool:
	if is_maxed():
		return false
	var price: float = next_price()
	if Economy.cash < price:
		return false
	if not Economy.spend_cash(price):
		return false
	_level += 1
	# Registrar en GameManager solo si el método existe (forward-compat
	# con SAVE-1). No falla si no está implementado aún.
	if GameManager.has_method("set_upgrade_level"):
		GameManager.set_upgrade_level(upgrade_type, _level)
	_apply_effect()
	_refresh()
	emit_signal("purchased", upgrade_type, _level)
	# JUICE-1: SFX + shake ligero al comprar upgrade.
	if Juice:
		Juice.play_buy()
		Juice.shake(3.0, 0.18)
	print("[UpgradePad] %s -> nivel %d por $%d" % [upgrade_type, _level, int(price)])
	return true

# Aplica el efecto al objetivo correspondiente. Resuelve el Player
# sincrónico si no vino por body_entered (smoke headless).
func _apply_effect() -> void:
	match upgrade_type:
		"speed":
			var p: Node = _resolve_player()
			if p and "move_speed" in p:
				if not p.has_meta("base_move_speed"):
					p.set_meta("base_move_speed", p.get("move_speed"))
				var base: float = float(p.get_meta("base_move_speed"))
				p.set("move_speed", base * pow(1.12, float(_level)))
		"carry":
			var p2: Node = _resolve_player()
			if p2 and "carry_capacity" in p2:
				if not p2.has_meta("base_carry_capacity"):
					p2.set_meta("base_carry_capacity", p2.get("carry_capacity"))
				var base_c: int = int(p2.get_meta("base_carry_capacity"))
				p2.set("carry_capacity", base_c + 2 * _level)
				if p2.has_method("_update_carry_visual"):
					p2._update_carry_visual()
		"shelf_cap":
			# +3 capacity a todos los estantes activos (no locked).
			for s in get_tree().get_nodes_in_group("shelves"):
				if s and "capacity" in s and "locked" in s and not s.locked:
					if not s.has_meta("base_capacity"):
						s.set_meta("base_capacity", s.get("capacity"))
					var base_cap: int = int(s.get_meta("base_capacity"))
					s.set("capacity", base_cap + 3 * _level)
					if s.has_method("_update_visual"):
						s._update_visual()
		"cashier_speed":
			# No aplica sobre nodos existentes: el ClientSpawner lee
			# GameManager.get_upgrade_level("cashier_speed") al crear
			# cada cliente y reduce su browse_time. Caja más rápida.
			pass
		"production":
			# -10% production_time por nivel (mín 0.4s) en todas las
			# fábricas. Patrón base-meta como speed/carry/shelf_cap.
			for f in get_tree().get_nodes_in_group("factories"):
				if f and "production_time" in f:
					if not f.has_meta("base_production_time"):
						f.set_meta("base_production_time", f.get("production_time"))
					var base_pt: float = float(f.get_meta("base_production_time"))
					f.set("production_time", max(0.4, base_pt * (1.0 - 0.1 * float(_level))))
		_:
			pass

func _resolve_player() -> Node:
	if _player != null and is_instance_valid(_player):
		return _player
	# Fallback: buscar por nombre en World (padre del pad).
	var w: Node = get_parent()
	if w:
		for c in w.get_children():
			if c.has_method("add_carried"):
				return c
	return null

func _refresh() -> void:
	_level_label.text = "Lv %d/%d" % [_level, max_level]
	if is_maxed():
		_price_label.text = "MAX"
		_body.color = Color(0.95, 0.8, 0.25, 0.7)
		_prompt_label.visible = false
		# Pop táctil al maxear.
		var tw: Tween = create_tween()
		tw.tween_property(_body, "scale", Vector2(1.3, 1.3), 0.08) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12) \
			.set_trans(Tween.TRANS_SINE)
	else:
		_price_label.text = "$%d" % int(next_price())
		# Pop táctil al comprar.
		var tw2: Tween = create_tween()
		tw2.tween_property(_body, "scale", Vector2(1.25, 1.25), 0.08) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw2.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.12) \
			.set_trans(Tween.TRANS_SINE)

# Pulso suave para llamar la atención del jugador (meta cercana visible).
func _start_pulse() -> void:
	var tw: Tween = create_tween()
	tw.set_loops()
	tw.tween_property(_body, "color", Color(0.55, 0.85, 0.6, 0.85), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_body, "color", Color(0.4, 0.7, 0.5, 0.55), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
