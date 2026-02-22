extends Node

# Distancia entre Tiles
@export var distance : Vector2 = Vector2(32,16)
# Pivot de deslocamento dos tiles
@export var pivot : Vector2 = Vector2.ZERO


# Transforma uma cordenada isometrica em simples ( tile )
func tile_to_isometric(grid_pos: Vector2i) -> Vector2:
	# Ajuste os valores 64 e 32 conforme o tamanho do seu tile
	return Vector2((grid_pos.x - grid_pos.y) * distance.x + pivot.x, (grid_pos.x + grid_pos.y) * distance.y + pivot.y)

# Transformar uma coordenada em isometrica
func isometric_to_tile(world_pos: Vector2) -> Vector2i:
	# Remove o pivot
	var local_pos = world_pos - pivot

	var x = (local_pos.x / distance.x + local_pos.y / distance.y) / 2.0
	var y = (local_pos.y / distance.y - local_pos.x / distance.x) / 2.0

	return Vector2i(floor(x), floor(y))
