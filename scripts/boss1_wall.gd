extends AnimatableBody2D
var target = 0
var velocity = Vector2()
var time_left = 7
@export var attack_timer = 6
func _ready() -> void:
	z_index = 1
	print('made at', position)
	
func _physics_process(delta: float) -> void:
	attack_timer -= delta
	if abs(target - position.x) < 30:
		velocity.x = 0
		finisher(attack_timer)
	else:
		velocity.x = signf(target - position.x) * 4

	translate(velocity)
	
func finisher(time):
	await get_tree().create_timer(time).timeout
	queue_free()
