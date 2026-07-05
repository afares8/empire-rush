# MoneyDrop — dinero físico en el piso (loop base, LOOP-5/LOOP-6).
# Soltado por el cliente al comprar. Recogible por el jugador al
# caminar sobre él (auto-collect, sin E). Suma al Cash del Economy.
# JUICE-1/POLISH-1/2: partículas + pop + cash volando al HUD + SFX.
class_name MoneyDrop
extends Area2D

@export var value: float = 5.0

@onready var _body: ColorRect = $Body
@onready var _label: Label = $ValueLabel

func _ready() -> void:
	_label.text = "$%d" % int(value)
	# Pop-in al aparecer.
	_body.scale = Vector2(0.1, 0.1)
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Duck-typing: detecta al jugador por sus métodos (convención del repo).
func _is_player(body: Node) -> bool:
	return body != null and body.has_method("add_carried")

func _on_body_entered(body: Node) -> void:
	if not _is_player(body):
		return
	# Juice: partículas + cash volando + sonido + pop del body.
	var pos: Vector2 = global_position
	if Juice:
		Juice.money_burst(pos)
		Juice.fly_cash(pos, value)
		Juice.play_pickup()
	# Pop de scale antes de desaparecer para feel táctil.
	var tw: Tween = create_tween()
	tw.tween_property(_body, "scale", Vector2(1.6, 1.6), 0.08) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_body, "modulate:a", 0.0, 0.08)
	tw.tween_callback(_finish_collect)

func _finish_collect() -> void:
	Economy.add_cash(value)
	queue_free()
