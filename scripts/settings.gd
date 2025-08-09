extends CanvasLayer

@onready var back_button: Button = $Control/MarginContainer/BackButton

@onready var master_volume: HSlider = $Control/MarginContainer/VBoxContainer/MasterVolume
@onready var sfx_volume: HSlider = $Control/MarginContainer/VBoxContainer/SFXVolume
@onready var music_volume: HSlider = $Control/MarginContainer/VBoxContainer/MusicVolume


func _ready() -> void:
	master_volume.value = Global.masterVol
	sfx_volume.value = Global.sfxVol
	music_volume.value = Global.musicvol


func _on_back_button_pressed() -> void:
	Global.masterVol = music_volume.value
	Global.sfxVol = sfx_volume.value
	Global.musicvol = music_volume.value
	Global.goto_scene("res://scenes/mainMenu.tscn")
