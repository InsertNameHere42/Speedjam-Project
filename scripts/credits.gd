extends CanvasLayer

@onready var back_button: Button = $Control/MarginContainer/BackButton


func _on_back_button_pressed() -> void:
	Global.goto_scene("res://scenes/mainMenu.tscn")
