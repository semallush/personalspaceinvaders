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

@onready
var furniture_layer = get_node("furniture")

var mapscale = 5
var linewidth = 1

var rooms = [
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

var obstacle_paths = [
	"bed01",
	"bed02",
	"chair01",
	"plant01",
	"sofa01"
]
var wall_ornament_paths = [
	
]
var floor_ornament_paths = [
	"rug01",
	"rug02"
]

var obstacles = []
var wall_ornaments = []
var floor_ornaments = []

var obstacle_nodes = []
var wall_ornament_nodes = []
var floor_ornament_nodes = []


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
	for path in obstacle_paths:
		var tex = load("res://assets/obstacles/"+path+".png")
		obstacles.push_back({
			"texture" = tex,
			"obj_size" = Vector2i(ceil(tex.get_width()/16),ceil(tex.get_height()/16)),
			"name" = path
		})
	for path in wall_ornament_paths:
		var tex = load("res://assets/wall ornament/"+path+".png")
		wall_ornaments.push_back({
			"texture" = tex,
			"obj_size" = Vector2i(ceil(tex.get_width()/16),ceil(tex.get_height()/16)),
			"name" = path
		})
	for path in floor_ornament_paths:
		var tex = load("res://assets/floor ornament/"+path+".png")
		floor_ornaments.push_back({
			"texture" = tex,
			"obj_size" = Vector2i(ceil(tex.get_width()/16),ceil(tex.get_height()/16)),
			"name" = path
		})
	rooms.push_back(room.new(null, null, Vector2(0,0), false, [],0,obstacles,wall_ornaments, floor_ornaments))
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
			var door = rooms[room_index].doors[doorkey]
			rooms.push_back(room.new(
				room_index, 
				door_translate[doorkey], 
				rooms[room_index].world_coord
					+ Vector2i(
					door.coord if (doorkey=="up"||doorkey=="down") else walls["right"] - walls["left"] - 1 if (doorkey=="right") else 0, 
					door.coord if (doorkey=="left"||doorkey=="right") else walls["down"] - walls["up"] - 1 if (doorkey=="down") else 0
					),
				rooms[room_index].doors[doorkey].mapped,
				rooms,
				rooms.size(),
				obstacles,
				wall_ornaments,
				floor_ornaments
			))
			#print('old coord:', rooms[room_index].world_coord)
			rooms[room_index].doors[doorkey].room_index = rooms.size()-1
			room_index = rooms.size()-1
			#print('new coord:', rooms[room_index].world_coord)
			
			precinctNode.updateCrossStar(rooms)
			load_room(room_index, door_translate[doorkey])

func load_room(index, side) -> void:
	
	#uinode.toggle_player_highlight(index, true)
	for obstacle_node in obstacle_nodes:
		obstacle_node.free()
	obstacle_nodes = []
	
	var loading_room = rooms[index]
	var tilestring
	walls = {
		"left": 9 - loading_room.width/2,
		"right": 0,
		"up": 10 - loading_room.height/2,
		"down": 0,
	}
	walls["right"] = walls["left"]+loading_room.width+1;
	walls["down"] = walls["up"]+loading_room.height+1;
	
	roomNode.clear()
	var writtenTiles = []
	door_coords = default_doors
	if(loading_room.doors["left"].exists):
		var coord = Vector2i(walls["left"], walls["up"] + loading_room.doors["left"].coord-1)
		roomNode.set_cell( coord, 0, tiles["door_left"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x + 1, coord.y + 2)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		door_coords["left"] = coord
		writtenTiles.push_back(coord)
	if(loading_room.doors["right"].exists):
		var coord = Vector2i(walls["right"], walls["up"] + loading_room.doors["right"].coord-1)
		roomNode.set_cell( coord, 0, tiles["door_right"])
		writtenTiles.push_back(coord)
		coord = Vector2i(coord.x - 1, coord.y + 2)
		roomNode.set_cell( coord, 0, tiles["doormat"])
		door_coords["right"] = coord
		writtenTiles.push_back(coord)
	if(loading_room.doors["up"].exists):
		var coord = Vector2i(walls["left"] + loading_room.doors["up"].coord+1, walls["up"] - 2)
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
		var coord = Vector2i( walls["left"] + loading_room.doors["down"].coord+1, walls["down"] - 1)
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
				y < walls["up"]-2 || 
				y > walls["down"]-1 ):
				tilestring = "nothing"
			elif(  y < walls["down"]  && (x == walls["left"] || (x == walls["right"])) || 
				y == walls["up"]-2 ):
				tilestring = "wall_top"
			elif( (x > walls["left"] &&
				  x < walls["right"] &&
				(y == walls["up"] || y == walls["up"] - 1)) ||
				 ((x == walls["left"] ||
				  x == walls["right"]) &&
				(y == walls["down"] + 1 || y == walls["down"]))):
				tilestring = "wall_side"
			else:
				roomNode.set_cell(Vector2i(x, y), 0, loading_room.floor_tile)
				continue
			roomNode.set_cell(Vector2i(x, y), 0, tiles[tilestring])
			
	#for ornament in rooms[room_index].this_floor_ornament:
		#var obs_sprite = Sprite2D.new()
		#var texture
		#for ornament_texture in floor_ornaments:
			#if(ornament_texture["name"] == ornament["name"]):
				#texture = ornament_texture["texture"]
		#obs_sprite.set_texture(texture)
		#obs_sprite.rotate(ornament["rot"]*PI/2)
		#obs_sprite.set_centered(false)
		#obs_sprite.translate(Vector2( (walls["left"]+ornament["pos"].x+2)*16, (walls["up"]+ornament["pos"].y+4)*16))
		#furniture_layer.add_child(obs_sprite)
		#obstacle_nodes.push_back(obs_sprite)
	#for obstacle in rooms[room_index].this_obstacles:
		#var obs_sprite = Sprite2D.new()
		#var texture
		#for obstacle_texture in obstacles:
			#if(obstacle_texture["name"] == obstacle["name"]):
				#texture = obstacle_texture["texture"]
		#obs_sprite.set_texture(texture)
		#obs_sprite.rotate(obstacle["rot"]*PI/2)
		#obs_sprite.set_centered(false)
		#obs_sprite.translate(Vector2( (walls["left"]+obstacle["pos"].x+2)*16, (walls["up"]+obstacle["pos"].y+4)*16))
		#furniture_layer.add_child(obs_sprite)
		#obstacle_nodes.push_back(obs_sprite)
		
	precinctNode.killPigs()
	
	uinode.updatearrows()

func map_room() -> void:
	rooms[room_index].mapped = true
	
	var roomsize = Vector2(rooms[room_index].width, rooms[room_index].height)
	var roomcoord = rooms[room_index].world_coord
	
	var new_room_map_outside = ColorRect.new()
	new_room_map_outside.name = str(room_index)
	minimap.add_child(new_room_map_outside)
	
	## this is the cool version where rooms overlap a bit but its too confusing and i think probably also buggy
	#new_room_map_outside.set_begin(
		#minimap.get_size()/2 + Vector2(roomcoord) + Vector2(-1,-1) + Vector2(rooms[room_index].map_offset)
	#)
	#new_room_map_outside.set_size(roomsize + Vector2(2,2))
	
	## boring no overlap version
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
			door.coord if (doorkey=="up"||doorkey=="down") else roomsize.x - 1 if (doorkey=="right") else 0, 
			door.coord if (doorkey=="left"||doorkey=="right") else roomsize.y - 1 if (doorkey=="down") else 0)
		)
		door_line.set_size(doormaplinesize[doorkey])
		if(door.coord == (roomsize.x if (doorkey=="up"||doorkey=="down") else roomsize.y) - 1):
			door_line.set_size(Vector2(1,1))
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
	get_node('minimap/'+str(room_index)+'/'+direction).set_color(
		doorcolor if rooms[room_index].doors[direction].mapped else linecolor
	)
	var other_index = rooms[room_index].doors[direction].room_index
	if(other_index):
		if(rooms[other_index].mapped):
			get_node('minimap/'+str(other_index)+'/'+door_translate[direction]).set_color(
				doorcolor if rooms[other_index].doors[door_translate[direction]].mapped else linecolor
			)
