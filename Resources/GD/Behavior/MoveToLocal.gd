extends AtributeResource
class_name MoveToLocalResource

@export var seconds : float = 0.5


func execute(AR : ActionResource):
	var user = AR.user
	var local = AR.local
	
	if user.current_hp <= 0 : return
	
	user.sprite.flip_h = user.position.x < local.x if user.position.x != local.x else user.sprite.flip_h
	var tween = user.create_tween()
	tween.parallel()
	tween.tween_property(user,"position",local,seconds)
	
	pass
