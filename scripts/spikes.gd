extends Area2D
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = -1
	await get_tree().create_timer(1).timeout
	velocity.y = -10
	await get_tree().create_timer(0.001).timeout
	velocity.y = 0
	await get_tree().create_timer(1).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	translate(velocity)




func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group('Player'):
		
		var knockback_direction = (body.global_position - global_position).normalized()
		knockback_direction.y -= 2
		print(knockback_direction)
		body.apply_knockback(knockback_direction, 200, 0.12)
		
