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

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
