# MissionGuide — primer minuto guiado sin tutorial pesado (LOOP-9).
# Avanza por señales del juego (no por tiempo): llena estante → recoge
# dinero → desbloquea zona → (empleados próximamente). Muestra el texto
# en el HUD via `set_mission_text()`. No bloquea el input.
#
# Beats alineados a BLUEPRINT §25:
#   0-10s  FILL_SHELF   "Llena tu primer estante"
#   10-20s COLLECT_MONEY "Recoge tu dinero"
#   20-35s UNLOCK_ZONE  "Invierte para crecer"
#   35-60s HIRE_HELP    "Contrata ayuda" (capa 4, mensaje futuro)
extends Node

enum Step { FILL_SHELF, COLLECT_MONEY, UNLOCK_ZONE, HIRE_HELP, DONE }

var _step: int = Step.FILL_SHELF
var _hud: Node = null

func _ready() -> void:
	# HUD es sibling; usar call_deferred para asegurar que el árbol ya
	# resolvió @onready del HUD.
	call_deferred("_setup")

func _setup() -> void:
	_hud = get_node_or_null("/root/Main/HUD")
	_update_text()
	# Conectar a estantes (avanza FILL_SHELF al primer `stocked`).
	for s in get_tree().get_nodes_in_group("shelves"):
		if s.has_signal("stocked") and not s.is_connected("stocked", _on_shelf_stocked):
			s.stocked.connect(_on_shelf_stocked)
	# Recoger dinero (avanza COLLECT_MONEY).
	if not Economy.is_connected("money_collected", _on_money_collected):
		Economy.money_collected.connect(_on_money_collected)
	# Pads de desbloqueo (avanza UNLOCK_ZONE).
	for p in get_tree().get_nodes_in_group("unlock_pads"):
		if p.has_signal("unlocked") and not p.is_connected("unlocked", _on_zone_unlocked):
			p.unlocked.connect(_on_zone_unlocked)

func _on_shelf_stocked(_amount: int) -> void:
	if _step == Step.FILL_SHELF:
		_advance(Step.COLLECT_MONEY)

func _on_money_collected(_amount: float) -> void:
	if _step == Step.COLLECT_MONEY:
		_advance(Step.UNLOCK_ZONE)

func _on_zone_unlocked(_zone_id: String) -> void:
	if _step == Step.UNLOCK_ZONE:
		_advance(Step.HIRE_HELP)

func _advance(next: int) -> void:
	_step = next
	_update_text()
	print("[MissionGuide] step=%d" % _step)

func _update_text() -> void:
	if _hud == null or not _hud.has_method("set_mission_text"):
		return
	match _step:
		Step.FILL_SHELF:
			_hud.set_mission_text("Recoge producto y presiona E en el estante")
		Step.COLLECT_MONEY:
			_hud.set_mission_text("Recoge el dinero del piso")
		Step.UNLOCK_ZONE:
			_hud.set_mission_text("Invierte: E en el pad amarillo para crecer")
		Step.HIRE_HELP:
			_hud.set_mission_text("Sigue expandiendo. Empleados proximamente!")
		Step.DONE:
			_hud.set_mission_text("")

# API para smoke headless.
func get_step() -> int:
	return _step
