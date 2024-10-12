extends CharacterBody2D

var canMove = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		if canMove:
			position.x -= 16
			canMove = false
	if Input.is_action_pressed("up"):
		if canMove:
			position.y -= 16
			canMove = false
	if Input.is_action_pressed("right"):
		if canMove:
			position.x += 16
			canMove = false
	if Input.is_action_pressed("down"):
		if canMove:
			position.y += 16
			canMove = false
	if Input.is_action_just_released("left") || Input.is_action_just_released("up") || Input.is_action_just_released("right") || Input.is_action_just_released("down"):
		canMove = true
		
