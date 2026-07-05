# Main — escena raíz del juego.
# Por ahora solo arranca el MVP. El loop se construye en capa 2.
extends Node2D

# EMP-1: preload para reportar rareza en DEVIN_SMOKE (LEARNINGS r2).
const EmployeeRarity = preload("res://scripts/game/employee_rarity.gd")

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
	# Verificar reponedores cargados (capa 4, AUTO-2).
	var stockers: Array = get_tree().get_nodes_in_group("stockers")
	var stockers_hired: int = 0
	for st in stockers:
		if st.has_method("is_hired") and st.is_hired():
			stockers_hired += 1
	print("[Main] Stockers=%d hired=%d" % [stockers.size(), stockers_hired])
	# Verificar pads de upgrade cargados (capa 4, UPG-1..5).
	var upg_pads: Array = get_tree().get_nodes_in_group("upgrade_pads")
	var upg_total_level: int = 0
	for u in upg_pads:
		if u.has_method("get_level"):
			upg_total_level += u.get_level()
	print("[Main] UpgradePads=%d total_level=%d" % [upg_pads.size(), upg_total_level])
	# EMP-1: reportar influencers cargados (capa 4, tercer tipo de empleado).
	var influencers: Array = get_tree().get_nodes_in_group("influencers")
	var influencers_hired: int = 0
	for inf in influencers:
		if inf.has_method("is_hired") and inf.is_hired():
			influencers_hired += 1
	print("[Main] Influencers=%d hired=%d" % [influencers.size(), influencers_hired])
	# EMP-1: reportar rareza y habilidad de cada empleado en boot.
	for ch in cashiers:
		if ch.has_method("get_rarity_enum"):
			print("[Main] cashier %s rarity=%s value_mult=%.2f" % [ch.target_business_id, EmployeeRarity.name_of(ch.get_rarity_enum()), ch.get_value_mult()])
	for st in stockers:
		if st.has_method("get_rarity_enum"):
			print("[Main] stocker %s rarity=%s trip=%.2fs carry=%d" % [st.target_business_id, EmployeeRarity.name_of(st.get_rarity_enum()), st.get_effective_trip_interval(), st.get_effective_carry_per_trip()])
	for inf in influencers:
		if inf.has_method("get_rarity_enum"):
			print("[Main] influencer %s rarity=%s power_mult=%.2f" % [inf.influencer_name, EmployeeRarity.name_of(inf.get_rarity_enum()), inf.get_power_mult()])
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
			Economy.add_cash(5000.0)
		for b in bizs:
			if b.is_locked() and b.has_method("_on_zone_unlocked"):
				var zid: String = b.unlock_zone_id
				if zid != "":
					GameManager.unlock_zone(zid)
					print("[Main] DEVIN_SMOKE: forced unlock zone=%s (%s)" % [zid, b.business_id])
		# Pre-llenar almacén para validar buffer y dar stock al reponedor.
		if warehouse and warehouse.has_method("is_locked") and not warehouse.is_locked():
			warehouse.stock = 20
			warehouse.emit_signal("stock_changed", warehouse.stock)
			print("[Main] DEVIN_SMOKE: warehouse pre-filled stock=20")
		# Contratar el cajero del biz_market para validar cobro automático.
		for ch in cashiers:
			if ch.has_method("try_hire") and not ch.is_hired():
				if ch.try_hire():
					print("[Main] DEVIN_SMOKE: cashier hired for %s" % ch.target_business_id)
		# Drenar los estantes del biz_market a 0 para que el reponedor
		# tenga trabajo visible (los demás quedan pre-llenos para el
		# ciclo de clientes).
		for s in get_tree().get_nodes_in_group("shelves"):
			if "stock" in s and "locked" in s and not s.locked:
				# Identificar shelves del biz_market por product_name
				# (el Business setea product_name="camiseta" en _apply_state).
				if "product_name" in s and s.product_name == "camiseta" and s.get_parent().has_method("is_locked") and s.get_parent().business_id == "biz_market":
					s.stock = 0
					s.emit_signal("stock_changed", s.stock)
		print("[Main] DEVIN_SMOKE: biz_market shelves drained to 0 for stocker")
		# Contratar todos los reponedores para validar reposición automática.
		for st in stockers:
			if st.has_method("try_hire") and not st.is_hired():
				if st.try_hire():
					print("[Main] DEVIN_SMOKE: stocker hired for %s" % st.target_business_id)
		# Comprar 2 niveles de cada upgrade para validar efectos.
		for u in upg_pads:
			if u.has_method("try_buy"):
				for _i in range(2):
					if not u.try_buy():
						break
				print("[Main] DEVIN_SMOKE: upgrade %s -> nivel %d" % [u.upgrade_type, u.get_level()])
		# Reportar efectos aplicados.
		var player_node: Node = get_node_or_null("World/Player")
		if player_node:
			print("[Main] DEVIN_SMOKE: player move_speed=%.1f carry_capacity=%d" % [player_node.move_speed, player_node.carry_capacity])
		var shelf_cap_sample: Node = null
		for s in get_tree().get_nodes_in_group("shelves"):
			if "capacity" in s and "locked" in s and not s.locked:
				shelf_cap_sample = s
				break
		if shelf_cap_sample:
			print("[Main] DEVIN_SMOKE: shelf capacity sample=%d" % shelf_cap_sample.capacity)
		# Reportar producción y cashier_speed aplicados.
		var fnode: Node = get_node_or_null("World/FactoryBIZ4")
		if fnode and "production_time" in fnode:
			print("[Main] DEVIN_SMOKE: factory production_time=%.2f" % fnode.production_time)
		print("[Main] DEVIN_SMOKE: cashier_speed level=%d (browse_time reducido en spawner)" % GameManager.get_upgrade_level("cashier_speed"))
		# EMP-1: contratar todos los influencers para validar boost de
		# spawn de clientes (más clientes = más ventas = más cash).
		for inf in influencers:
			if inf.has_method("try_hire") and not inf.is_hired():
				if inf.try_hire():
					print("[Main] DEVIN_SMOKE: influencer hired (%s)" % inf.influencer_name)
		# Reportar multiplicador combinado de influencers aplicado al spawner.
		var spawner_node: Node = get_node_or_null("World/ClientSpawner")
		if spawner_node and spawner_node.has_method("_influencer_mult"):
			var imult: float = spawner_node._influencer_mult()
			var eff_interval: float = spawner_node.spawn_interval / imult if imult > 0.0 else spawner_node.spawn_interval
			print("[Main] DEVIN_SMOKE: influencer combined mult=x%.2f, effective spawn_interval=%.2fs" % [imult, eff_interval])
		# Reportar reposición del reponedor (AUTO-2) tras esperar varios
		# viajes (trip_interval ~2s → esperar 6s para ~3 viajes). El
		# reporte es diferido para que _process de los stockers corra.
		_report_stocker_smoke.call_deferred()

func _report_stocker_smoke() -> void:
	# Esperar 6s reales (wall-clock) para que los reponedores hagan ~3
	# viajes. NO usar get_tree().create_timer() porque en headless
	# --quit-after el timer basado en delta/process_time no es wall-clock
	# (LEARNINGS r5 confirmada: delta diminuto en headless). Poll con
	# Time.get_ticks_msec() + await process_frame.
	var start_ms: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_ms < 6000:
		await get_tree().process_frame
	var biz_market_stock: int = 0
	for s in get_tree().get_nodes_in_group("shelves"):
		if "stock" in s and "locked" in s and not s.locked:
			if "product_name" in s and s.product_name == "camiseta" and s.get_parent().has_method("is_locked") and s.get_parent().business_id == "biz_market":
				biz_market_stock += s.stock
	print("[Main] DEVIN_SMOKE: biz_market shelf stock=%d (drained=0, restocked by stocker)" % biz_market_stock)
	for st in get_tree().get_nodes_in_group("stockers"):
		if st.has_method("is_hired") and st.is_hired():
			print("[Main] DEVIN_SMOKE: stocker %s units_restocked=%d" % [st.target_business_id, st.get_units_restocked()])
	var wh: Node = get_node_or_null("World/WarehouseBIZ5")
	if wh and "stock" in wh:
		print("[Main] DEVIN_SMOKE: warehouse stock=%d (consumed by stockers)" % wh.stock)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
