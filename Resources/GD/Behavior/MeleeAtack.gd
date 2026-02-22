extends AtributeResource
class_name MeleeAtack

#

func execute(AR : ActionResource):
	var user = AR.user
	var target = AR.target
	var respost = AR.respost
	var current_hp = AR.life
	var max_hp = AR.max_life
	
	var current_damage = AR.damage
	
	if current_hp <= 0: return
	elif current_hp <= int(max_hp / 2) and not respost: current_damage = int(current_damage / 2)
	
	var current_position = user.position
	var target_position = target.position
	
	var tile_user = IT.isometric_to_tile(current_position)
	var tile_target = IT.isometric_to_tile(target_position)
	
	if not user.get_valid_moves(tile_user,"atack").has(tile_target): return
	
	
	var tween = user.create_tween()
	tween.tween_property(user,"position",target.position,0.1)
	target.damaged(current_damage,user,respost)
	tween.tween_property(user,"position",current_position,0.1)
	pass
