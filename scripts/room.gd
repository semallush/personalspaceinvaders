extends Object

var width = 0
var height = 0
var world_coord = Vector2i(0,0)
var mapped = false
var mapped_correctly = false
var room_index = -1
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

var this_wall_ornament = []
var this_floor_ornament = []
var this_obstacles = []
var obstacle_tiles = []

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

func _init(start_index, start_side, door_coord, mapped, rooms, index, obstacles, wall_ornaments, floor_ornaments) -> void:
	
	room_index = index
	if(start_side):check_convergence(start_side, door_coord, rooms)
	if(width == 0):
		width = randi_range(max(6,doors["up"].coord, doors["down"].coord),18)
	width += width%2
	width = max(width,6)
	if(height == 0):
		height = randi_range(max(6,doors["left"].coord, doors["right"].coord),18)
	height += height%2
	height = max(height,6)
	
	if(start_side):
		world_coord = (door_coord 
			+ door_size_shift[start_side] * Vector2i(width-2, height-3)
			+ door_door_shift[start_side] * Vector2i(doors[start_side].coord,doors[start_side].coord)
			+ door_door_offset[start_side]
		)
		
	var check_rooms_direction = {
		"left"=	Vector2i(-12, floor(height/2)),
		"right"=Vector2i(width+12,floor(height/2)),
		"up"=	Vector2i(floor(width/2),-12),
		"down"=	Vector2i(floor(width/2), height+12)
	}
		
	for door in doors:
		if(door == start_side):
			doors[door].exists = true
			doors[door].room_index = start_index
			doors[door].mapped = mapped
		elif(doors[door].exists && doors[door].room_index != null):
			#print(rooms[doors[door].room_index].doors[door_translate[door]].mapped)
			doors[door].mapped = rooms[doors[door].room_index].doors[door_translate[door]].mapped
		else:
			#check if theres some shit in the way????
			var samplepos = world_coord+check_rooms_direction[door]
			for room in rooms:
				if(samplepos.x > room.world_coord.x && samplepos.y > room.world_coord.y
					&& samplepos.x < room.world_coord.x + room.width && samplepos.y < room.world_coord.y + room.height):
						continue
				
			doors[door].exists = randf() < 0.75
			
		if(doors[door].coord != 0): 
			if(door=="left" || door=="right" ): doors[door].coord = min(doors[door].coord, height-5)
			continue
		if(door == "left" || door == "right"):
			doors[door].coord = randi_range(1,height-5)
		if(door == "up" || door == "down"):
			doors[door].coord = randi_range(1,width-3)
	
	# add obstacles
	var roomsize = Vector2i(width-4, height-5)
	var total_tiles = roomsize.x * roomsize.y
	while(obstacle_tiles.size() / total_tiles < 0.25):
		if(randf()>0.999):
			break
		var pos = Vector2i(randi_range(0,roomsize.x), randi_range(0,roomsize.y))
		var obstacle = obstacles[randi_range(0,obstacles.size()-1)]
		var rotate = randi_range(0,3)
		var obsize = obstacle["obj_size"]
		var objectinvalid = false
		if(rotate == 1 || rotate == 3):
			obsize = Vector2i(obsize.y,obsize.x)
		for x in range(obsize.x):
			for y in range(obsize.y):
				if(x+pos.x>roomsize.x || y+pos.y>roomsize.y):
					objectinvalid = true
					break
				for tile in obstacle_tiles:
					if(x+pos.x==tile.x || y+pos.y==tile.y):
						objectinvalid = true
						break
		if(!objectinvalid):
			for x in range(obsize.x):
				for y in range(obsize.y):
					obstacle_tiles.push_back(Vector2i(x,y)+pos)
			this_obstacles.push_back({
				"pos" = pos,
				"name" = obstacle.name,
				"rot" = rotate
			})
	print(this_obstacles)
	
	#add floor deco
	var filled_tiles = [];
	while(filled_tiles.size() / total_tiles < 0.25):
		if(randf()>0.999):
			break
		var pos = Vector2i(randi_range(0,roomsize.x), randi_range(0,roomsize.y))
		var floor_ornament = floor_ornaments[randi_range(0,floor_ornaments.size()-1)]
		var rotate = randi_range(0,3)
		var obsize = floor_ornament["obj_size"]
		var objectinvalid = false
		if(rotate == 1 || rotate == 3):
			obsize = Vector2i(obsize.y,obsize.x)
		for x in range(obsize.x):
			for y in range(obsize.y):
				if(x+pos.x>roomsize.x || y+pos.y>roomsize.y):
					objectinvalid = true
					break
		if(!objectinvalid):
			for x in range(obsize.x):
				for y in range(obsize.y):
					filled_tiles.push_back(Vector2i(x,y)+pos)
			this_floor_ornament.push_back({
				"pos" = pos,
				"name" = floor_ornament.name,
				"rot" = rotate
			})
		
	#print(this_floor_ornament)

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
		var roomsize = Vector2i(room.width-2, room.height-2)
		for doorkey in room.doors:
			var door = room.doors[doorkey]
			if(!door.exists || doorkey==door_translate[start_side] || door.room_index != null):
				continue
				
			var doorcoord = room.world_coord + Vector2i(
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
							if(start_side=="left"||start_side=="right"):
								convergent_doors.push_back({
									"key"=door_translate[doorkey],
									"doorcoord"=doorcoord,
									"door"=door,
									"room_index"=room.room_index
								})
								doors[door_translate[doorkey]].exists = true
								doors[door_translate[doorkey]].room_index = room.room_index
								door.room_index = room_index
	
	if convergent_doors.size() > 0:
		print('this room is: ', room_index)
		print('convergent doors ', convergent_doors)
		print('my doors are ', doors)
		
		var door = convergent_doors[0]
		var ydiff = door["doorcoord"].y - door_coord.y
		var xdiff = door["doorcoord"].x - door_coord.x
		if start_side=="left":
			match door["key"]:
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
					height = doors["left"].coord + ydiff
					doors["down"].coord = door["doorcoord"].x - door_coord.x
		if start_side=="right":
			match door["key"]:
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
					width = doors["down"].coord - xdiff
					
					doors["right"].coord = randi_range(1,18-ydiff)
					height = doors["right"].coord + ydiff
		#if start_side=="up":
			#match door["key"]:
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
			#match door["key"]:
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
