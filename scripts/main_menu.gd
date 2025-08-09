extends CanvasLayer

@onready var start_button: Button = $Control/MarginContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $Control/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Control/MarginContainer/VBoxContainer/QuitButton



func _on_start_button_pressed() -> void:
	Global.goto_scene("res://scenes/Levels/level_1.tscn")
	Global.timer = 0



func _on_credits_button_pressed() -> void:
	Global.goto_scene("res://scenes/credits.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	Global.goto_scene("res://scenes/settings.tscn")


func _on_leaderboard_button_pressed() -> void:
	Global.goto_scene("res://scenes/leaderboard.tscn")
