extends Area2D
@export var cooldown = 0.5
@export var manaCost = 3
@export var damage = 5
@export var doesDamage = true
@export var knforce = 20
@export var knduration = 0.32
@export var freeze_time = 0
@export var stats = {"damage": damage, "manaCost": manaCost, "cooldown": cooldown, "freeze_time": freeze_time}

func _ready() -> void:
	$AnimatedSprite2D.play()
func get_stats() -> Dictionary:
	return {"damage": damage, "manaCost": manaCost, "cooldown": cooldown}

func _on_body_entered(body: Node2D) -> void:
	print("Collides")
	if body.is_in_group("enemy"):
		body.apply_damage(damage, (body.global_position - global_position).normalized(), knforce, knduration)


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
