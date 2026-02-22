extends AtributeResource
class_name Pop


func execute(AR : ActionResource):
	var user = AR.user
	
	if user.current_hp <= 0 : return
	
	var tween = user.create_tween()
	tween.tween_property(user,"scale",Vector2(1.3,1.3),0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(user,"scale",Vector2(1.0,1.0),0.15).set_ease(Tween.EASE_OUT_IN)
	
	pass
