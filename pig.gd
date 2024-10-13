extends CharacterBody2D

var astar_grid = AStarGrid2D.new()

#@onready
#var roomNode = get_node("../room")
#
#@onready
#var worldNode = get_parent()
#
##@onready
##var playerNode = get_node("../lenin")

var roomNode = null
var worldNode = null
var playerNode = null

var isStepping = false

# pixels per frame
var speed = 1
var stepSize = 16
var currentSubStep = 0

var pigs = []
# 0:up, 1:right, 2:down, 3:left
var stepDir = -1
var stepStart = Vector2i(0,0)

var perp = null
var pigTile = null

var path = []
var pathIndex = 0

var pigIndex = -1

func _ready():
	pass

	
func _process(delta):
	if (playerNode != null && worldNode != null && roomNode != null):

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
				var tileTaken = false
				var nextTile = path[pathIndex+1]
				
				for pig in pigs:
					if (pig.pigIndex != pigIndex):
						var otherTile = Vector2i(floor((pig.position.x)/16), floor((pig.position.y)/16))
						var otherNext = null
						if pig.pathIndex < pig.path.size()-1:
							otherNext = pig.path[pig.pathIndex+1]
						if nextTile == otherTile || nextTile == otherNext:
							tileTaken = true
							break
				
				var dir = 0

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
					
				if dir > -1 && !tileTaken:
					startStep(dir)
				else:
					#cant do pathfinding, do random step.
					var left = Vector2i(pigTile.x-1, pigTile.y)
					var right = Vector2i(pigTile.x+1, pigTile.y)
					var up = Vector2i(pigTile.x, pigTile.y-1)
					var down = Vector2i(pigTile.x, pigTile.y+1)
					
					# 0:up, 1:right, 2:down, 3:left
					var dirPossibilities = [true, true ,true, true]
					
					for pig in pigs:
						if pig.pigIndex != pigIndex:
							var otherTile = Vector2i(floor((pig.position.x)/16), floor((pig.position.y)/16))
							var otherNext = null
							if pig.pathIndex < pig.path.size()-1:
								otherNext = pig.path[pig.pathIndex+1]
							if left == otherNext || left == otherTile:
								dirPossibilities[3] = false
							if right == otherNext || right == otherTile:
								dirPossibilities[1] = false
							if up == otherNext || up == otherTile:
								dirPossibilities[0] = false
							if down == otherNext || down == otherTile:
								dirPossibilities[2] = false
					
					var dirs = []
					if dirPossibilities[0]: dirs.append(0)
					if dirPossibilities[1]: dirs.append(1)
					if dirPossibilities[2]: dirs.append(2)
					if dirPossibilities[3]: dirs.append(3)
					
					if randf()<0.05:
						var di = randi_range(0,dirs.size()-1)
						#print(dirs)
						if (dirs.size()>0):
							startStep(dirs[di])
					
				
			

	
	
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
	#print(path)
func receivePlayer(player: Node) -> void:
	playerNode = player
func receiveWorld(world: Node) -> void:
	worldNode = world
func receiveRoom(room: Node) -> void:
	roomNode = room
func updatePigs(p:Array) -> void:
	
	pigs = p
	for pig in pigs:
		var otherTile = Vector2i(floor((pig.position.x)/16), floor((pig.position.y)/16))
			
		astar_grid.set_point_solid(otherTile, false)
	
