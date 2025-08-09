extends Node3D

@export var bulletSpeed : Curve
var direction : Vector3 = Vector3.ZERO
var timeAlive = 0

func _process(delta):
	timeAlive+=delta
	global_translate(direction * bulletSpeed.sample(timeAlive) * delta)
	
	if(timeAlive>=10):
		queue_free()




func _on_area_3d_area_entered(_area: Area3D) -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D && body.collision_layer & (1 << 2):
		body.hit() 
		queue_free()
	if body is CSGCombiner3D:
		queue_free()
