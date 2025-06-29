extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree


func inAir(inp : bool):
	animation_tree["parameters/conditions/inAir"] = inp
	animation_tree["parameters/conditions/onGround"] = !inp
func inputCharge(inp : bool):
	animation_tree["parameters/conditions/inputCharge"] = inp
	animation_tree["parameters/conditions/chargeRelease"] = !inp
func inputPunch(inp : bool):
	animation_tree["parameters/conditions/inputPunch"] = inp
func sliding(inp : bool):
	animation_tree["parameters/conditions/isSliding"] = inp
	animation_tree["parameters/conditions/notSliding"] = !inp
	
func yVelocity(inp : float):
	animation_tree["parameters/Jumping/blend_position"] = inp
	
func chargeTimeout():
	animation_tree["parameters/conditions/chargeTimeout"] = true
