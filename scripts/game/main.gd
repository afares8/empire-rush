# Main — escena raíz del juego.
# Por ahora solo arranca el MVP. El loop se construye en capa 2.
extends Node2D

func _ready() -> void:
	print("[Main] Trade Empire Rush — MVP boot")
	# Semilla inicial de economía para que el jugador pueda moverse.
	if Economy.cash == 0.0:
		Economy.add_cash(0.0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
