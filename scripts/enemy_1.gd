extends CharacterBody2D
@onready var player: CharacterBody2D = $"../player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var health: int = 20
var nums = [-1,1]
var invincible = false
var direction = nums[randi_range(0,1)]
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _ready() -> void:
	velocity.x = direction * 20
var prev_position
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if sprite.animation != "death":
		if velocity.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		if global_position == prev_position:
			direction *= -1
			velocity.x = 20 * direction
		prev_position = global_position
	else:
		velocity.x = 0
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			velocity.x = 20 * direction
	move_and_slide()
	
func apply_damage(damage: int, kndirection: Vector2, force: float, knockback_duration: float):
	if !invincible and sprite.animation != "death":
		invincible = true
		health -= damage
		sprite.play("damaged")
		knockback = kndirection * force
		knockback_timer = knockback_duration
	

func _on_damage_zone_body_entered(body: Node2D) -> void:
	if body == player:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, 200, 0.12)


func _on_animated_sprite_2d_animation_finished() -> void:
	if !invincible:
		queue_free()
	if health <= 0:
		sprite.play("death")
	else:
		sprite.play("default")
	invincible = false
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("colides with " + str(body.get_groups()))
	if body.is_in_group("damagers"):
		var damage_vars = body.get_damage_vars()
		apply_damage(damage_vars[0], (body.global_position - global_position).normalized(), damage_vars[1], damage_vars[2])
