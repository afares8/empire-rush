# GameManager — singleton de estado global del juego.
# Zonas desbloqueadas, empleados, eventos activos, métricas locales.
extends Node

signal zone_unlocked(zone_id: String)
signal upgrade_purchased(upgrade_type: String, level: int)

var unlocked_zones: Dictionary = {}  # zone_id -> true
# Nivel por tipo de upgrade (capa 4, UPG-1..5). Persistible (SAVE-1).
var upgrades: Dictionary = {}  # upgrade_type -> int level
var active_events: Array = []  # ids de eventos activos
var session_start_time: float = 0.0
var events_played: int = 0
var ads_watched: int = 0

func _ready() -> void:
	session_start_time = Time.get_ticks_msec() / 1000.0

func unlock_zone(zone_id: String) -> void:
	if not unlocked_zones.has(zone_id):
		unlocked_zones[zone_id] = true
		emit_signal("zone_unlocked", zone_id)

func is_zone_unlocked(zone_id: String) -> bool:
	return unlocked_zones.has(zone_id)

# --- Upgrades (capa 4, UPG-1..5) ---
func set_upgrade_level(upgrade_type: String, level: int) -> void:
	upgrades[upgrade_type] = level
	emit_signal("upgrade_purchased", upgrade_type, level)

func get_upgrade_level(upgrade_type: String) -> int:
	return int(upgrades.get(upgrade_type, 0))

func session_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - session_start_time

func log_metrics() -> void:
	print("[METRICS] session_time=%.1fs zones=%d events_played=%d ads_watched=%d" %
		[session_time(), unlocked_zones.size(), events_played, ads_watched])
