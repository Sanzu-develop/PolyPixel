extends Node2D
class_name Unit

@export var sprite : Sprite2D
@export var data: PieceResource
@export var act_r : ActionResource = ActionResource.new()
var current_hp: int = 10
var tile : Vector2i

@warning_ignore("unused_signal")
signal death(current_tile : Vector2i)

func _ready():
	if data:
		current_hp = data.max_health
		sprite.texture = data.texture
	if act_r:
		act_r = act_r.duplicate(true)

func get_valid_moves(current_pos: Vector2i,type : String = "move") -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	
	if type == "move" and current_hp > 0:
		if data.special_move_offsets.size() > 0:
			# Movimentação tipo Xadrez (offsets fixos)
			for offset in data.special_move_offsets:
				moves.append(current_pos + offset)
		else:
			# Movimentação padrão (raio de alcance)
			for x in range(-data.move_range, data.move_range + 1):
				for y in range(-data.move_range, data.move_range + 1):
					if abs(x) + abs(y) <= data.move_range or data.move_range == 1:
						moves.append(current_pos + Vector2i(x, y))
	if type == "atack" and current_hp > 0:
		if data.special_atack_offsets.size() > 0:
			# Movimentação tipo Xadrez (offsets fixos)
			for offset in data.special_atack_offsets:
				moves.append(current_pos + offset)
		else:
			# Movimentação padrão (raio de alcance)
			for x in range(-data.atack_range, data.atack_range + 1):
				for y in range(-data.atack_range, data.atack_range + 1):
					if abs(x) + abs(y) <= data.atack_range or data.atack_range == 1:
						moves.append(current_pos + Vector2i(x, y))
	if not data.behavior.has("move_to_local") and type == "move" or not data.behavior.has("atack") and type == "atack": return []
	return moves

func move_to_local(local: Vector2):
	var behavior = "move_to_local"
	if not data.behavior.has(behavior): return
	
	var ar = get_ar()
	ar.local = local
	
	var current_behavior = data.behavior[behavior]
	current_behavior.execute(ar)

func pop():
	var behavior = "pop"
	if not data.behavior.has(behavior): return
	
	var ar = get_ar()
	
	var current_behavior = data.behavior[behavior]
	current_behavior.execute(ar)

func damaged(count : int,target : Node2D, respost : bool = true):
	var behavior = "damaged"
	if not data.behavior.has(behavior): return
	
	var ar = get_ar()
	ar.target = target
	ar.damaged = count
	ar.respost = respost
	
	var current_behavior = data.behavior[behavior]
	current_behavior.execute(ar)

func atack(target : Node2D,accept_respost : bool = true):
	var behavior = "atack"
	if not data.behavior.has(behavior): return
	
	var ar = get_ar()
	ar.target = target
	ar.respost = accept_respost
	
	var current_behavior = data.behavior[behavior]
	current_behavior.execute(ar)

func get_tile(new_tile : Vector2i):
	tile = new_tile

func get_ar() -> ActionResource:
	
	var ar = act_r.duplicate(true)
	
	ar.user = self
	ar.damage = data.damage
	ar.life = current_hp
	ar.max_life = data.max_health
	ar.resistance = data.resistance
	
	return ar
