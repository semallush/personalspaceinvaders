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

var map_offset = Vector2i(0,0)

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
var door_door_offset = { #this is only for the mapping now
	"left"=	Vector2i(1,0),
	"right"=Vector2i(-1,0),
	"up"=	Vector2i(0,1),
	"down"=	Vector2i(0,-1)
}

var floor_tile = Vector2i(randi_range(0,1),randi_range(0,1))

func _init(start_index, start_side, door_coord, mapped, rooms, index, obstacles, wall_ornaments, floor_ornaments) -> void:
	
	#print('door', door_coord)
	
	room_index = index
	
	width = randi_range(6,18)
	height = randi_range(6,16)
	
	if(start_side):
		doors[start_side].coord = randi_range(0,height if (start_side=="left"||start_side=="right") else width)
		map_offset = rooms[start_index].map_offset + door_door_offset[start_side]
		check_convergence(start_side, door_coord, rooms)
	
	#print('size ', width, ", ", height)
		
	#this is for checking where a door should be impossible bc it goes into another room.
	#i think its probably more efficient to do this in the previous bit
	var check_rooms_direction = {
		"left"=	Vector2i(-1, floor(height/2)),
		"right"=Vector2i(width+1,floor(height/2)),
		"up"=	Vector2i(floor(width/2),-1),
		"down"=	Vector2i(floor(width/2), height+1)
	}
		
	for door in doors:
		if(door == start_side):
			doors[door].exists = true
			doors[door].room_index = start_index
			doors[door].mapped = mapped
			continue
		elif(doors[door].exists && doors[door].room_index != null):
			#print(rooms[doors[door].room_index].doors[door_translate[door]].mapped)
			doors[door].mapped = rooms[doors[door].room_index].doors[door_translate[door]].mapped
		else:
			#check if theres some shit in the way????
			#var samplepos = world_coord+check_rooms_direction[door]
			#for room in rooms:
				#if(samplepos.x > room.world_coord.x && samplepos.y > room.world_coord.y
					#&& samplepos.x < room.world_coord.x + room.width && samplepos.y < room.world_coord.y + room.height):
						#continue
				
			doors[door].exists = randf() < 0.75
			
		if(doors[door].coord != 0): 
			# skip doors that are already mapped in check_convergence
			#if(door=="left" || door=="right" ): doors[door].coord = min(doors[door].coord, height-5)
			continue
		if(door == "left" || door == "right"):
			doors[door].coord = randi_range(0,height-1)
		if(door == "up" || door == "down"):
			doors[door].coord = randi_range(0,width-1)
		
	# add obstacles
	var roomsize = Vector2i(width, height)
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
	#print(this_obstacles)
	
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
	
	world_coord = (door_coord 
		+ door_size_shift[start_side] * Vector2i(width, height)
		+ door_door_shift[start_side] * Vector2i(doors[start_side].coord,doors[start_side].coord)
	)
	
	print('before crop', world_coord, doors[start_side].coord, '  width:',width,' height:',height)

	var bb1 = {	x0 = world_coord.x, 
				y0 = world_coord.y,
				x1 = world_coord.x + width,
				y1 = world_coord.y + height} #bounding box
	
	#epic room chopping math
	for room in rooms:
		var bb2 = {	x0 = room.world_coord.x, 
					y0 = room.world_coord.y,
					x1 = room.world_coord.x + room.width,
					y1 = room.world_coord.y + room.height}
		
		#extremely elegant intersection check
		if !(bb2.x0<bb1.x1 && bb2.x1>bb1.x0 && bb2.y0<bb1.y1 && bb2.y1>bb1.y0):
			continue
		
		print('found intersection')
		
		#cropping
		var culling = {x = 0, y = 0}
		if(door_coord.x < bb2.x0):
			bb1.x1 = min(bb1.x1, bb2.x0)
			culling.x= bb1.x1-bb1.x0
		if(door_coord.x > bb2.x1):
			bb1.x0 = max(bb1.x0, bb2.x1)
			culling.x= bb1.x1-bb1.x0
		if(door_coord.y < bb2.y0):
			bb1.y1 = min(bb1.y1, bb2.y0)
			culling.y= bb1.y1-bb1.y0
		if(door_coord.y > bb2.y1):
			bb1.y0 = max(bb1.y0, bb2.y1)
			culling.y= bb1.y1-bb1.y0
		
		if(culling.x && culling.y):
			pass #do area calcs
	
	world_coord = Vector2i(bb1.x0,bb1.y0)
	width = bb1.x1-bb1.x0
	height = bb1.y1-bb1.y0
	doors[start_side].coord = (door_coord.x - world_coord.x ) if (start_side=="up"||start_side=="down") else (door_coord.y - world_coord.y )
	
	print('after crop', world_coord, doors[start_side].coord, '  width:',width,' height:',height)
	

#var door_options = {
	#"left"={
		#"right" = Vector4i(0,-1,1,1),
		#"up" = 	  Vector4i(0,-1,1,0),
		#"down" =  Vector4i(0,0,1,1), 
	#},
	#"right"={
		#"left" =  Vector4i(-1,-1,0,1),
		#"up" = 	  Vector4i(-1,-1,0,0),
		#"down" =  Vector4i(-1,0,0,1), 
	#},
	#"up"={
		#"left" =  Vector4i(-1,0,0,1),
		#"right" = Vector4i(0,0,1,1),
		#"down" =  Vector4i(-1,0,1,1), 
	#},
	#"down"={
		#"left" =  Vector4i(-1,-1,0,0),
		#"right" = Vector4i(0,-1,1,0),
		#"up" = 	  Vector4i(-1,-1,1,0), 
	#},
#}

var door_translate = {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
}
