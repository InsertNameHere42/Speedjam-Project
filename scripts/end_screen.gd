extends CanvasLayer

@onready var final_time: Label = $Control/MarginContainer/VBoxContainer/FinalTime
@onready var line_edit: LineEdit = $Control/MarginContainer/VBoxContainer2/LineEdit
var score : int = 0

var playerName : String

func _ready() -> void:
	score = int(Global.timer * 1000)
	final_time.text = str(Global.timer).substr(0, str(Global.getTime()).find(".")+3)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _on_submit_button_pressed() -> void:
	if(line_edit.text!=""):
		playerName = line_edit.text
		SilentWolf.Scores.save_score(playerName, score)
		Global.goto_scene("res://scenes/leaderboard.tscn")
