# Business — contenedor de un negocio (capa 3, BIZ-1/2/3).
# Agrupa Pickup(s) + Shelf(s) + UnlockPad opcional. Centraliza la
# config del producto (nombre, precio de venta) y el estado de
# desbloqueo. Cuando el negocio está locked, las shelves se marcan
# locked (el spawner las ignora y el cliente no compra) y los
# pickups se apagan visualmente. Al desbloquear la zona asociada,
# todo se reactiva.
#
# Reutiliza el pad existente como gate (no crea uno nuevo si
# start_locked=false). El patrón está validado en r10 log.
class_name Business
extends Node2D

signal business_unlocked(business_id: String)

@export var business_id: String = "biz_market"
@export var business_name: String = "Puesto Callejero"
@export var product_name: String = "camiseta"
@export var product_value: float = 5.0
@export var start_locked: bool = false
@export var unlock_zone_id: String = ""
@export var unlock_price: float = 0.0
@export var tint: Color = Color(0.55, 0.75, 0.55, 1.0)

var _locked: bool = false

func _ready() -> void:
	_locked = start_locked
	# Si la zona ya estaba desbloqueada (save futuro), forzar unlock.
	if _locked and unlock_zone_id != "" and GameManager.is_zone_unlocked(unlock_zone_id):
		_locked = false
	_apply_state()
	if not GameManager.is_connected("zone_unlocked", _on_zone_unlocked):
		GameManager.zone_unlocked.connect(_on_zone_unlocked)
	print("[Business] %s ready, locked=%s zone=%s" % [business_id, _locked, unlock_zone_id])

func is_locked() -> bool:
	return _locked

# Duck-typing para evitar class_name cross-script (LEARNINGS r2).
func _is_shelf(n: Node) -> bool:
	return n != null and n.has_method("take_item") and n.has_method("has_stock")

func _is_pickup(n: Node) -> bool:
	return n != null and n.has_signal("picked_up")

func _is_pad(n: Node) -> bool:
	return n != null and n.has_method("try_unlock") and n.has_signal("unlocked")

func get_shelves() -> Array:
	var out: Array = []
	for c in get_children():
		if _is_shelf(c):
			out.append(c)
	return out

func _on_zone_unlocked(zone_id: String) -> void:
	if zone_id == unlock_zone_id and _locked:
		_locked = false
		_apply_state()
		emit_signal("business_unlocked", business_id)
		print("[Business] %s unlocked (zone %s)" % [business_id, zone_id])

func _apply_state() -> void:
	for c in get_children():
		if _is_shelf(c):
			c.locked = _locked
			c.product_name = product_name
			c.product_value = product_value
		elif _is_pickup(c):
			c.product_name = product_name
			c.set_process(not _locked)
			c.visible = not _locked
			c.set_deferred("monitoring", not _locked)
		elif _is_pad(c):
			# El pad es el gate del negocio. Solo activo si el negocio
			# está locked y tiene zone_id+price configurados.
			if _locked and unlock_zone_id != "":
				c.zone_id = unlock_zone_id
				c.price = unlock_price
				c.visible = true
				c.set_deferred("monitoring", true)
			else:
				c.visible = false
				c.set_deferred("monitoring", false)
	_apply_tint()

func _apply_tint() -> void:
	# Tinte sutil del cuerpo de cada hijo para distinguir negocios.
	for c in get_children():
		if _is_shelf(c) and c.has_node("Body"):
			var b: ColorRect = c.get_node("Body")
			if not _locked:
				b.color = Color(tint.r, tint.g, tint.b, b.color.a)
		elif _is_pickup(c) and c.has_node("Body"):
			var b2: ColorRect = c.get_node("Body")
			if not _locked:
				b2.color = Color(tint.r * 0.7, tint.g * 0.7, tint.b * 1.0, b2.color.a)
