extends Node
var room = load("res://scripts/room.gd")

@onready
var roomNode = get_node("room")

var rooms = [
	room.new(null, null)
]

var tiles = {
	"floor": Vector2i(1,1),
	"wall_top": Vector2i(1,2),
	"wall_side": Vector2i(0,2),
	"nothing": Vector2i(0,0),
	"door_up_upper": Vector2i(2,0),
	"door_up_lower": Vector2i(2,1),
	"door_up_top": Vector2i(2,2),
	"door_left": Vector2i(3,0),
	"door_right": Vector2i(3,1),
	"doormat": Vector2i(3,2),
}

func _ready() -> void:
	load_room(0,"left")

func _process(delta: float) -> void:
	pass

func load_room(index, side) -> void:
	var loading_room = rooms[index]
	var tilestring
	var walls = {
		"left": 10 - loading_room.width/2,
		"right": 9 + loading_room.width/2,
		"up": 10 - loading_room.height/2,
		"down": 9 + loading_room.height/2,
	}
	
	roomNode.clear()
	var writtenTiles = []
	if(loading_room.doors["left"].exists):
		var coord = Vector2i(walls["left"], walls["up"] + loading_room.doors["left"].coord)
		roomNode.set_cell( coord, 0, tiles["door_left"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x + 1, coord.y + 2)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		writtenTiles.push_back(coord)
	if(loading_room.doors["right"].exists):
		var coord = Vector2i(walls["right"], walls["up"] + loading_room.doors["right"].coord)
		roomNode.set_cell( coord, 0, tiles["door_right"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x - 1, coord.y + 2)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		writtenTiles.push_back(coord)
	if(loading_room.doors["up"].exists):
		var coord = Vector2i(walls["left"] + loading_room.doors["up"].coord, walls["up"])
		roomNode.set_cell( coord, 0, tiles["door_up_top"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x, coord.y + 1)
		roomNode.set_cell( coord, 0, tiles["door_up_upper"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x, coord.y + 1)
		roomNode.set_cell( coord, 0, tiles["door_up_lower"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x, coord.y + 1)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		writtenTiles.push_back(coord)
	if(loading_room.doors["down"].exists):
		var coord = Vector2i( walls["left"] + loading_room.doors["down"].coord, walls["down"])
		roomNode.set_cell( coord, 0, tiles["doormat"])
		writtenTiles.push_back(coord)
	
	for x in range(20):
		for y in range(20):
			if(writtenTiles.has(Vector2i(x,y))):
				continue
			elif( x < walls["left"] || 
				x > walls["right"] || 
				y < walls["up"] || 
				y > walls["down"] ):
				tilestring = "nothing"
			elif( ( y < walls["down"] - 1) && (x == walls["left"] || (x == walls["right"])) || 
				y == walls["up"] ):
				tilestring = "wall_top"
			elif( (x > walls["left"] &&
				  x < walls["right"] &&
				(y == walls["up"] + 1 || y == walls["up"] + 2)) ||
				 ((x == walls["left"] ||
				  x == walls["right"]) &&
				(y == walls["down"] - 1 || y == walls["down"]))):
				tilestring = "wall_side"
			else:
				tilestring = "floor"
			roomNode.set_cell(Vector2i(x, y), 0, tiles[tilestring])

#func generate_room(prev_index, door) -> room:
	#return room.new(prev_index, door)
