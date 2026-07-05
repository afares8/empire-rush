# HUD — contador de Cash, Empire Value e indicador de misión.
# Esquina superior izquierda. Loop base, LOOP-8.
# Se conecta a las señales de Economy para refrescar en tiempo real.
# MissionGuide actualiza el texto de misión via `set_mission_text()`.
extends CanvasLayer

@onready var _cash_label: Label = $Panel/CashLabel
@onready var _empire_label: Label = $Panel/EmpireLabel
@onready var _mission_label: Label = $Panel/MissionLabel

func _ready() -> void:
	Economy.cash_changed.connect(_on_cash_changed)
	Economy.empire_value_changed.connect(_on_empire_value_changed)
	_refresh_cash(Economy.cash)
	_refresh_empire(Economy.empire_value)

func _on_cash_changed(new_cash: float) -> void:
	_refresh_cash(new_cash)
	# Pop de scale al cambiar cash para que se sienta vivo (juice ligero).
	var tw: Tween = create_tween()
	tw.tween_property(_cash_label, "scale", Vector2(1.18, 1.18), 0.06) \
		.set_trans(Tween.TRANS_SINE)
	tw.tween_property(_cash_label, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_trans(Tween.TRANS_SINE)

func _on_empire_value_changed(new_value: float) -> void:
	_refresh_empire(new_value)

func _refresh_cash(c: float) -> void:
	_cash_label.text = "$%d" % int(c)

func _refresh_empire(v: float) -> void:
	_empire_label.text = "EV %d" % int(v)

# API para MissionGuide (LOOP-9): muestra el texto de la misión actual.
func set_mission_text(text: String) -> void:
	_mission_label.text = text
