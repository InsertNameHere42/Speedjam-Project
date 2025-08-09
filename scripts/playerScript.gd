extends CharacterBody3D

#Basic Movement
@export_group("Simple Movement")
@export var acceleration : float #acceleration of walking
@export var maxWalkSpeed : float #the maximum speed you can get just by walking
@export var deceleration : float #toss of speed while on ground
@export var lookSpeed : float = 0.003
@export var angleToAcceleration : Curve
@export var slidingMultiplier : float = 20
@export_subgroup("Jumping")
@export var jumpVelocity : float
@export var coyoteTime : float = 0.3
@export var airStrafeFactor : float = 0.4

#input map for remappable controls
@export_group("Inputs")
@export var inputForward : String
@export var inputLeft : String
@export var inputRight : String
@export var inputBack : String
@export var inputSlide : String
@export var inputPunch : String
@export var inputCharge : String

@export_group("Attack Settings")
@export_subgroup("Charge Attack")
@export var minChargeSpeed : float = 20 
@export var chargeBoost : float = 10
@export var maxChargeTime : float = 2

@export_group("Camera Settings")
@export var dynamicFOV : Curve #Velocity vs FOV
@export var speedToShake : Curve
@export var headbobFrequency : float = 2
@export var headbobAmplitude : float = 0.04
@export_subgroup("Speedline Settings")
@export var speedlineDensityCurve : Curve
@export var speedlineFalloffCurve : Curve

var headbobTime : float = 0
var hasGravity : bool = true
var mouseCaptured : bool = false
var lookRotation : Vector2
var canJump : bool = true
var sliding : bool = false
var acceleratorMult : float = 1 #controls sliding's effect on deceleration on the ground
var crouchMult : float = 1 #controls sliding's affect on acceleration on the ground
var wasOnFloor = true #helper for coyote time

var isCharging : bool = false
var canCharge : bool = true
var chargeTime : float = 0
var chargeDirection : Vector3 = Vector3.ZERO
var launchedThisFrame : bool = false
var currentSpeed : float = 0

@onready var collider : CollisionShape3D = $Collider
@onready var head : Node3D = $Head
@onready var coyoteTimer : Timer = $CoyoteTimer
@onready var camera : Camera3D = $Head/Camera3D
@onready var speedlines: Control = $Speedlines
@onready var arms: Node3D = $Head/Camera3D/ArmsAnim
@onready var chargeTimer: Timer = $ChargeTimer

@onready var level_time: Label = $Labels/Control/MarginContainer/Timers/LevelTime
@onready var overall_time: Label = $Labels/Control/MarginContainer/Timers/OverallTime
@onready var targets_left: Label = $Labels/Control/MarginContainer/Other/TargetsLeft
@onready var back_button: Button = $Labels/Control/MarginContainer/BackButton

@onready var punch_sound: AudioStreamPlayer = $PunchSound
@onready var charge_hit: AudioStreamPlayer = $ChargeHit
@onready var charge_release: AudioStreamPlayer = $ChargeRelease
@onready var slidingAudio: AudioStreamPlayer = $Sliding
var slidingAudioPossible := true

@onready var purp_particles: GPUParticles3D = $Head/PurpParticles
@onready var yellow_particles: GPUParticles3D = $Head/YellowParticles




func _ready() -> void:
	capture_mouse()
	coyoteTimer.wait_time = coyoteTime
	purp_particles.emitting = false
	yellow_particles.emitting = false
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	if mouseCaptured && event is InputEventMouseMotion:
		rotateLook(event.relative)
			

func _physics_process(delta: float) -> void:
	if canJump && wasOnFloor!=is_on_floor() && wasOnFloor: #currently have a bug where it's starting even off a jump but that can be fixed later, just a small optimization issue
		coyoteTimer.start()
	
	
	if Input.is_action_pressed("slide"):
		sliding = true
		acceleratorMult = 0.4
		if(is_on_floor()):
			if(slidingAudio.playing==false && slidingAudioPossible == true):
				slidingAudioPossible = false
				slidingAudio.pitch_scale = 0.7 + randf_range(-0.1, 0.1) 
				slidingAudio.play()
			crouchMult = 0.2
	else:
		slidingAudio.stop()
		slidingAudioPossible = true
		sliding = false
		acceleratorMult = 1
		crouchMult = 1
		
	if sliding:
		#play sliding animation
		camera.setBaseYPos(0)
		if is_on_floor():
			var floorAngle := rad_to_deg(get_floor_angle())
			var slideAccel := angleToAcceleration.sample(floorAngle) #multiplier from sliding
			var slopeDir := get_floor_normal() .slide(Vector3.DOWN).normalized()
			var slideVelocity := slopeDir * slideAccel * slidingMultiplier * acceleratorMult * 1.2 * delta 
			
			velocity.x += slideVelocity.x
			velocity.z += slideVelocity.z
	else:
		camera.setBaseYPos(0.5)
		
		
	
	

	
	#basic movement code
	var inputDir := Input.get_vector(inputLeft, inputRight, inputForward, inputBack)
	var moveDir := (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var horizontalVelocity := Vector3(velocity.x, 0, velocity.z)
	currentSpeed = horizontalVelocity.length()
	if moveDir:
		var targetVelocity := moveDir * maxWalkSpeed * crouchMult
		var targetSpeed := targetVelocity.length()
		if(is_on_floor()):
			horizontalVelocity = horizontalVelocity.move_toward(targetVelocity, acceleration * crouchMult * delta)
		elif currentSpeed >= targetSpeed * 0.98:
			horizontalVelocity = horizontalVelocity.move_toward(targetVelocity.normalized() * currentSpeed, acceleration * delta * airStrafeFactor)
		else:
			horizontalVelocity = horizontalVelocity.move_toward(targetVelocity, acceleration * delta)
	elif is_on_floor() && hasGravity:
		horizontalVelocity = horizontalVelocity.move_toward(Vector3.ZERO, deceleration * acceleratorMult * delta)
	
	
	if canJump && Input.is_action_just_pressed("jump"):
		velocity.y = jumpVelocity
		canJump = false
	
	if is_on_floor():
		resetMovement()
		set_floor_snap_length(0.1+currentSpeed/10)
	else:
		if hasGravity:
			velocity += get_gravity() * delta
			set_floor_snap_length(0)
	
	#Speedline shader
	speedlines.material.set_shader_parameter("line_falloff", speedlineFalloffCurve.sample(velocity.length()))
	speedlines.material.set_shader_parameter("line_density", speedlineDensityCurve.sample(velocity.length()))
	
	#Camera JUICE
	camera.fov = dynamicFOV.sample(currentSpeed) #only x and z matter
	camera.cameraShake(speedToShake.sample(velocity.length())) #x y and z
	if speedToShake.sample(currentSpeed) == 0:
		camera.resetPos()
	#Headbob
	
	headbobTime += delta * velocity.length() * float(is_on_floor()) * float(!sliding)
	head.transform.origin = headbobFunc(headbobTime)
	arms.transform.origin.x = headbobFunc(headbobTime).x / 4
	arms.transform.origin.y = headbobFunc(headbobTime).y / 4 - 1.894
	arms.transform.origin.z = headbobFunc(headbobTime).z / 4 + 0.3
	
	
	
	var justLanded := !wasOnFloor && is_on_floor()
	wasOnFloor = is_on_floor()
	
	#Punch handler
	
	#Charge Handler (Also AI but I cannot be bothered rn)
	if Input.is_action_pressed("charge") && canCharge:
		arms.inputCharge(true)
		if !isCharging:
			isCharging = true
			chargeTime = 0
			# Prefer velocity-based direction
		else:
			chargeTime += delta
			chargeTime = min(chargeTime, maxChargeTime)
	elif isCharging:
		charge_release.pitch_scale = 1.4 + randf_range(-0.15, 0.15) 
		charge_release.play()
		arms.chargeTimeout(false)
		arms.inputCharge(false)
		chargeDirection = (-camera.get_global_transform().basis.z).normalized() # face forward
		isCharging = false
		canCharge = false
		if chargeDirection != Vector3.ZERO:
			currentSpeed = Vector3(velocity.x, 0, velocity.z).length()
			var launchSpeed = max(minChargeSpeed, currentSpeed + chargeBoost * (chargeTime / maxChargeTime))
			var launchVelocity = chargeDirection * launchSpeed
			velocity = launchVelocity
			launchedThisFrame = true
			if(velocity.y>=0 || is_on_floor()):
				hasGravity = false
			if chargeTimer.time_left>0:
				chargeTimer.stop()
			chargeTimer.wait_time = chargeTime * 0.75
			chargeTimer.start()
	
	if !isCharging && Input.is_action_just_pressed("punch"):
		arms.inputPunch(true)
	else:
		arms.inputPunch(false)
	
		
	
	#velocity updater
	if !launchedThisFrame:
		arms.chargeHit(false)
		velocity.x = horizontalVelocity.x
		velocity.z = horizontalVelocity.z

	#Animation Handler
	arms.sliding(sliding && is_on_floor())
	arms.yVelocity(self.velocity.y * 0.2)
	
	
	
	move_and_slide()
	launchedThisFrame = false
	updateTimes()
	
	if justLanded: #this is AI. It works but I don't like how it's AI
		var slope_normal := get_floor_normal()
		var slope_angle := rad_to_deg(get_floor_angle())
		
		if slope_angle > 5: # Only apply slope boost on noticeably steep slopes
			var slope_dir := slope_normal.slide(Vector3.DOWN).normalized()
			var horizontal := Vector3(velocity.x, 0, velocity.z)

			var fall_speed := -velocity.y
			var slope_component := slope_dir * horizontal.dot(slope_dir)
			var sideways_component := horizontal - slope_component

			slope_component += slope_dir * fall_speed
			sideways_component *= 0.1

			velocity = slope_component + sideways_component

func rotateLook(rotInput : Vector2):
	lookRotation.x -= rotInput.y * lookSpeed
	lookRotation.x = clamp(lookRotation.x, deg_to_rad(-85), deg_to_rad(85))
	lookRotation.y -= rotInput.x * lookSpeed
	transform.basis = Basis()
	rotate_y(lookRotation.y)
	head.transform.basis = Basis()
	head.rotate_x(lookRotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouseCaptured= true
	back_button.visible = false
func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouseCaptured = false
	back_button.visible = true
func resetMovement():
	coyoteTimer.stop()
	canCharge = true
	canJump = true
	arms.chargeTimeout(false)
	
func collide(currentSpeedInp : float, enemy : bool):
	punch_sound.pitch_scale = 0.7 + randf_range(-0.1, 0.1) 
	punch_sound.play()
	if(enemy && is_on_floor()):
		pass
	else:
		var launchSpeed = max(20, currentSpeedInp + chargeBoost/2)
		var launchVelocity = (camera.get_global_transform().basis.z).normalized() * launchSpeed
		velocity = launchVelocity
		launchedThisFrame = true
	canCharge = true
	purp_particles.restart()
	yellow_particles.restart()
	

	
	
	
func chargeCollide(currentSpeedInp : float):
	var launchSpeed = max(20, currentSpeedInp + chargeBoost/2)
	var launchVelocity = (camera.get_global_transform().basis.z).normalized() * launchSpeed
	arms.chargeHit(true)
	velocity.x = -launchVelocity.x/2
	velocity.y = 25
	velocity.z = -launchVelocity.z/2
	canCharge = true #chaining
	launchedThisFrame = true
	charge_hit.pitch_scale = 0.7 + randf_range(-0.1, 0.1) 
	charge_hit.play()
	purp_particles.restart()
	yellow_particles.restart()



func _on_coyote_timer_timeout() -> void:
	canJump=false
func headbobFunc(headbobTime : float) -> Vector3:
	var headbobPosition = Vector3.ZERO
	headbobPosition.y = sin(headbobTime * headbobFrequency) * headbobAmplitude / 2
	headbobPosition.x = cos(headbobTime * headbobFrequency / 4) * headbobAmplitude
	return headbobPosition
func _on_charge_timer_timeout() -> void:
	hasGravity = true
	arms.chargeTimeout(true)
	
func hit():
	var current_scene = get_tree().current_scene
	if current_scene:
		get_tree().reload_current_scene()
	
func updateTimes():
	level_time.text = str(owner.getTime()).substr(0, str(owner.getTime()).find(".")+3)
	overall_time.text = str(Global.getTime()).substr(0, str(Global.getTime()).find(".")+3)
	targets_left.text = str(owner.numEnemies)


func _on_back_button_pressed() -> void:
	Global.goto_scene("res://scenes/mainMenu.tscn")
