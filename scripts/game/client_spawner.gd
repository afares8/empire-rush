# ClientSpawner — spawnea clientes periódicamente (loop base, LOOP-5).
# Busca estantes del grupo "shelves" y asigna uno aleatorio a cada
# cliente. Limita el número de clientes concurrentes para evitar
# abrumar al jugador (caos controlado, ver BLUEPRINT §26).
# Usa _process + Time.get_ticks_msec (no _physics_process ni delta
# acumulado): en headless --quit-after los physics ticks no corren y
# el delta por frame es diminuto (FPS sin cap), así que el timer
# basado en delta nunca llega al umbral. Tiempo real es robusto.
class_name ClientSpawner
extends Node2D

@export var spawn_interval: float = 3.0
@export var max_clients: int = 5
@export var spawn_pos: Vector2 = Vector2(400, -300)
@export var exit_pos: Vector2 = Vector2(450, -350)

var _shelves: Array = []
var _next_spawn_ms: int = 0
var _client_scene: PackedScene = preload("res://scenes/Client.tscn")

func _ready() -> void:
	_refresh_shelves()
	_next_spawn_ms = Time.get_ticks_msec() + int(spawn_interval * 1000.0)

func _refresh_shelves() -> void:
	# Filtrar shelves locked (negocios no desbloqueados, BIZ-2/3).
	var all: Array = get_tree().get_nodes_in_group("shelves")
	_shelves = []
	for s in all:
		if "locked" in s and s.locked:
			continue
		_shelves.append(s)

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() >= _next_spawn_ms:
		# EMP-1: influencers contratados reducen el intervalo de spawn
		# (más clientes por minuto). El multiplicador combinado es el
		# producto de los power_mult de cada influencer contratado.
		var interval: float = spawn_interval / _influencer_mult()
		_next_spawn_ms = Time.get_ticks_msec() + int(interval * 1000.0)
		_try_spawn()

# EMP-1: multiplicador combinado de influencers contratados (>= 1.0).
func _influencer_mult() -> float:
	var mult: float = 1.0
	for inf in get_tree().get_nodes_in_group("influencers"):
		if inf.has_method("is_hired") and inf.is_hired() and inf.has_method("get_power_mult"):
			mult *= inf.get_power_mult()
	return mult

func _try_spawn() -> void:
	# Refrescar siempre: negocios pueden desbloquearse mid-sesión.
	_refresh_shelves()
	if _shelves.is_empty():
		return
	var count: int = get_tree().get_nodes_in_group("clients").size()
	if count >= max_clients:
		return
	var shelf: Node = _shelves[randi() % _shelves.size()]
	var client: Node = _client_scene.instantiate()
	get_parent().add_child(client)
	client.setup(shelf, spawn_pos, exit_pos)
	# UPG-4 (cashier_speed): cada nivel reduce browse_time 15% (mín 0.1s).
	var csl: int = GameManager.get_upgrade_level("cashier_speed")
	if csl > 0 and "browse_time" in client:
		client.browse_time = max(0.1, client.browse_time * (1.0 - 0.15 * float(csl)))
	print("[Spawner] spawned client -> shelf %s (clients=%d)" % [shelf.name, get_tree().get_nodes_in_group("clients").size()])
