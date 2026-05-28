extends Area2D


func _ready() -> void:
	self.modulate = Color.BLUE
	$Boom.visible = false
	await  get_tree().create_timer(2.0).timeout
	$Sprite2D.visible = false
	$Boom.visible = true
	var interacting = get_overlapping_bodies()
	for body in interacting:
		print(body.get_groups())
		if body.is_in_group('Player'):
			print('hey')
			var knockback_direction = (body.global_position - global_position).normalized()
			body.apply_knockback(knockback_direction, 200, 0.12)
	await get_tree().create_timer(0.5).timeout
	queue_free()

	
	
