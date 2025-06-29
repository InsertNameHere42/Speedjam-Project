extends Camera3D

@export var period = 0.3
var basePosition = self.position

func cameraShake(magnitude : float):
	var elapsed_time = 0.0

	while elapsed_time < period:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)

		self.position = basePosition + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	resetPos()
	
func resetPos() -> void:
	self.position = basePosition
func setBaseYPos(newPosY : float) -> void:
	basePosition.y = newPosY
	resetPos()
		
		
