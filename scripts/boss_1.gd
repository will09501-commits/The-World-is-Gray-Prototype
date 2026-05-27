extends CharacterBody2D

#@onready var player: CharacterBody2D = $"../player"
@onready var sprite: Sprite2D = $Sprite2D

@export var health: int = 200
const LASER = preload("res://scenes/boss1_laser.tscn")
const WALL = preload("res://scenes/boss1_wall.tscn")
const SPIKE = preload("res://scenes/spikes.tscn")
var nums = [-1,1]
var invincible_timer = 0.0
var direction = 1
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var attack_cooldown = 2.0
var attacks = {walls: 8}
func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta
	else:
		var attack = attacks.keys().pick_random()
		attack.call()
		attack_cooldown = attacks[attack]
	if invincible_timer > 0:
		invincible_timer -= delta
	if invincible_timer <= 0:
		$Sprite2D.modulate = Color.HOT_PINK
		invincible_timer = 0
	
func apply_damage(damage: int, kndirection: Vector2, force: float, knockback_duration: float):	
	if invincible_timer <= 0:
		invincible_timer = 0.3
		health -= damage
		$Sprite2D.modulate = Color.RED
		#knockback = kndirection * force
		#knockback_timer = knockback_duration
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("colides with " + str(body.get_groups()))
	if body.is_in_group("damagers"):
		var damage_vars = body.get_damage_vars()
		apply_damage(damage_vars[0], (body.global_position - global_position).normalized(), damage_vars[1], damage_vars[2])

func lasers():
	for i in range(8):
		var laser = LASER.instantiate()
		get_parent().add_child(laser)
		laser.z_index = -1
		laser.position = $Marker2D.global_position
		laser.move_local_y((i * 20) - 100)
	var missing2 = randi_range(0, 20)
	for i in range(18):
		if i != missing2:
			var laser = LASER.instantiate()
			get_parent().add_child(laser)
			laser.z_index = -1
			laser.position = $Marker2D.global_position
			laser.rotate(PI / 2)
			laser.move_local_y((i * 20) - 175)


func walls():
	var target = $Marker2D.global_position.x + randi_range(-15,15) * 10
	for i in range(2):
		var wall = WALL.instantiate()
		get_parent().add_child(wall)
		wall.position = $Marker2D.global_position
		wall.move_local_x((-1 ** (i + 1)) * 200)
		wall.move_local_y(60)
		wall.target = target
	await get_tree().create_timer(4).timeout
	var spike = SPIKE.instantiate()
	get_parent().add_child(spike)
	spike.position = $Marker2D.global_position
	spike.move_local_y(60)
	spike.move_local_x(target - $Marker2D.global_position.x)
