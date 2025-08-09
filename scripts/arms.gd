extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hitbox: Area3D = $"Human FPV/Hitbox"

func inputCharge(inp : bool) -> void:
	animation_tree["parameters/conditions/inputCharge"] = inp
	animation_tree["parameters/conditions/chargeRelease"] = !inp
func inputPunch(inp : bool) -> void:
	animation_tree["parameters/conditions/inputPunch"] = inp
func sliding(inp : bool) -> void:
	animation_tree["parameters/conditions/isSliding"] = inp
	animation_tree["parameters/conditions/notSliding"] = !inp
	
func yVelocity(inp : float) -> void:
	animation_tree["parameters/Idle/blend_position"] = inp
	
func chargeTimeout(inp : bool) -> void:
	animation_tree["parameters/conditions/chargeTimeout"] = inp

func chargeHit(inp : bool) -> void:
	animation_tree["parameters/conditions/chargeHit"] = inp
	


func _on_hitbox_area_entered(area: Area3D) -> void:
	print(owner)
	owner.collide(owner.currentSpeed, true)
	if area.collision_layer & (1 << 1): 
		area.owner.hit()

func _on_charge_box_area_entered(area: Area3D) -> void:
	print(owner)
	owner.chargeCollide(owner.currentSpeed)
	area.owner.hit()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is CSGCombiner3D:
		owner.collide(owner.currentSpeed, false)
