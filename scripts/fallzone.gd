extends Area2D


@onready var timer: Timer = $Timer
@export var respawnx = 100
@export var respawny = 100
@onready var player: CharacterBody2D = $"../player"


func _on_body_entered(body: Node2D) -> void:
	print("you fell")
	print(player.position)
	timer.start()
	if body.get_class() == "CharacterBody2D":
		body.apply_knockback(Vector2.ZERO,0,0)
	


func _on_timer_timeout() -> void:
	print("reset")
	player.position[0] = respawnx
	player.position[1] = respawny
	
