extends Resource
class_name TileResource

enum TileType { GROUND, WATER, VOID }

@export var name: String = "Terra"
@export var type: TileType = TileType.GROUND
@export var texture_idx: Vector2i = Vector2i.ZERO # Índice no seu SpriteSheet/Atlas
@export var movement_cost: int = 1
@export var top_pivot : Vector2 = Vector2.ZERO
