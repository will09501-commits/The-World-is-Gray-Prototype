extends Area2D
@export var SPEED = 200
@export var manaCost = 20
@export var cooldown = 2
@export var damage = 20
@export var doesDamage = true
@export var knforce = 20
@export var knduration = 0.32
@onready var velocity = Vector2()
@export var freeze_time = 0.5
@export var stats = {"damage": damage, "manaCost": manaCost, "cooldown": cooldown, "freeze_time": freeze_time}
func _ready():
	pass
func _physics_process(delta: float) -> void:
	velocity.x = SPEED * delta
	translate(velocity)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
func get_damage_vars() -> Array:
	return [damage, knforce, knduration]
	



func _on_body_entered(body: Node2D) -> void:
	print("collides with " + str(body.get_groups()))
	if body.is_in_group("enemy"):
		body.apply_damage(damage, (body.global_position - global_position).normalized(), knforce, knduration)
