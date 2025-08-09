extends Node3D

@export var numEnemies : int
@export var levelNum : int
@export var nextScene : String

@onready var playerCheck: Area3D = $Area3D
@onready var deathbox: Area3D = $Deathbox
@onready var music: AudioStreamPlayer = $Music
@onready var fade: CanvasLayer = $Fade

var time : float = 0
var timerActive : bool = false

func _physics_process(delta: float) -> void:
	if timerActive:
		time+=delta

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if numEnemies==0:
		timerActive = false
		Global.timerActive = false
		fade.transition()
	else:
		if(!music.playing):
			music.play()
		timerActive = true
		Global.timerActive = true
		
func enemyDead():
	numEnemies-=1


func _on_deathbox_body_entered(_body: Node3D) -> void:
	var current_scene = get_tree().current_scene
	if current_scene:
		get_tree().reload_current_scene()

func getTime():
	return time


func _on_fade_transitioned() -> void:
	print("got")
	Global.finishLevel(levelNum, time, nextScene)
	music.stop()
