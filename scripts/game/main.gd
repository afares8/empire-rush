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
	# Verificar pickups cargados (loop base, LOOP-3).
	var pk_a: Node = get_node_or_null("World/PickupA")
	var pk_b: Node = get_node_or_null("World/PickupB")
	print("[Main] Pickups: PickupA=%s PickupB=%s" % [pk_a != null, pk_b != null])
	# Verificar estantes cargados (loop base, LOOP-4).
	var sh_a: Node = get_node_or_null("World/ShelfA")
	var sh_b: Node = get_node_or_null("World/ShelfB")
	print("[Main] Shelves: ShelfA=%s ShelfB=%s" % [sh_a != null, sh_b != null])
	# Verificar spawner de clientes cargado (loop base, LOOP-5).
	var spawner: Node = get_node_or_null("World/ClientSpawner")
	print("[Main] ClientSpawner=%s shelves_group=%d" % [spawner != null, get_tree().get_nodes_in_group("shelves").size()])
	# Verificar HUD + MissionGuide + pads (LOOP-7/8/9).
	var hud: Node = get_node_or_null("HUD")
	var guide: Node = get_node_or_null("MissionGuide")
	var pad_a: Node = get_node_or_null("World/UnlockPadA")
	var pad_b: Node = get_node_or_null("World/UnlockPadB")
	var pad_count: int = int(pad_a != null) + int(pad_b != null)
	print("[Main] HUD=%s MissionGuide=%s UnlockPads=%d" % [hud != null, guide != null, pad_count])
	# Debug smoke: pre-llena estantes para probar el ciclo de clientes
	# sin requerir input del jugador. Activado por env var DEVIN_SMOKE=1.
	if OS.get_environment("DEVIN_SMOKE") == "1":
		for s in get_tree().get_nodes_in_group("shelves"):
			if "stock" in s and "capacity" in s:
				s.stock = s.capacity
				s.emit_signal("stock_changed", s.stock)
		print("[Main] DEVIN_SMOKE: shelves pre-filled")
		# Smoke del pad: dar cash y desbloquear el primer pad.
		if Economy:
			Economy.add_cash(100.0)
		if pad_a and pad_a.has_method("try_unlock"):
			var ok: bool = pad_a.try_unlock()
			print("[Main] DEVIN_SMOKE: pad unlock ok=%s zone=%s" % [ok, pad_a.zone_id if "zone_id" in pad_a else "?"])

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
