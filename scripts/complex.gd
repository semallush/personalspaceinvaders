extends Node
var room = load("res://scripts/room.gd")

@onready
var roomNode = get_node("room")

var rooms = [
	room.new(null, null)
]

var tiles = {
	"floor": Vector2i(0,0),
	"wall": Vector2i(0,1),
	"nothing": Vector2i(1,0),
}

func _ready() -> void:
	load_room(0,"left")
	#roomNode.set_cell(coords: Vector2i, 
						#source_id: int = -1, 
						#atlas_coords: Vector2i = Vector2i(-1, -1), 
						#alternative_tile: int = 0)

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
	
	var writtenTiles = []
	if(loading_room.doors["left"].exists):
		var coord = Vector2i(walls["left"], walls["up"] + loading_room.doors["left"].coord)
		roomNode.set_cell( coord, 0, tiles["door_left"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x + 1, coord.y + 1)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		writtenTiles.push_back(coord)
	if(loading_room.doors["right"].exists):
		var coord = Vector2i(walls["right"], walls["up"] + loading_room.doors["right"].coord)
		roomNode.set_cell( coord, 0, tiles["door_right"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x - 1, coord.y + 1)
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
		var coord = Vector2i( walls["left"] + loading_room.doors["down"].coord, walls["down"] - 1)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		writtenTiles.push_back(coord)
	
	roomNode.clear()
	for x in range(20):
		for y in range(20):
			if(writtenTiles.has(Vector2i(x,y))):
				continue
			elif( x < walls["left"] || 
				x > walls["right"] || 
				y < walls["up"] || 
				y > walls["down"] ):
				tilestring = "nothing"
			elif( x == walls["left"] || 
				x == walls["right"] || 
				y == walls["up"] || 
				y == walls["down"] ):
				tilestring = "wall_top"
			elif( (x > walls["left"] &&
				  x < walls["right"] &&
				(y == walls["up"] - 1 || y == walls["up"] - 2)) ||
				 ((x == walls["left"] ||
				  x == walls["right"]) &&
				(y == walls["down"] - 1 || y == walls["down"] - 2))):
				tilestring = "wall_side"
			else:
				tilestring = "floor"
			roomNode.set_cell(Vector2i(x, y), 0, tiles[tilestring])

#func generate_room(prev_index, door) -> room:
	#return room.new(prev_index, door)
