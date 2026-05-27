extends Area2D


func _ready() -> void:
	self.modulate = Color.BLUE
	$Boom.visible = false
	await  get_tree().create_timer(2.0).timeout
	$Sprite2D.visible = false
	$Boom.visible = true
	await get_tree().create_timer(0.5).timeout
	queue_free()

	
	
