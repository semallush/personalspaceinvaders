extends Object

var width = 0
var height = 0
var doors  = {
	"left": {
		exists = false,
		coord = 0,
		room_index = null,
	},
	"right": {
		exists = false,
		coord = 0,
		room_index = null,
	},
	"up": {
		exists = false,
		coord = 0,
		room_index = null,
	},
	"down": {
		exists = false,
		coord = 0,
		room_index = null,
	}
}
var floor_tile = Vector2i(randi_range(0,1),randi_range(0,1))

func _init(start_index, start_side) -> void:
	width = randi_range(10,18)
	height = randi_range(10,18)
	for door in doors:
		if(door == start_side):
			doors[door].exists = true;
			doors[door].room_index = start_index;
		else:
			doors[door].exists = randf() > 0.1
		if(doors[door].exists && (door == "left" || door == "right")):
			doors[door].coord = randi_range(1,height-5)
		if(doors[door].exists && (door == "up" || door == "down")):
			doors[door].coord = randi_range(1,width-3)
