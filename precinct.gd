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

var pigs = []

# keeps track of all pigs
var trackedPigs = []

var haveSpawned = false

var frames = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass
		
		
		
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("pig"):
		inventPig(1, worldNode.room_index)
	
	if randf() < 0.01:
		halt_sfx.play()
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
		trackedPigs.append([worldNode.room_index, Vector2i(x*16+8,y*16-8)])
		
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
