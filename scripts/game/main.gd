# Main — escena raíz del juego.
# Por ahora solo arranca el MVP. El loop se construye en capa 2.
extends Node2D

func _ready() -> void:
	print("[Main] Trade Empire Rush — MVP boot")
	# Semilla inicial de economía para que el jugador pueda moverse.
	if Economy.cash == 0.0:
		Economy.add_cash(0.0)
	var player: Node = get_node_or_null("World/Player")
	if player:
		print("[Main] Player spawned at %s" % str(player.position))
	else:
		push_warning("[Main] Player node NOT found")
	# Verificar negocios cargados (capa 3, BIZ-1/2/3 + BIZ-4 taller + BIZ-5 almacén).
	var bizs: Array = []
	for c in get_node("World").get_children():
		if c.has_method("is_locked"):
			bizs.append(c)
	var bizs_locked: int = 0
	for b in bizs:
		if b.is_locked():
			bizs_locked += 1
	print("[Main] Businesses=%d locked=%d" % [bizs.size(), bizs_locked])
	# Conteo específico de taller y almacén.
	var factory: Node = get_node_or_null("World/FactoryBIZ4")
	var warehouse: Node = get_node_or_null("World/WarehouseBIZ5")
	print("[Main] Factory=%s Warehouse=%s" % [factory != null, warehouse != null])
	# Shelves activos (no locked) que el spawner puede usar.
	var active_shelves: int = 0
	for s in get_tree().get_nodes_in_group("shelves"):
		if "locked" in s and not s.locked:
			active_shelves += 1
	print("[Main] Active shelves=%d/%d" % [active_shelves, get_tree().get_nodes_in_group("shelves").size()])
	# Verificar spawner de clientes cargado (loop base, LOOP-5).
	var spawner: Node = get_node_or_null("World/ClientSpawner")
	print("[Main] ClientSpawner=%s" % [spawner != null])
	# Verificar HUD + MissionGuide + pads (LOOP-7/8/9).
	var hud: Node = get_node_or_null("HUD")
	var guide: Node = get_node_or_null("MissionGuide")
	var pads: int = get_tree().get_nodes_in_group("unlock_pads").size()
	print("[Main] HUD=%s MissionGuide=%s UnlockPads=%d" % [hud != null, guide != null, pads])
	# Verificar cajeros cargados (capa 4, AUTO-1).
	var cashiers: Array = get_tree().get_nodes_in_group("cashiers")
	var cashiers_hired: int = 0
	for ch in cashiers:
		if ch.has_method("is_hired") and ch.is_hired():
			cashiers_hired += 1
	print("[Main] Cashiers=%d hired=%d" % [cashiers.size(), cashiers_hired])
	# Debug smoke: pre-llena estantes activos para probar el ciclo de
	# clientes sin requerir input del jugador. Activado por env var
	# DEVIN_SMOKE=1.
	if OS.get_environment("DEVIN_SMOKE") == "1":
		for s in get_tree().get_nodes_in_group("shelves"):
			if "stock" in s and "capacity" in s and "locked" in s and not s.locked:
				s.stock = s.capacity
				s.emit_signal("stock_changed", s.stock)
		print("[Main] DEVIN_SMOKE: active shelves pre-filled")
		# Smoke del pad: dar cash y desbloquear TODOS los negocios locked
		# (BIZ-2/3/4/5) para validar que _on_zone_unlocked reactiva cada uno.
		if Economy:
			Economy.add_cash(2000.0)
		for b in bizs:
			if b.is_locked() and b.has_method("_on_zone_unlocked"):
				var zid: String = b.unlock_zone_id
				if zid != "":
					GameManager.unlock_zone(zid)
					print("[Main] DEVIN_SMOKE: forced unlock zone=%s (%s)" % [zid, b.business_id])
		# Pre-llenar almacén para validar buffer.
		if warehouse and warehouse.has_method("is_locked") and not warehouse.is_locked():
			warehouse.stock = 10
			warehouse.emit_signal("stock_changed", warehouse.stock)
			print("[Main] DEVIN_SMOKE: warehouse pre-filled stock=10")
		# Contratar el cajero del biz_market para validar cobro automático.
		for ch in cashiers:
			if ch.has_method("try_hire") and not ch.is_hired():
				if ch.try_hire():
					print("[Main] DEVIN_SMOKE: cashier hired for %s" % ch.target_business_id)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
