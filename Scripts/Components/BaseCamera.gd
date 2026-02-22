extends Camera2D

@export_category("Caracteristicas")
@export_group("Velocidades")
@export var drag_speed: float = 1.0
@export var zoom_speed: float = 0.05

@export_group("Limites e Suavização")
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var smoothing: float = 15.0 # Quanto maior, mais rápido segue o dedo

var target_zoom: float = 1.0
var target_position: Vector2
var touches = {}

func _ready():
	target_position = position
	target_zoom = zoom.x

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

	if event is InputEventScreenDrag:
		touches[event.index] = event.position
		
		if touches.size() == 1:
			# Ajusta o destino baseado no arrasto
			target_position -= event.relative * (1.0 / zoom.x) * drag_speed
			
		elif touches.size() == 2:
			var finger_positions = touches.values()
			var dist = finger_positions[0].distance_to(finger_positions[1])
			var prev_dist = (finger_positions[0] - event.relative).distance_to(finger_positions[1])
			
			if event.index == 1:
				prev_dist = finger_positions[0].distance_to(finger_positions[1] - event.relative)
			
			var zoom_factor = dist / prev_dist
			target_zoom = clamp(target_zoom * zoom_factor, min_zoom, max_zoom)

func _process(delta):
	# Interpolação suave (Lerp)
	position = position.lerp(target_position, smoothing * delta)
	var zoom_value = lerp(zoom.x, target_zoom, smoothing * delta)
	zoom = Vector2(zoom_value, zoom_value)

func go_to(local : Vector2, aproximate : float = target_zoom):
	target_position = local
	target_zoom = aproximate
