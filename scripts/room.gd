extends Object

var width = 0
var height = 0
var world_coord = Vector2i(0,0)
var mapped = false
var doors  = {
	"left": {
		exists = false,
		mapped = false,
		coord = 0,
		room_index = null,
	},
	"right": {
		exists = false,
		mapped = false,
		coord = 0,
		room_index = null,
	},
	"up": {
		exists = false,
		mapped = false,
		coord = 0,
		room_index = null,
	},
	"down": {
		exists = false,
		mapped = false,
		coord = 0,
		room_index = null,
	}
}

var door_size_shift = {
	"left"=	Vector2i(0,0),
	"right"=Vector2i(-1,0),
	"up"=	Vector2i(0,0),
	"down"=	Vector2i(0,-1)
}
var door_door_shift = {
	"left"=	Vector2i(0,-1),
	"right"=Vector2i(0,-1),
	"up"=	Vector2i(-1,0),
	"down"=	Vector2i(-1,0)
}
var door_door_offset = { #this is necessary because of how badly i fucked up the room loading
	"left"=	Vector2i(-1, -2),
	"right"=Vector2i(0,-2),
	"up"=	Vector2i(-1,-2),
	"down"=	Vector2i(0,-3)
}

var floor_tile = Vector2i(randi_range(0,1),randi_range(0,1))

func _init(start_index, start_side, door_coord) -> void:
	width = randi_range(10,18)
	width += width%2
	height = randi_range(10,18)
	height += height%2
	for door in doors:
		if(door == start_side):
			doors[door].exists = true;
			doors[door].room_index = start_index;
		else:
			doors[door].exists = randf() < 0.5
		if(doors[door].exists && (door == "left" || door == "right")):
			doors[door].coord = randi_range(1,height-5)
		if(doors[door].exists && (door == "up" || door == "down")):
			doors[door].coord = randi_range(1,width-3)
	
	if(start_side):
		world_coord = (door_coord 
			+ door_size_shift[start_side] * Vector2i(width-2, height-3)
			+ door_door_shift[start_side] * Vector2i(doors[start_side].coord,doors[start_side].coord)
			+ door_door_offset[start_side]
		)
