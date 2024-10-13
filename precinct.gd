extends Node

var pig_scene = preload("res://scenes/pig_template.tscn")
var test_pig = null
var test_pig1 = null
var test_pig2 = null

@onready
var roomNode = get_node("../room")

@onready
var worldNode = get_parent()

@onready
var playerNode = get_node("../lenin")

@onready
var halt_sfx = get_node("../halt_sfx")

var pigs = []
var pigAmount = 5

var haveSpawned = false

var frames = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var pigIndex = 0
	
	for i in range(pigAmount):
		var pig = pig_scene.instantiate()
		add_child(pig)
		pig.receivePlayer(playerNode)
		pig.receiveWorld(worldNode)
		pig.receiveRoom(roomNode)
		pig.pigIndex = pigIndex
		pigIndex += 1
		pigs.append(pig)
		
		
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if randf() < 0.01:
		halt_sfx.play()
	frames += 1
	if (frames % 10 == 0):
		updatePigPaths()
	updatePigsPigs()
	if !haveSpawned:
		
		var room = worldNode.rooms[worldNode.room_index]
		var walls = worldNode.walls
		for pig in pigs:
			var x = randi_range(walls["left"]+1, walls["left"]+room.width-3)
			var y = randi_range(walls["up"]+3, walls["up"]+room.height-3)
			
			pig.position = Vector2i(x*16,y*16)
		
		haveSpawned = true

func updatePigPaths() -> void:
	for pig in pigs:
		pig.updatePath()
func updatePigsPigs() -> void:
	for pig in pigs:
		pig.updatePigs(pigs)
