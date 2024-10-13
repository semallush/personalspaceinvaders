extends Object

var width = 0
var height = 0
var world_coord = Vector2i(0,0)
var mapped = false
var mapped_correctly = false
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

func _init(start_index, start_side, door_coord, mapped, rooms) -> void:
	
	#check_convergence(start_side, door_coord, rooms)
	
	width = randi_range(10,18)
	width += width%2
	height = randi_range(10,18)
	height += height%2
	for door in doors:
		if(door == start_side):
			doors[door].exists = true;
			doors[door].room_index = start_index;
			doors[door].mapped = mapped
		else:
			doors[door].exists = randf() < 0.8
			
		if(door == "left" || door == "right"):
			doors[door].coord = randi_range(1,height-5)
		if(door == "up" || door == "down"):
			doors[door].coord = randi_range(1,width-3)
	
	if(start_side):
		world_coord = (door_coord 
			+ door_size_shift[start_side] * Vector2i(width-2, height-3)
			+ door_door_shift[start_side] * Vector2i(doors[start_side].coord,doors[start_side].coord)
			+ door_door_offset[start_side]
		)

func verify_mapping() -> void:
	if(mapped):
		for door in doors:
			if doors[door].exists != doors[door].mapped:
				mapped_correctly = false
				return
		mapped_correctly = true

func check_convergence(start_side, door_coord, rooms) -> void:
	var convergence_check_box = Vector2i(18,18)
	var check_areas = {
		"left_corner" = Vector2i(),
		"right_corner" = Vector2i(),
		"opposite" = Vector2i()
	}
	var check_dir = check_direction[start_side]
	var check_window = {
		"x0"= door_coord.x + check_dir.x*18,
		"y0"= door_coord.y + check_dir.y*18,
		"x1"= door_coord.x + check_dir.z*18,
		"y1"= door_coord.y + check_dir.w*18
	}
	
	var convergent_doors = []
	
	for room in rooms:
		var roomsize = Vector2i(rooms[room].width-2, rooms[room].height-2)
		for doorkey in rooms[room].doors:
			var door = rooms[room].doors[doorkey]
			if(!door.exists || doorkey==door_translate[start_side] || door.room_index != null):
				continue
				
			var doorcoord = rooms[room].world_coord + Vector2i(
				door.coord if (doorkey=="up"||doorkey=="down") else roomsize.x if (doorkey=="right") else 0, 
				door.coord if (doorkey=="left"||doorkey=="right") else roomsize.y if (doorkey=="down") else 0)
			
			if(doorcoord.x > check_window["x0"] && doorcoord.y > check_window["y0"] &&
				doorcoord.x < check_window["x1"] && doorcoord.y < check_window["y1"]):
					var betterwindow = door_options[start_side][door_translate[doorkey]] * 18
					var bettercheck = {
						"x0"= door_coord.x + betterwindow.x,
						"y0"= door_coord.y + betterwindow.y,
						"x1"= door_coord.x + betterwindow.z,
						"y1"= door_coord.y + betterwindow.w
					}
					if(doorcoord.x > bettercheck["x0"] && doorcoord.y > bettercheck["y0"] &&
						doorcoord.x < bettercheck["x1"] && doorcoord.y < bettercheck["y1"]):
							convergent_doors.push_back({
								"key"=door_translate[doorkey],
								"doorcoord"=doorcoord,
								"door"=door
							})
							doors[door_translate[doorkey]].exists = true
							doors[door_translate[doorkey]].room_index = room
							door.room_index = rooms.size()-1
	
	if convergent_doors.size() > 0:
		print(convergent_doors)
		
		var door = convergent_doors[0]
		var ydiff = door["doorcoord"].y - door_coord.y
		var xdiff = door["doorcoord"].x - door_coord.x
		if start_side=="left":
			match door["doorkey"]:
				"up":
					doors["left"].coord = door_coord.y - door["doorcoord"].y
					doors["up"].coord = door["doorcoord"].x - door_coord.x
				"right":
					if(ydiff > 0):
						doors["left"].coord = randi_range(1,18-ydiff)
					else:
						doors["left"].coord = randi_range(1-ydiff,18)
					doors["right"].coord = doors["left"].coord + ydiff
					width = xdiff
				"down":
					doors["left"].coord = randi_range(1,18-ydiff)
					height = doors["left"] + ydiff
					doors["down"].coord = door["doorcoord"].x - door_coord.x
		if start_side=="right":
			match door["doorkey"]:
				"up":
					doors["right"].coord = door_coord.y - door["doorcoord"].y
					doors["up"].coord = randi_range(1,18+xdiff)
					width = doors["up"].coord - xdiff
				"left":
					width = -1*xdiff
					if(ydiff > 0):
						doors["right"].coord = randi_range(1,18-ydiff)
					else:
						doors["right"].coord = randi_range(1-ydiff,18)
					doors["left"].coord = doors["right"].coord + ydiff
				"down":
					doors["down"].coord = randi_range(1,18+xdiff)
					width = doors["up"].coord - xdiff
					
					doors["left"].coord = randi_range(1,18-ydiff)
					height = doors["left"] + ydiff
		#if start_side=="up":
			#match door["doorkey"]:
				#"up":
					#doors["left"].coord = door_coord.y - door["doorcoord"].y
					#doors["up"].coord = door["doorcoord"].x - door_coord.x
				#"right":
					#if(ydiff > 0):
						#doors["left"].coord = randi_range(1,18-ydiff)
					#else:
						#doors["left"].coord = randi_range(1-ydiff,18)
					#doors["right"].coord = doors["left"].coord + ydiff
				#"down":
					#doors["left"].coord = randi_range(1,18-ydiff)
					#height = doors["left"] + ydiff
		#if start_side=="down":
			#match door["doorkey"]:
				#"up":
					#doors["left"].coord = door_coord.y - door["doorcoord"].y
					#doors["up"].coord = door["doorcoord"].x - door_coord.x
				#"right":
					#if(ydiff > 0):
						#doors["left"].coord = randi_range(1,18-ydiff)
					#else:
						#doors["left"].coord = randi_range(1-ydiff,18)
					#doors["right"].coord = doors["left"].coord + ydiff
				#"down":
					#doors["left"].coord = randi_range(1,18-ydiff)
					#height = doors["left"] + ydiff
						
		

var door_options = {
	"left"={
		"right" = Vector4i(0,-1,1,1),
		"up" = 	  Vector4i(0,-1,1,0),
		"down" =  Vector4i(0,0,1,1), 
	},
	"right"={
		"left" =  Vector4i(-1,-1,0,1),
		"up" = 	  Vector4i(-1,-1,0,0),
		"down" =  Vector4i(-1,0,0,1), 
	},
	"up"={
		"left" =  Vector4i(-1,0,0,1),
		"right" = Vector4i(0,0,1,1),
		"down" =  Vector4i(-1,0,1,1), 
	},
	"down"={
		"left" =  Vector4i(-1,-1,0,0),
		"right" = Vector4i(0,-1,1,0),
		"up" = 	  Vector4i(-1,-1,1,0), 
	},
}

var door_coord_translate = {
	"left"=	Vector2i(0,1), #check area relative to door: x1,y1,x2,y2
	"right"=Vector2i(0,1),
	"up"=	Vector2i(1,-1),
	"down"=	Vector2i(1,0)
}

var check_direction = {
	"left"=	Vector4i(0,-1,1,1), #check area relative to door: x1,y1,x2,y2
	"right"=Vector4i(-1,-1,0,1),
	"up"=	Vector4i(-1,0,1,-1),
	"down"=	Vector4i(-1,-1,1,0)
}

var door_translate = {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
}
