# Economy — singleton de economía del jugador.
# Cash + gems + empire_value + reputación. Contadores simples MVP.
extends Node

signal cash_changed(new_cash: float)
signal empire_value_changed(new_value: float)

var cash: float = 0.0
var gems: int = 0
var empire_value: float = 0.0
var reputacion: float = 0.0

func add_cash(amount: float) -> void:
	cash += amount
	if amount > 0.0:
		empire_value += amount * 0.5
	emit_signal("cash_changed", cash)
	emit_signal("empire_value_changed", empire_value)

func spend_cash(amount: float) -> bool:
	if cash < amount:
		return false
	cash -= amount
	emit_signal("cash_changed", cash)
	return true

func add_gems(amount: int) -> void:
	gems += amount

func reset() -> void:
	cash = 0.0
	gems = 0
	empire_value = 0.0
	reputacion = 0.0
	emit_signal("cash_changed", cash)
	emit_signal("empire_value_changed", empire_value)
