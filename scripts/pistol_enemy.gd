extends CharacterBody3D

@export var target : CharacterBody3D
@export var targetingRange : float = 50
@export var shootingCooldown : float = 2

@onready var enemyMesh: Node3D = $PistolEnemyMesh
@onready var shootTimer: Timer = $ShootTimer
@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var gunshot: AudioStreamPlayer3D = $Gunshot

var flatLook : Vector3
	
func _ready():
	shootTimer.wait_time = shootingCooldown
	

func _physics_process(_delta: float) -> void:
	flatLook = Vector3(target.position.x, self.position.y, target.position.z)
	if shootTimer.time_left>0:
		enemyMesh.isFiring(false)
		
	if(global_position.distance_to(target.position) < targetingRange):
	
		self.look_at(flatLook)
		enemyMesh.isAiming(true)
		if(shootTimer.is_stopped()):
			shootTimer.start()
	else:
		enemyMesh.isAiming(false)
		shootTimer.stop()

	
	
		
	
func hit():
	get_parent().enemyDead()
	queue_free()

func _on_shoot_timer_timeout() -> void:
	enemyMesh.isFiring(true)
	gunshot.pitch_scale = randf_range(0.8, 1)
	gunshot.play()
	var spawnedBullet = bullet.instantiate()
	get_tree().get_root().add_child(spawnedBullet)
	spawnedBullet.global_position = self.global_position
	spawnedBullet.position.y += 1.2
	var bulletDir = (target.global_position - self.global_position).normalized()
	spawnedBullet.direction = bulletDir
