extends CharacterBody2D

#@onready var player: CharacterBody2D = $"../player"
@onready var sprite: Sprite2D = $Sprite2D

@export var health: int = 20
const LASER = preload("res://scenes/boss1_laser.tscn")
var nums = [-1,1]
var invincible_timer = 0.0
var direction = nums[randi_range(0,1)]
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var attack_cooldown = 2.0
var attacks = [lasers]
func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta
	else:
		attacks.pick_random().call()
		attack_cooldown = 4.0
	if invincible_timer > 0:
		invincible_timer -= delta
	if invincible_timer < 0:
		invincible_timer = 0
	
func apply_damage(damage: int, kndirection: Vector2, force: float, knockback_duration: float):
	if invincible_timer <= 0 and sprite.animation != "death":
		invincible_timer = 0.3
		health -= damage
		sprite.play("damaged")
		#knockback = kndirection * force
		#knockback_timer = knockback_duration
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("colides with " + str(body.get_groups()))
	if body.is_in_group("damagers"):
		var damage_vars = body.get_damage_vars()
		apply_damage(damage_vars[0], (body.global_position - global_position).normalized(), damage_vars[1], damage_vars[2])

func lasers():
	for i in range(9):
		var laser = LASER.instantiate()
		get_parent().add_child(laser)
		laser.position = $Marker2D.global_position
		laser.move_local_y((i * 20) - 100)
	pass
