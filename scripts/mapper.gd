extends Sprite2D

@onready
var world = get_parent()

@onready
var arrows = {
	"left": get_child(0),
	"right": get_child(1),
	"up": get_child(2),
	"down": get_child(3)
}
var door_translate = {
	"left": "right",
	"right": "left",
	"up": "down",
	"down": "up"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for arrow in arrows:
		arrows[arrow].get_child(0).play()
		arrows[arrow].get_child(1).play()
	get_child(4).play()
	updatearrows()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mapping"):
		show()
		if(!world.rooms[world.room_index].mapped):
			world.map_room()
	if Input.is_action_just_released("mapping"):
		hide()
	if Input.is_action_pressed("mapping"):
		for arrow in arrows:
			if Input.is_action_just_pressed(arrow):
				var door = world.rooms[world.room_index].doors[arrow]
				door.mapped = !door.mapped
				if(door.room_index != null):
					world.rooms[door.room_index].doors[door_translate[arrow]].mapped = door.mapped
				updatearrows()
				world.update_doors(arrow)

func updatearrows() -> void:
	var doors = world.rooms[world.room_index].doors
	for arrow in arrows:
		if (doors[arrow].mapped):
			arrows[arrow].get_child(0).show()
			arrows[arrow].get_child(1).hide()
		else:
			arrows[arrow].get_child(1).show()
			arrows[arrow].get_child(0).hide()

func toggle_cop_highlight(room_index, on) -> void:
	if(!get_node('../minimap/'+str(room_index)+'/inner')):return
	if(on): get_node('../minimap/'+str(room_index)+'/inner').set_color(Color(0,0,1))
	if(!on): get_node('../minimap/'+str(room_index)+'/inner').set_color(Color(0,0,0))

func toggle_player_highlight(room_index, on) -> void:
	if(!get_node('../minimap/'+str(room_index)+'/inner')):return
	if(on): get_node('../minimap/'+str(room_index)+'/inner').set_color(Color(0.3,0.3,0.3))
	if(!on): get_node('../minimap/'+str(room_index)+'/inner').set_color(Color(0.0,0.0,0.0))
	
