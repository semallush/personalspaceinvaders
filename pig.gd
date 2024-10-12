extends CharacterBody2D

var astar_grid = AStarGrid2D.new()

@onready
var roomNode = get_node("../room")

@onready
var worldNode = get_parent()

var tiles = {
	"wall_top": Vector2i(1,2),
	"wall_side": Vector2i(0,2),
	"nothing": Vector2i(0,3),
}


func _ready():


	var cells = roomNode.get_used_cells()
	
	var room = worldNode.rooms[worldNode.room_index]


	
	

#func getBounds(cells) -> Array:
	#var bounds = []
	#
	#var TLFound = false
	#var TRFound = false
	#var BLFound = false
	#var BRFound = false
	#
	#var TL = null
	#var TR = null
	#var BR = null
	#var BL = null
	#print(roomNode.get_cell_atlas_coords(Vector2i(10,10)))
	#print('---')
	#for i in range(0,cells.size()):
		#
		#if !TLFound:
			##print(tiles["wall_top"])
			##print(cells[i])
			##print(roomNode.get_cell_atlas_coords(cells[i]))
			##print('---------')
			#if roomNode.get_cell_atlas_coords(cells[i]) == tiles["wall_top"]:
				#print('hello')
				#TL = roomNode.get_cell_atlas_coords(cells[i])
				#TLFound = true
		#if !TRFound:
			#if roomNode.get_cell_atlas_coords(cells[i]) == tiles["nothing"]:
				#TR = roomNode.get_cell_atlas_coords(cells[i-1])
				#TRFound = true
				#break
	#for i in range(cells.size()-1, 0):
		#if !BRFound:
			#if roomNode.get_cell_atlas_coords(cells[i]) == tiles["wall_side"]:
				#BR = roomNode.get_cell_atlas_coords(cells[i])
				#BRFound = true
		#if !BLFound:
			#if roomNode.get_cell_atlas_coords(cells[i]) == tiles["nothing"]:
				#BL = roomNode.get_cell_atlas_coords(cells[i+1])
				#BLFound = true
				#break
			#
	#bounds = [TL, TR, BL, BR]
	#return bounds
##func _process(delta):
