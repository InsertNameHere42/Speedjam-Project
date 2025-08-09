extends Node

var bestSpeedrun : float = 0 #best time when speedrunning
var timer : float = 0 #global timer for speedrun mode
var timerActive : bool = false
var speedrunning : bool = true

var masterVol : float = 1
var sfxVol : float = 1
var musicvol : float = 1

var levelBestTimes : Array[float] = [0, 0, 0, 0, 0, 0]
var currentScene = null
	
func _ready() -> void:
	var root = get_tree().root
	currentScene = root.get_child(root.get_child_count()-1)

	SilentWolf.configure({
		"api_key": "9Yi70Wabbc7DywQqFtKqC4a3uyHjj3Xd39GHYqpr",
		"game_id": "VioletGauntlet",
		"log_level": 1
		})

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/mainMenu.tscn"
	})
	
	
func _physics_process(delta: float) -> void:
	if timerActive:
		timer+=delta

func finishLevel(level : int, time : float, nextScene : String):
	if levelBestTimes[level] == 0 || levelBestTimes[level] < time:
		levelBestTimes[level] = time
	if speedrunning:
		if(level+2 > levelBestTimes.size()):
			timerActive = false
			if(bestSpeedrun == 0 || timer<bestSpeedrun):
				bestSpeedrun = timer
		goto_scene(nextScene)
	else:
		pass
		#goto_scene() go to level select

func goto_scene(path: String):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	var packed_scene = ResourceLoader.load(path)
	if packed_scene is PackedScene:
		get_tree().change_scene_to_packed(packed_scene)
	else:
		push_error("Failed to load scene: %s" % path)

func getTime():
	return timer
		
