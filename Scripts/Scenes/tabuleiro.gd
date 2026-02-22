extends Node2D

# Tamanho do tabuleiro
@export var board_size: Vector2i = Vector2i(100, 100)

@export_group("Packed Scenes")
# Uma unidade moldavel 
@export var unit_scene: PackedScene 

@export_group("Vector")
# Distancia entre Tiles
@export var distance : Vector2 = Vector2(32,16)
# Pivot de deslocamento dos tiles
@export var pivot : Vector2 = Vector2.ZERO

#Tiles Manager
@export_group("Polygon")
# Formato do polygono
@export var polygon : Array[Vector2] = [Vector2(-15.5,0),Vector2(0,7.5),Vector2(15.5,0),Vector2(0,-7.5)]
# Polygon2D que desenha o polygono selecionado
@export var drawer_polygon : Polygon2D

# Tile selecionado ( grid )
var tile_grid : Vector2i
var tile_current : String = "void"

@export_group("Referencias")
# Pai e tabuleiro
@export var parent : Node2D
@export var tile_spawn : Node2D
# Pai das peças
@export var unit_parent : Node2D
# Camera de jogo
@export var cam : Camera2D

@export var panel : Panel

@export_group("TileSet")
# Referencia de todos os resources de terreno
@export var grounds : Dictionary[String,TileResource] = {"grass": TileResource.new()}
@export var units : Dictionary[String,PieceResource] = {"warrior": PieceResource.new()}

var grid = {} # Dicionário para guardar { Vector2i: TileData }
var unit = {} # Dicionario que guarda as unidades { Vector2i: { "unit" : Node2D, "data: PieceResource }
var polygons = {} # Dicionario que guarda os polygonos criados { Vector2i: Polygon2D }


var map : Dictionary


## --- Iniciar e processar ---


# Inicializar
func _ready():
	parent = get_parent()
	atualize_isometric_transform()
	create_map()
	generate_board()
	atualize_unit_manager()
	UM.create_unit(Vector2i(2,4),unit_parent,0,"warrior")
	UM.create_unit(Vector2i(5,4),unit_parent,0,"warrior")
	UM.create_unit(Vector2i(6,4),unit_parent,0,"knight")

# Controle de toque
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not event.pressed:
			board_atualize()
	
	if event is InputEventScreenDrag:
		#Reseta a grade se mover o dedo
		if tile_grid.x != -1 and event.relative > Vector2(5,5):
			draw_selected_tile(false)


## --- Atualize ---


func atualize_unit_manager():
	UM.atualizer(unit,units,unit_scene)

func atualize_isometric_transform():
	IT.distance = distance
	IT.pivot = pivot


## --- Map ---


# Criar mapa
func create_map():
	generate_noise_map(board_size.x,board_size.y,randi(),10.0,0.1)

# Re/Gerar tabuleiro
func generate_board():
	# Limpa o tabuleiro se já existir
	for n in get_children(): n.queue_free()
	grid.clear()
	
	for x in board_size.x:
		for y in board_size.y:
			var pos = Vector2i(x, y)
			
			var tile_type = convert_float_for_tile_name(map[pos]) if map.has(pos) else "grass"
			
			create_tile(pos,tile_type)

# Converter float em tile
func convert_float_for_tile_name(value : float) -> String:
	#print(value)
	if value < -0.45:
		return "largewater"
	elif value < -0.25:
		return "mediumwater"
	elif value < 0.0:
		return "water"
	elif value < 0.09:
		return "sand"

	return "grass"

# Gerar um mapa em noise
func generate_noise_map(
	width: int,
	height: int,
	seed_: int = randi(),
	scale_: float = 10.0,
	frequency: float = 0.3,
	noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX
) -> Dictionary:
	var noise := FastNoiseLite.new()
	noise.seed = seed_
	noise.noise_type = noise_type
	noise.frequency = frequency
	
	map.clear()
	
	for y in range(height):
		for x in range(width):
			var nx = float(x) / scale_
			var ny = float(y) / scale_
			
			var value := noise.get_noise_2d(nx, ny)
			# value vem entre -1 e 1
			
			map[Vector2i(x, y)] = value
	
	return map


## --- TileManager ---


# Criar tile
func create_tile(grid_pos: Vector2i,type: String = "grass"):
	if not grounds.has(type): return
	
	var data : TileResource = grounds[type].duplicate()
	
	grid[grid_pos] = data
	
	draw_tile(grid_pos,data.texture_idx)

# Desenhar tile
func draw_tile(grid_pos : Vector2i,texture_idx : Vector2i):
	parent.set_cell(grid_pos,0,texture_idx)


## --- TileSelect ---


# Desenhar polygono de selecao e desativa caso precise
func draw_selected_tile(is_true : bool = true):
	if is_true:
		drawer_polygon.polygon = polygon
		drawer_polygon.position = IT.tile_to_isometric(tile_grid) + grid[tile_grid].top_pivot
	else:
		tile_grid = Vector2i(-1,-1)
	drawer_polygon.visible = is_true

func create_polygon(parent_: Node2D, tile : Vector2i = tile_grid, color_id : int = 0, polygoned : Array[Vector2] = polygon) -> Polygon2D:
	if not grid.has(tile): return null
	
	var colors : Array[Color] = [Color(0.002, 0.0, 0.493, 1.0),Color(0.824, 0.0, 0.0, 1.0)]
	
	var poly = Polygon2D.new()
	
	parent_.add_child(poly)
	
	poly.color = colors[clamp(color_id,0,colors.size()-1)]
	poly.polygon = polygoned
	poly.position = IT.tile_to_isometric(tile) + grid[tile].top_pivot
	
	return poly

func redraw_polygons(parent_: Node2D, tiles : Array[Vector2i] = [], polygoned : Array[Vector2] = polygon):
	
	if polygons.size() > 0:
		for i in polygons.keys():
			var poly_target = polygons[i]
			polygons.erase(i)
			poly_target.queue_free()
		
	var atack_offsets = unit[tile_grid]["unit"].get_valid_moves(tile_grid,"atack") if unit.has(tile_grid) else []
	for i in tiles:
		var tile_color = 1 if i != tile_grid and unit.has(i) and atack_offsets.has(i) else 0
		
		var poly = create_polygon(parent_, i, tile_color, polygoned) if not unit.has(i) or tile_color != 0 else null
		
		if poly != null : 
			
			poly.scale = Vector2.ZERO
			
			var tween = create_tween()
			tween.tween_property(poly,"scale",Vector2(1,1),0.15)
			
			polygons[i] = poly


## --- BoardManager ---

func board_atualize():
	var touch_world = get_global_mouse_position() + Vector2(0,3)
	var touch_grid = IT.isometric_to_tile(touch_world)
	
	if not grid.has(touch_grid) : tile_current = "void"

	# Camera Zoon
	if unit.has(touch_grid):
		UM.select_unit(touch_grid)
		if cam.zoom.x < 1.4 : cam.go_to(touch_world,max(cam.target_zoom,1.5))
		tile_current = "unit"

	# Tile Manager
	if tile_grid == touch_grid:
		tile_current = "tile" if unit.has(tile_grid) and tile_current == "unit" else "void"
	elif unit.has(tile_grid) and not unit.has(touch_grid) and grid.has(touch_grid): 
		if not UM.piece_move(tile_grid,touch_grid): tile_current = "unit" if grid.has(touch_grid) else "void"
	elif unit.has(tile_grid) and unit.has(touch_grid):# and unit[tile_grid]["unit"].get_valid_moves(tile_grid,"atack").has(touch_grid):
		UM.piece_atack(tile_grid,touch_grid)
	
	# Obter os blocos de movimentação da peça
	var moves : Array[Vector2i] = []
	if unit.has(touch_grid) and tile_current == "unit":
		moves = unit[touch_grid]["unit"].get_valid_moves(touch_grid)# if unit.has(touch_grid) else []
	
	# Atualizar a malha de seleção
	if grid.has(touch_grid) and tile_grid != touch_grid:
		tile_grid = touch_grid 
		draw_selected_tile()
	elif tile_grid == touch_grid : draw_selected_tile(false)
	
	# Desenha tiles de movimentação
	redraw_polygons(tile_spawn,moves)
