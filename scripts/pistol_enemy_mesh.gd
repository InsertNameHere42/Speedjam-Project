extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree

func isAiming(inp : bool):
	animation_tree["parameters/conditions/isAiming"] = inp
	animation_tree["parameters/conditions/notAiming"] = !inp

func isFiring(inp : bool):
	animation_tree["parameters/conditions/isFiring"] = inp
