extends Node

var pig_scene = preload("res://scenes/pig_template.tscn")

@onready
var roomNode = get_node("../room")

@onready
var worldNode = get_parent()

@onready
var playerNode = get_node("../lenin")

@onready
var halt_sfx = get_node("../halt_sfx")

@onready
var bust_sfx = get_node("../bust_sfx")

@onready
var forgot = get_node("../forgot")

@onready
var uinode = get_node("../ui")


var pigs = []

# keeps track of all pigs
# worldNode.room_index, Vector2i(x*16+8,y*16-8), null, false
var trackedPigs = []

var haveSpawned = false

var frames = 0

var crossStar = AStar2D.new()

var crossSpeed = 32
var crossStep = 0;

var angryPigs = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass
		
		
		
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#if Input.is_action_just_released("pig"):
		#inventPig(1, worldNode.room_index)
	#if Input.is_action_just_released("follow"):
		#angryPigs = !angryPigs
	if (worldNode.wrongMaps > 2 && !angryPigs):
		angryPigs = true
		forgot.play()
		
	for pig in trackedPigs:
		
		uinode.toggle_cop_highlight(pig[0], true)
	for room in worldNode.rooms:
		var noPig = true
		for pig in trackedPigs:
			if room.room_index == pig[0]:
				noPig = false
		if noPig:
			uinode.toggle_cop_highlight(room.room_index, false)
			
	
	if angryPigs:
		crossFollow()
		
		for i in range(trackedPigs.size()):
			if trackedPigs[i][3] == true:
				if crossStep == 0:
					if (trackedPigs[i][2] == worldNode.room_index):
						bust_sfx.play()
				if crossStep < crossSpeed:
					crossStep+=1
				else:
					var prev = trackedPigs[i][0]
					trackedPigs[i][0] = trackedPigs[i][2]
					trackedPigs[i][2] = null
					trackedPigs[i][3] = false
					
					var room = worldNode.rooms[trackedPigs[i][0]]
					var walls = worldNode.walls
					var x = randi_range(walls["left"]+1, walls["left"]+room.width-3)
					var y = randi_range(walls["up"]+3, walls["up"]+room.height-3)
					if (trackedPigs[i][0] == worldNode.room_index):
						#bust_sfx.play()
						var side = -1
						if worldNode.rooms[prev].world_coord.y<worldNode.rooms[trackedPigs[i][0]].world_coord.y:
							side = 0
						if worldNode.rooms[prev].world_coord.y>worldNode.rooms[trackedPigs[i][0]].world_coord.y:
							side = 2
						if worldNode.rooms[prev].world_coord.x>worldNode.rooms[trackedPigs[i][0]].world_coord.x:
							side = 1
						if worldNode.rooms[prev].world_coord.x<worldNode.rooms[trackedPigs[i][0]].world_coord.x:
							side = 3
							
						match side:
							0:
								x = worldNode.door_coords["up"].x
								y = worldNode.door_coords["up"].y
							1:
								x = worldNode.door_coords["right"].x
								y = worldNode.door_coords["right"].y
							2:
								x = worldNode.door_coords["down"].x
								y = worldNode.door_coords["down"].y
							3:
								x = worldNode.door_coords["left"].x
								y = worldNode.door_coords["left"].y
						
					
					trackedPigs[i][1] = Vector2i(x*16,y*16)
					crossStep = 0
					
					killPigs()
					spawnLocalPigs()
	
	#if randf() < 0.01:
		#halt_sfx.play()
	frames += 1
	if (frames % 10 == 0):
		updatePigPaths()
	updatePigsPigs()
	if !haveSpawned:
		spawnLocalPigs()
		haveSpawned = true

func updatePigPaths() -> void:
	for pig in pigs:
		pig.updatePath()
func updatePigsPigs() -> void:
	for pig in pigs:
		pig.updatePigs(pigs)
		
func inventPig(count: int, room_index: int) -> void:
	var room = worldNode.rooms[room_index]
	var walls = worldNode.walls
	for i in range(count):
		var x = randi_range(walls["left"]+1, walls["left"]+room.width-3)
		var y = randi_range(walls["up"]+3, walls["up"]+room.height-3)
		trackedPigs.append([worldNode.room_index, Vector2i(x*16+8,y*16-8), null, false])
		
func spawnLocalPigs() -> void:
	var pigIndex = 0
	var walls = worldNode.walls
	for tp in trackedPigs:
		if tp[0] == worldNode.room_index:
			var pig = pig_scene.instantiate()
			add_child(pig)
			pig.receivePlayer(playerNode)
			pig.receiveWorld(worldNode)
			pig.receiveRoom(roomNode)

			pig.position = tp[1]
			pig.pigIndex = pigIndex
			pigIndex += 1
			pigs.append(pig)
	
			
func killPigs() -> void:
	for pig in pigs:
		pig.queue_free()
	pigs = []
	haveSpawned = false

func updateCrossStar(rooms: Array) -> void:

	
	for room in rooms:
		crossStar.add_point(room.room_index, room.world_coord)
		
	for room in rooms:
		if room.mapped:
			if room.doors["left"].room_index != null && room.doors["left"].mapped:
				crossStar.connect_points(room.room_index, room.doors["left"].room_index)
			if room.doors["right"].room_index != null && room.doors["right"].mapped:
				crossStar.connect_points(room.room_index, room.doors["right"].room_index)
			if room.doors["up"].room_index != null && room.doors["up"].mapped:
				crossStar.connect_points(room.room_index, room.doors["up"].room_index)
			if room.doors["down"].room_index != null && room.doors["down"].mapped:
				crossStar.connect_points(room.room_index, room.doors["down"].room_index)
			
func crossFollow() -> void:
	for i in range(trackedPigs.size()):
		
		var id = trackedPigs[i][0]
		var path = crossStar.get_id_path(id, worldNode.room_index, false)
		if path.size() > 1:
			var next = path[1]
			var moving = true
			trackedPigs[i] = [trackedPigs[i][0], trackedPigs[i][1], next, moving]
		
	
