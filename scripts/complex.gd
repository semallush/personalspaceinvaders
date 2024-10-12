extends Node
var room = load("res://scripts/room.gd")

@onready
var roomNode = get_node("room")

var rooms = [
	room.new(null, null)
]

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func load_room(index, side) -> void:
	room.tile_map_data = null

#func generate_room(prev_index, door) -> room:
	#return room.new(prev_index, door)
