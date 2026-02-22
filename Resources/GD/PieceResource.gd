extends Resource
class_name PieceResource

@export var name: String
@export var texture: Texture2D
@export_group("Stats")
@export var max_health: int = 10
@export var resistance: int = 2
@export var damage: int = 5
@export var move_range: int = 3
@export var atack_range: int = 1

@export_group("Movement")
# Ex: [[1,2], [-1,2]] para um movimento tipo L de cavalo
# Ou deixe vazio para movimento padrão (caminhada)
@export var special_move_offsets: Array[Vector2i] = []
@export var special_atack_offsets: Array[Vector2i] = []

@export_group("Tags")
@export var behavior : Dictionary[String,AtributeResource]
