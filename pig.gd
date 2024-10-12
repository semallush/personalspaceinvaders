extends CharacterBody2D

var astar_grid = AStarGrid2D.new()

@onready
var roomNode = get_node("../room")

@onready
var worldNode = get_parent()

@onready
var playerNode = get_node("../lenin")

var isStepping = false

# pixels per frame
var speed = 1
var stepSize = 16
var currentSubStep = 0


# 0:up, 1:right, 2:down, 3:left
var stepDir = -1
var stepStart = Vector2i(0,0)

var perp = null
var pigTile = null

var path = []
var pathIndex = 0

func _ready():
	pass

	
func _process(delta):
	
	perp = playerNode.playerTile
	pigTile = Vector2i(floor((position.x)/16), floor((position.y)/16))
	updateStep()
	
	# if this affects perfomance it needs to be called AFTER a new room is loaded
	var cells = roomNode.get_used_cells()
	var room = worldNode.rooms[worldNode.room_index]
	var walls = worldNode.walls
	astar_grid.region = Rect2i(walls["left"], walls["up"]+3, room.width-2, room.height-3)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = 1
	astar_grid.update()
	
	
	
	if !isStepping:
		if path.size() > 0 && pathIndex < path.size()-1:
			var nextTile = path[pathIndex+1]
			var dir = 0
			print(nextTile)
			print(pigTile)
			print('----')
			print(nextTile.y)
			if nextTile.y < pigTile.y:
				dir = 0
			elif nextTile.x > pigTile.x:
				dir = 1
			elif nextTile.y > pigTile.y:
				dir = 2
			elif nextTile.x < pigTile.x:
				dir = 3
			else:
				dir = -1
			if dir > -1:
				startStep(dir)
			
			

	
	
func startStep(dir: int) -> void:
			stepStart = Vector2i(position.x, position.y)
			stepDir = dir
			isStepping = true
			pathIndex += 1
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
				
				
func updatePath() -> void:
	path = astar_grid.get_id_path(pigTile, perp, true)
	pathIndex = 0
	print(path)
