extends CanvasLayer


func _ready() -> void:
	pass

func _on_quit_button_pressed() -> void:
	Global.goto_scene("res://scenes/mainMenu.tscn")
