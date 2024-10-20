extends Object

var obstacle_fill_ratio = 0.2
var ornament_fill_ratio = 0.05

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
		
		doors[start_side].exists = true
		doors[start_side].room_index = start_index
		doors[start_side].mapped = mapped
	else:
		#this is just for the first room rn. would rather not but o well
		for door in doors:
			doors[door].exists = randf() < 0.75
			if(door == "left" || door == "right"):
				doors[door].coord = randi_range(0,height-1)
			if(door == "up" || door == "down"):
				doors[door].coord = randi_range(0,width-1)
		
	# add obstacles
	var roomsize = Vector2i(width, height)
	var total_tiles = float(width * height)
	while(float(obstacle_tiles.size()) / total_tiles < 0.25):
		if(randf()>0.999):
			break
		var pos = Vector2i(randi_range(0,roomsize.x-1), randi_range(0,roomsize.y-1))
		var obstacle = obstacles[randi_range(0,obstacles.size()-1)]
		var rotate = randi_range(0,3)
		var obsize = obstacle["obj_size"]
		var objectinvalid = false
		if(rotate == 1 || rotate == 3):
			obsize = Vector2i(obsize.y,obsize.x)
		for x in range(obsize.x):
			for y in range(obsize.y):
				if(x+pos.x>=roomsize.x || y+pos.y>=roomsize.y):
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
				"rot" = rotate,
				"size" = obsize
			})
	#print(this_obstacles)
	
	#add floor deco
	var filled_tiles = [];
	while(float(filled_tiles.size()) / total_tiles < 0.25):
		if(randf()>0.999):
			break
		var pos = Vector2i(randi_range(0,roomsize.x-1), randi_range(0,roomsize.y-1))
		var floor_ornament = floor_ornaments[randi_range(0,floor_ornaments.size()-1)]
		var rotate = randi_range(0,3)
		var obsize = floor_ornament["obj_size"]
		var objectinvalid = false
		if(rotate == 1 || rotate == 3):
			obsize = Vector2i(obsize.y,obsize.x)
		for x in range(obsize.x):
			for y in range(obsize.y):
				if(x+pos.x>=roomsize.x || y+pos.y>=roomsize.y):
					objectinvalid = true
					break
		if(!objectinvalid):
			for x in range(obsize.x):
				for y in range(obsize.y):
					filled_tiles.push_back(Vector2i(x,y)+pos)
			this_floor_ornament.push_back({
				"pos" = pos,
				"name" = floor_ornament.name,
				"rot" = rotate,
				"size" = floor_ornament["obj_size"]
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
	
	#print('before crop', world_coord, doors[start_side].coord, '  width:',width,' height:',height)

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
		
		#print('found intersection')
		
		#cropping
		var culling = {x = 0, y = 0}
		var bbx = bb1
		var bby = bb1
		if(door_coord.x < bb2.x0):
			bbx.x1 = min(bb1.x1, bb2.x0)
			culling.x= bb1.x1-bb1.x0
		if(door_coord.x > bb2.x1):
			bbx.x0 = max(bb1.x0, bb2.x1)
			culling.x= bb1.x1-bb1.x0
		if(door_coord.y < bb2.y0):
			bby.y1 = min(bb1.y1, bb2.y0)
			culling.y= bb1.y1-bb1.y0
		if(door_coord.y > bb2.y1):
			bby.y0 = max(bb1.y0, bb2.y1)
			culling.y= bb1.y1-bb1.y0
		
		if(culling.x && culling.y):
			if(culling.x * height > culling.y * width):
				bb1 = bbx
			else:
				bb1 = bby
		elif(culling.x):
			bb1 = bbx
		elif(culling.y):
			bb1 = bby
	
	
	world_coord = Vector2i(bb1.x0,bb1.y0)
	width = bb1.x1-bb1.x0
	height = bb1.y1-bb1.y0
	doors[start_side].coord = (door_coord.x - world_coord.x ) if (start_side=="up"||start_side=="down") else (door_coord.y - world_coord.y )
	
	#print('after crop', world_coord, doors[start_side].coord, '  width:',width,' height:',height)
	
	# do door convergence checks
	for door in doors:
		if(door == start_side): continue
		
		var wall_segments = []
		for i in range(height if( door == "left" || door == "right") else width):
			wall_segments.push_back(Vector2i(
				bb1.x0 if door=="left" else bb1.x1 if door=="right" else (bb1.x0+i),
				bb1.y0 if door=="up" else bb1.y1 if door=="down" else (bb1.y0+i),
			))
			
		for room in rooms:
			var oth_wall = { #seriously starting to think this might be even worse than my single use lookup tables
				x0= room.world_coord.x + (room.width if door=="left" else 0),
				y0= room.world_coord.y + (room.height if door=="up" else 0),
				x1= room.world_coord.x + (room.width if door!="right" else 0),
				y1= room.world_coord.y + (room.height if door!="down" else 0),
			}
			var doorkey = door_translate[door]
			var other_door_coord = room.world_coord + Vector2i(
				room.doors[doorkey].coord if (doorkey=="up"||doorkey=="down") else room.width if (doorkey=="right") else 0, 
				room.doors[doorkey].coord if (doorkey=="left"||doorkey=="right") else room.height if (doorkey=="down") else 0
			)
			
			for segment_index in range(wall_segments.size()-1, -1, -1):
				var seg = wall_segments[segment_index]
				if(other_door_coord == seg && room.doors[doorkey].exists):
					print('converging!!!!')
					doors[door].exists = true
					doors[door].coord = (seg.x - bb1.x0) if (door=="up"||door=="down") else (seg.y - bb1.y0)
					doors[door].room_index = room.room_index
					doors[door].mapped = room.doors[doorkey].mapped
					room.doors[doorkey].room_index = room_index
					break
				if(seg.x >= oth_wall.x0  && seg.x <= oth_wall.x1 && seg.y >= oth_wall.y0 && seg.y <= oth_wall.y1 ):
					#print('blocked wall!')
					wall_segments.remove_at(segment_index)
			
			if(doors[door].exists): #dont check the other rooms if u got a door
				break
		
		#if no convergence was found. generate door at a free wall segment
		if(!doors[door].exists):
			#print(door, wall_segments)
			if(wall_segments.size()>0): 
				doors[door].exists = randf() < 0.75
				var door_segment = wall_segments[randi_range(0,wall_segments.size()-1)]
				doors[door].coord = (door_segment.x - bb1.x0) if (door=="up"||door=="down") else (door_segment.y - bb1.y0)
			else:
				if(door == "left" || door == "right"):
					doors[door].coord = randi_range(0,height-1)
				if(door == "up" || door == "down"):
					doors[door].coord = randi_range(0,width-1)

var door_translate = {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
}
