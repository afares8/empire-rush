# EmployeeRarity — helper de rareza para empleados (capa 4, EMP-1).
# Define los tiers de rareza (BLUEPRINT §13: común/raro/épico/legendario)
# y la metadata asociada: color de tint, multiplicador de precio de
# contratación, multiplicador de poder (efecto de la habilidad), label
# y texto de habilidad por tipo de empleado.
#
# Cada empleado usa power_mult distinto:
#  - Cashier:    +X% cash por venta en su negocio (cashier_value_mult).
#  - Stocker:    +X% unidades por viaje + trips más frecuentes.
#  - Influencer: +X% tasa de spawn de clientes.
#
# Sin autoload: solo static getters. Evita dependencias de orden de carga.
# NO usa class_name: en Godot 4.3 headless el class_name cross-script
# no se resuelve al parsear (LEARNINGS r2). Los consumidores deben
# hacer `const EmployeeRarity = preload("res://scripts/game/employee_rarity.gd")`.
extends RefCounted

enum Tier { COMMON, RARE, EPIC, LEGENDARY }

# Metadata por tier. power_mult = multiplicador del efecto de la habilidad.
# price_mult = multiplicador del precio de contratación (rarezas altas cuestan más).
static func _meta(tier: int) -> Dictionary:
	match tier:
		Tier.COMMON:
			return {color = Color(0.62, 0.62, 0.62, 1.0), price_mult = 1.0, power_mult = 1.0, label = "Comun"}
		Tier.RARE:
			return {color = Color(0.40, 0.70, 1.00, 1.0), price_mult = 1.5, power_mult = 1.25, label = "Raro"}
		Tier.EPIC:
			return {color = Color(0.85, 0.45, 1.00, 1.0), price_mult = 2.2, power_mult = 1.6, label = "Epico"}
		Tier.LEGENDARY:
			return {color = Color(1.00, 0.75, 0.20, 1.0), price_mult = 3.5, power_mult = 2.0, label = "Legendario"}
		_:
			return {color = Color(0.62, 0.62, 0.62, 1.0), price_mult = 1.0, power_mult = 1.0, label = "Comun"}

# Resuelve un string exportado ("common"/"rare"/"epic"/"legendary") a enum.
static func from_string(s: String) -> int:
	match s.to_lower():
		"rare":
			return Tier.RARE
		"epic":
			return Tier.EPIC
		"legendary", "legend":
			return Tier.LEGENDARY
		_:
			return Tier.COMMON

static func name_of(tier: int) -> String:
	return _meta(tier).label

static func color_of(tier: int) -> Color:
	return _meta(tier).color

static func price_mult_of(tier: int) -> float:
	return _meta(tier).price_mult

static func power_mult_of(tier: int) -> float:
	return _meta(tier).power_mult

# Texto de habilidad por tipo de empleado (visible en el pad, EMP-1 criterio).
static func cashier_ability_of(tier: int) -> String:
	var pct: int = int(round((power_mult_of(tier) - 1.0) * 100.0))
	return "Cobro +%d%%" % pct

static func stocker_ability_of(tier: int) -> String:
	var pct: int = int(round((power_mult_of(tier) - 1.0) * 100.0))
	return "Reposicion +%d%%" % pct

static func influencer_ability_of(tier: int) -> String:
	var pct: int = int(round((power_mult_of(tier) - 1.0) * 100.0))
	return "Clientes +%d%%" % pct
