# MoneyDrop — dinero físico en el piso (loop base, LOOP-5/LOOP-6).
# Soltado por el cliente al comprar. Recogible por el jugador al
# caminar sobre él (auto-collect, sin E). Suma al Cash del Economy.
# LOOP-6 añadirá juice (partículas, tween al HUD, sonido); aquí
# solo cierra el loop estante → dinero → cash del jugador.
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
	Economy.add_cash(value)
	queue_free()
