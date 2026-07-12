@tool
extends Node

var step_mm: int = 10
var screw_diameter_mm: int = 4
var guide_diameter_mm: int = 2


var lattice_corner_left = load("res://addons/latticecore/Nodes/Parts/LaticeCornerLeft.gd")

# All the data here must be in milimeters
var servo_data : Dictionary = {
	# MICRO SERVOS
	'SG90': {
		'width': 11.8,
		'height': 22.5,
		'holes': [
			{ 'pos': Vector2(0, -(27.7 / 2)), 'diameter': 2.5 },
			{ 'pos': Vector2(0,  (27.7 / 2)), 'diameter': 2.5 },
		]
	},
	'MG90S': {
		'width': 12.5,
		'height': 24,
		
		'holes': [
			{ 'pos': Vector2(0, -(29 / 2)), 'diameter': 2.5 },
			{ 'pos': Vector2(0,  (29 / 2)), 'diameter': 2.5 },
		]
	},
	'MG90D': {
		'width': 12.5,
		'height': 22.5,

		'holes': [
			{ 'pos': Vector2(0, -(27.7 / 2)), 'diameter': 2.5 },
			{ 'pos': Vector2(0,  (27.7 / 2)), 'diameter': 2.5 },
		]
	},
	
	# MINI SERVOS
	'DS3218': {
		'width': 20,
		'height': 40,

		'holes': [
			{ 'pos': Vector2( 5, -(49.5 / 2)), 'diameter': 2.5 },
			{ 'pos': Vector2(-5, -(49.5 / 2)), 'diameter': 2.5 },
			{ 'pos': Vector2( 5,  (49.5 / 2)), 'diameter': 2.5 },
			{ 'pos': Vector2(-5,  (49.5 / 2)), 'diameter': 2.5 },
		]
	},
	
	'KST X08 S': {
		'width': 8,
		'height': 23.5,

		'holes': [
			{ 'pos': Vector2( 2.5, -(26.5 / 2)), 'diameter': 1.5 },
			{ 'pos': Vector2(-2.5, -(26.5 / 2)), 'diameter': 1.5 },
			{ 'pos': Vector2( 2.5,  (26.5 / 2)), 'diameter': 1.5 },
			{ 'pos': Vector2(-2.5,  (26.5 / 2)), 'diameter': 1.5 },
		]
	},
	'MG995': {
		'width': 20,
		'height': 40.5,

		'holes': [
			{ 'pos': Vector2( 5, -(49 / 2)), 'diameter': 1.5 },
			{ 'pos': Vector2(-5, -(49 / 2)), 'diameter': 1.5 },
			{ 'pos': Vector2( 5,  (49 / 2)), 'diameter': 1.5 },
			{ 'pos': Vector2(-5,  (49 / 2)), 'diameter': 1.5 },
		]
	},
}
