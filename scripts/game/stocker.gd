# Stocker — empleado reponedor (capa 4, AUTO-2).
# Contratable en un pad (Area2D con precio). Una vez contratado, cada
# trip_interval segundos retira carry_per_trip unidades del almacén
# (Warehouse BIZ-5) y las deposita en un estante del negocio objetivo
# que tenga espacio. Es la segunda automatización: el jugador ya no
# necesita reponer los estantes a mano. Junto con el cajero (AUTO-1),
# un negocio puede operar 100% pasivo. "Mi imperio trabaja por mí"
# (BLUEPRINT §32).
#
# Usa wall-clock (Time.get_ticks_msec) para el timer porque en headless
# --quit-after el delta de _process es diminuto (LEARNINGS r5) y el
# timer nunca llegaría al umbral. Patrón validado en r12 (Factory).
#
# No reusa UnlockPad ni GameManager.unlock_zone: el estado "contratado"
# es local del Stocker para no interferir con MissionGuide (igual que
# Cashier, LEARNINGS r13 #1).
class_name Stocker
extends Area2D

signal hired(business_id: String)

@export var target_business_id: String = "biz_market"
@export var hire_price: float = 120.0
@export var stocker_name: String = "Reponedor"
# Segundos reales entre viajes de reposición.
@export var trip_interval: float = 2.0
# Unidades movidas por viaje (respeta carry_capacity del almacén y
# capacity del estante objetivo).
@export var carry_per_trip: int = 2

var _hired: bool = false
var _player_in_area: bool = false
var _player: Node = null
var _target_shelves: Array = []
var _target_business: Node = null
var _warehouse: Node = null
var _last_trip_ms: int = 0
# Contador de unidades reposidas (para smoke + telemetría futura).
var units_restocked: int = 0

@onready var _body: ColorRect = $Body
@onready var _price_label: Label = $PriceLabel
@onready var _prompt_label: Label = $PromptLabel

func _ready() -> void:
	add_to_group("stockers")
	_price_label.text = "$%d" % int(hire_price)
	_prompt_label.text = "E para contratar reponedor"
	_prompt_label.visible = false
	# Resolver referencias tras un frame para que hijos del Business y
	# el Warehouse ya estén listos (LEARNINGS r8 #2 call_deferred).
	call_deferred("_resolve_references")
	if not _hired:
		_start_pulse()

func _resolve_references() -> void:
	_target_shelves = []
	_target_business = null
	_warehouse = null
	var parent_world: Node = get_parent()
	if parent_world == null:
		return
	for c in parent_world.get_children():
		# Buscar el negocio objetivo (Business o Factory con shelves).
		if c.has_method("is_locked") and "business_id" in c and c.business_id == target_business_id:
			_target_business = c
			for s in c.get_children():
				if s.has_method("take_item") and s.has_method("has_stock") and s.has_method("add_stock"):
					_target_shelves.append(s)
		# Buscar el almacén (cualquier nodo del grupo "warehouses").
	if _warehouse == null:
		for w in get_tree().get_nodes_in_group("warehouses"):
			if w.has_method("is_locked") and not w.is_locked():
				_warehouse = w
				break
	_apply_state()
	if _target_business and _target_business.has_signal("business_unlocked") \
			and not _target_business.is_connected("business_unlocked", _on_business_unlocked):
		_target_business.business_unlocked.connect(_on_business_unlocked)

func _on_business_unlocked(_bid: String) -> void:
	_apply_state()
	# Re-resolver almacén por si acababa de desbloquearse.
	if _warehouse == null:
		for w in get_tree().get_nodes_in_group("warehouses"):
			if w.has_method("is_locked") and not w.is_locked():
				_warehouse = w
				break

func is_hired() -> bool:
	return _hired

func get_target_shelves() -> Array:
	return _target_shelves

func get_units_restocked() -> int:
	return units_restocked

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
	# Si las referencias aún no se resolvieron (call_deferred pendiente),
	# resolver ahora (LEARNINGS r13 #2: API pública llamada desde _ready
	# de otro nodo no puede depender de call_deferred del target).
	if _target_shelves.is_empty():
		_resolve_references()
	_hired = true
	_last_trip_ms = Time.get_ticks_msec()
	_apply_state()
	emit_signal("hired", target_business_id)
	print("[Stocker] contratado para %s por $%d" % [target_business_id, int(hire_price)])
	return true

func _process(_delta: float) -> void:
	if not _hired:
		return
	# Timer wall-clock: robusto en headless --quit-after (LEARNINGS r5).
	var now_ms: int = Time.get_ticks_msec()
	if now_ms - _last_trip_ms < int(trip_interval * 1000.0):
		return
	_last_trip_ms = now_ms
	_do_trip()

# Un viaje: retira del almacén y repone el estante con más espacio.
func _do_trip() -> void:
	if _warehouse == null or not _warehouse.has_method("withdraw"):
		# Re-resolver almacén por si se desbloqueó después.
		for w in get_tree().get_nodes_in_group("warehouses"):
			if w.has_method("is_locked") and not w.is_locked():
				_warehouse = w
				break
	if _warehouse == null:
		return
	# Filtrar shelves activos (no locked) con espacio.
	var candidates: Array = []
	for s in _target_shelves:
		if "locked" in s and not s.locked and "stock" in s and "capacity" in s:
			if s.stock < s.capacity:
				candidates.append(s)
	if candidates.is_empty():
		return
	# Elegir el estante con más espacio (mayor déficit) para reparto uniforme.
	var best: Node = candidates[0]
	var best_space: int = best.capacity - best.stock
	for s in candidates:
		var space: int = s.capacity - s.stock
		if space > best_space:
			best = s
			best_space = space
	# Retirar del almacén (respeta stock disponible).
	var got: int = _warehouse.withdraw(carry_per_trip)
	if got <= 0:
		return
	# Depositar en el estante (respeta capacity).
	var added: int = best.add_stock(got)
	units_restocked += added
	if added > 0:
		_pop()
		print("[Stocker] %s -> %s: +%d (total reposido=%d)" % [target_business_id, best.product_name, added, units_restocked])

func _apply_state() -> void:
	# Si el negocio objetivo está bloqueado y aún no se contrató, el
	# reponedor no está disponible (no se puede reponer un negocio cerrado).
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
		_body.color = Color(0.45, 0.85, 0.55, 0.9)
		_price_label.text = "REPONEDOR ✓"
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
	tw.tween_property(_body, "color", Color(0.55, 0.9, 0.65, 0.85), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_body, "color", Color(0.4, 0.7, 0.5, 0.55), 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _pop() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.15, 0.9), 0.06).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
