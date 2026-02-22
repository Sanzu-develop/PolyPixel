extends Node

var unit_scene : PackedScene
var unit : Dictionary
var units : Dictionary[String,PieceResource] = {"warrior": PieceResource.new()}

func create_unit(grid_pos : Vector2i, parent : Node2D, player : int, type : String):
	if not units.has(type): return
	
	if unit.has(grid_pos) : return
	
	var data = units[type].duplicate()
	
	unit[grid_pos] = {"unit":spawn_unit(grid_pos,data,parent,player),"data":data}

func spawn_unit(grid_pos : Vector2i, data : PieceResource,unit_parent : Node2D, player := 0) -> Node2D:
	if unit_parent.get_child_count() <= player or player < 0: return null
	
	var unit_spawner = unit_parent.get_child(player)
	
	if unit_spawner.name != "Player%d" % player: return null
	
	var current_unit = unit_scene.instantiate()
	current_unit.data = data
	
	unit_spawner.add_child(current_unit)
	
	current_unit.position = IT.tile_to_isometric(grid_pos)
	
	current_unit.death.connect(Callable(self,"piece_die"))
	
	return current_unit

func select_unit(tile : Vector2i):
	if not unit.has(tile) or not unit[tile].has("unit") : return
	
	var current_unit = unit[tile]["unit"]
	
	current_unit.pop()

func piece_move(tile_grid : Vector2i,touch_grid : Vector2i) -> bool:
	var move = unit[tile_grid]["unit"].get_valid_moves(tile_grid)
	if move.has(touch_grid):
		var local = IT.tile_to_isometric(touch_grid)
		unit[tile_grid]["unit"].move_to_local(local)
		unit[touch_grid] = unit[tile_grid]
		unit.erase(tile_grid)
		return true
	return false

func piece_atack(piece_grid : Vector2i,target_grid : Vector2i):
	var move = unit[piece_grid]["unit"].get_valid_moves(piece_grid)
	if move.has(target_grid):

		if not unit.has(piece_grid) or not unit.has(target_grid): return
		if piece_grid == target_grid: return
		
		var piece = unit[piece_grid]["unit"]
		var target = unit[target_grid]["unit"]
		
		
		piece.atack(target,true)

func piece_die(tile_unit : Vector2i):
	await get_tree().create_timer(0.5).timeout
	unit[tile_unit]["unit"].queue_free()
	unit.erase(tile_unit)
	pass

func atualizer(unit_dict : Dictionary,units_dict : Dictionary,scene_unit : PackedScene = unit_scene):
	unit = unit_dict
	units = units_dict
	unit_scene = scene_unit
