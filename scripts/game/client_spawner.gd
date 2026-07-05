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
	_shelves = get_tree().get_nodes_in_group("shelves")

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() >= _next_spawn_ms:
		_next_spawn_ms = Time.get_ticks_msec() + int(spawn_interval * 1000.0)
		_try_spawn()

func _try_spawn() -> void:
	if _shelves.is_empty():
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
	print("[Spawner] spawned client -> shelf %s (clients=%d)" % [shelf.name, get_tree().get_nodes_in_group("clients").size()])
