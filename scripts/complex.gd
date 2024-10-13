extends Node
var room = load("res://scripts/room.gd")

@onready
var roomNode = get_node("room")
@onready
var playerNode = get_node("lenin")

@onready
var precinctNode = get_node("precinct")

@onready
var minimap = get_node("minimap")
@onready
var uinode = get_node("ui")

@onready
var door_sfx = get_node("door_sfx")

var mapscale = 5
var linewidth = 1

var rooms = [
	room.new(null, null, Vector2(0,0), false, [],0)
]
var room_index = 0

var emptycolor = Color(0,0,0)
var linecolor = Color(1,1,1)
var doorcolor = Color(1,0,0)
var highlight = Color(1,1,1,0.3)

var wrongMaps = 0

var default_doors = {
		"left": Vector2i(0,0),
		"right": Vector2i(0,0),
		"up": Vector2i(0,0),
		"down": Vector2i(0,0),
}
var door_coords = default_doors
var door_translate = {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
}
var door_place_player = {
		"left": Vector2i(1,0),
		"right": Vector2i(-1,0),
		"up": Vector2i(0,1),
		"down": Vector2i(0,-1)
}
var walls = {
	"left": 0,
	"right": 0,
	"up": 0,
	"down": 0,
}

var tiles = {
	"floor": Vector2i(randi_range(0,1),randi_range(0,1)),
	"wall_top": Vector2i(1,2),
	"wall_side": Vector2i(0,2),
	"nothing": Vector2i(0,3),
	"door_up_upper": Vector2i(2,0),
	"door_up_lower": Vector2i(2,1),
	"door_up_top": Vector2i(2,2),
	"door_left": Vector2i(3,0),
	"door_right": Vector2i(3,1),
	"doormat": Vector2i(3,2),
}

var firstRoom = true

func _ready() -> void:
	load_room(0,"left")

func _process(delta: float) -> void:
	var player_tile = Vector2i(floor((playerNode.position.x)/16), floor((playerNode.position.y)/16))
	var doorkey = door_coords.find_key(player_tile)
	if(doorkey && !playerNode.isStepping):
		door_sfx.play()
		
		# check if mapped correctly, then invent pigs
		rooms[room_index].verify_mapping()
		if (rooms[room_index].mapped_correctly):
			var pigs_exist = false
			for existing in precinctNode.trackedPigs:
				if existing[0] == room_index:
					pigs_exist = true
					break
			if !pigs_exist:
				playerNode.increaseScore(100)
				var count = randi_range(0,2)
				precinctNode.inventPig(count, room_index)
				if (count>0):
					pigs_exist = true
			if pigs_exist:
				
				uinode.toggle_cop_highlight(room_index, true)
		else:
			wrongMaps+=1			 
		var newroom = rooms[room_index].doors[doorkey].room_index
		
		#uinode.toggle_player_highlight(room_index, false)
		if(newroom != null):
			room_index = newroom
			load_room(room_index, door_translate[doorkey])
		if(newroom == null):
			
			rooms.push_back(room.new(
				room_index, 
				door_translate[doorkey], 
				rooms[room_index].world_coord + door_coords[doorkey] - Vector2i(walls["left"],walls["up"]),
				rooms[room_index].doors[doorkey].mapped,
				rooms,
				rooms.size()
			))
			rooms[room_index].doors[doorkey].room_index = rooms.size()-1
			room_index = rooms.size()-1
			
			precinctNode.updateCrossStar(rooms)
			load_room(room_index, door_translate[doorkey])

func load_room(index, side) -> void:
	
	#uinode.toggle_player_highlight(index, true)
	
	var loading_room = rooms[index]
	var tilestring
	walls = {
		"left": 10 - loading_room.width/2,
		"right": 9 + loading_room.width/2,
		"up": 10 - loading_room.height/2,
		"down": 9 + loading_room.height/2,
	}
	
	roomNode.clear()
	var writtenTiles = []
	door_coords = default_doors
	if(loading_room.doors["left"].exists):
		var coord = Vector2i(walls["left"], walls["up"] + loading_room.doors["left"].coord)
		roomNode.set_cell( coord, 0, tiles["door_left"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x + 1, coord.y + 2)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		door_coords["left"] = coord
		writtenTiles.push_back(coord)
	if(loading_room.doors["right"].exists):
		var coord = Vector2i(walls["right"], walls["up"] + loading_room.doors["right"].coord)
		roomNode.set_cell( coord, 0, tiles["door_right"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x - 1, coord.y + 2)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		door_coords["right"] = coord
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
		door_coords["up"] = coord
		writtenTiles.push_back(coord)
	if(loading_room.doors["down"].exists):
		var coord = Vector2i( walls["left"] + loading_room.doors["down"].coord, walls["down"])
		roomNode.set_cell( coord, 0, tiles["doormat"])
		door_coords["down"] = coord
		writtenTiles.push_back(coord)
	
	if(!firstRoom):
		var portal_to_pos = (door_coords[side] + door_place_player[side])*16
		playerNode.position = Vector2(portal_to_pos.x+8, portal_to_pos.y+8)
	firstRoom = false
	
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
				roomNode.set_cell(Vector2i(x, y), 0, loading_room.floor_tile)
				continue
			roomNode.set_cell(Vector2i(x, y), 0, tiles[tilestring])
	precinctNode.killPigs()
	
	uinode.updatearrows()

func map_room() -> void:
	rooms[room_index].mapped = true
	
	var roomsize = Vector2(rooms[room_index].width-2, rooms[room_index].height-2)
	var roomcoord = rooms[room_index].world_coord
	
	var new_room_map_outside = ColorRect.new()
	new_room_map_outside.name = str(room_index)
	minimap.add_child(new_room_map_outside)
	new_room_map_outside.set_begin(
		minimap.get_size()/2 + Vector2(roomcoord)
	)
	new_room_map_outside.set_size(roomsize)
	new_room_map_outside.set_color(linecolor)
	
	var new_room_map_inside = ColorRect.new()
	new_room_map_inside.name = str("cop")
	new_room_map_outside.add_child(new_room_map_inside)
	new_room_map_inside.set_begin(Vector2(linewidth, linewidth))
	new_room_map_inside.set_size(new_room_map_outside.get_size() - Vector2(linewidth*2, linewidth*2))
	new_room_map_inside.set_color(emptycolor)
	
	var new_room_map_highlight = ColorRect.new()
	new_room_map_highlight.name = str("player")
	new_room_map_outside.add_child(new_room_map_highlight)
	new_room_map_highlight.set_begin(Vector2(linewidth, linewidth))
	new_room_map_highlight.set_size(new_room_map_outside.get_size() - Vector2(linewidth*2, linewidth*2))
	new_room_map_highlight.set_color(highlight)
	
	for doorkey in rooms[room_index].doors:
		var door = rooms[room_index].doors[doorkey]
		
		var door_line = ColorRect.new()
		door_line.name = doorkey
		new_room_map_outside.add_child(door_line)
		door_line.set_begin(Vector2i(
			door.coord if (doorkey=="up"||doorkey=="down") else roomsize.x if (doorkey=="right") else 0, 
			door.coord if (doorkey=="left"||doorkey=="right") else roomsize.y if (doorkey=="down") else 0)
			+ doormapoffset[doorkey]
		)
		door_line.set_size(doormaplinesize[doorkey])
		door_line.set_color(doorcolor if rooms[room_index].doors[doorkey].mapped else linecolor)
	
	uinode.toggle_player_highlight(room_index, true)

var doormapoffset = {
		"left": Vector2i(0,0),
		"right": Vector2i(-1,0),
		"up": Vector2i(-1,0),
		"down": Vector2i(-1,-1)
}
var doormaplinesize = {
		"left": Vector2i(1,2),
		"right": Vector2i(1,2),
		"up": Vector2i(2,1),
		"down": Vector2i(2,1)
}

func update_doors(direction) -> void:
	#if(!rooms[room_index].doors[direction].exists):
	
	get_node('minimap/'+str(room_index)+'/'+direction).set_color(
		doorcolor if rooms[room_index].doors[direction].mapped else linecolor
	)
	var other_index = rooms[room_index].doors[direction].room_index
	if(other_index):
		if(rooms[other_index].mapped):
			get_node('minimap/'+str(other_index)+'/'+door_translate[direction]).set_color(
				doorcolor if rooms[other_index].doors[door_translate[direction]].mapped else linecolor
			)
			
