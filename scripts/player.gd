extends CharacterBody2D


@onready
var roomNode = get_node("../room")

#@onready
#var pigNode = get_node("../pig")
@onready
var precinct = get_node("../precinct")

@onready
var bg_audio = get_node("../bg_audio")

@onready
var money_audio = get_node("../money_sfx")

@onready
var step_audio = get_node("../step_sfx")

@onready
var score_label = get_node("../score")

var isStepping = false

# pixels per frame
var speed = 2
var stepSize = 16
var currentSubStep = 0

var score = 0

# 0:up, 1:right, 2:down, 3:left
var stepDir = -1
var stepStart = Vector2i(0,0)

var playerTile = null

var collisionTiles = {
	"wall_top": Vector2i(1,2),
	"wall_side": Vector2i(0,2),
	"nothing": Vector2i(0,3),
	"door_up_upper": Vector2i(2,0),
	"door_up_lower": Vector2i(2,1),
	"door_up_top": Vector2i(2,2),
	"door_left": Vector2i(3,0),
	"door_right": Vector2i(3,1)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	bg_audio.play()
	
	position = Vector2i(168,152)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	updateStep()
	
	playerTile = Vector2i(floor((position.x)/16), floor((position.y)/16))
	
	if !Input.is_action_pressed("mapping"):
		if Input.is_action_pressed("left"):
			if nextTileWalkable(playerTile, 3):
				startStep(3)
		if Input.is_action_pressed("up"):
			if nextTileWalkable(playerTile, 0):
				startStep(0)
		if Input.is_action_pressed("right"):
			if nextTileWalkable(playerTile, 1):
				startStep(1)
		if Input.is_action_pressed("down"):
			if nextTileWalkable(playerTile, 2):
				startStep(2)
	
	
func startStep(dir: int) -> void:
	
	if !isStepping:
			stepStart = Vector2i(position.x, position.y)
			stepDir = dir
			isStepping = true
			step_audio.pitch_scale = randf_range(0.5,1.0)
			step_audio.play()
func updateStep() -> void:
	if isStepping:
		if currentSubStep < stepSize:
			currentSubStep += speed
			match stepDir:
				0:
					position.y = stepStart.y - currentSubStep
				1:
					position.x = stepStart.x + currentSubStep
				2:
					position.y = stepStart.y + currentSubStep
				3:
					position.x = stepStart.x - currentSubStep
		else:
				isStepping = false
				currentSubStep = 0
func nextTileWalkable(playerTile: Vector2i, dir: int) -> bool:
		var nextTile = Vector2i(playerTile.x, playerTile.y-1)
		match dir:
			1:
				nextTile = Vector2i(playerTile.x+1, playerTile.y)
			2:
				nextTile = Vector2i(playerTile.x, playerTile.y+1)
			3:
				nextTile = Vector2i(playerTile.x-1, playerTile.y)	
		
		var nextTileType = roomNode.get_cell_atlas_coords(nextTile)
		for tile in collisionTiles:
			if collisionTiles[tile] == nextTileType:
				return false
		return true
				
func increaseScore(amount: int) -> void:
	score += amount
	var scoreText = "credit score: " + str(score)
	score_label.text = scoreText

	money_audio.play()
