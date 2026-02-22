extends AtributeResource
class_name DamagedResource


func execute(AR : ActionResource):
	var user = AR.user
	var target = AR.target
	var current_hp = AR.life
	var count = AR.damaged
	var resistance = AR.resistance
	var respost = AR.respost
	
	@warning_ignore("integer_division")
	var damaged = max(int(count / resistance),1)
	current_hp = max(current_hp - damaged,0)
	user.current_hp = current_hp
	
	var tween = user.create_tween()
	tween.tween_property(user,"scale",Vector2(1.3,1.3),0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(user,"scale",Vector2(1.0,1.0),0.1).set_ease(Tween.EASE_OUT_IN)
	
	if current_hp <= 0:
		tween.tween_property(user,"rotation",deg_to_rad(45.0),0.1).set_ease(Tween.EASE_OUT)
		user.death.emit(IT.isometric_to_tile(user.position))
	
	elif respost:
		tween.finished.connect(func():user.atack(target,false))
		
