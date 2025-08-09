extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal transitioned

func _ready() -> void:
	animation_player.play("fadeToNormal")

func transition():
	animation_player.play("FadeToBlack")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "FadeToBlack"):
		emit_signal("transitioned")
		print("signal emitted")
		
