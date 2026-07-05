# GameManager — singleton de estado global del juego.
# Zonas desbloqueadas, empleados, eventos activos, métricas locales.
extends Node

signal zone_unlocked(zone_id: String)

var unlocked_zones: Dictionary = {}  # zone_id -> true
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

func session_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - session_start_time

func log_metrics() -> void:
	print("[METRICS] session_time=%.1fs zones=%d events_played=%d ads_watched=%d" %
		[session_time(), unlocked_zones.size(), events_played, ads_watched])
