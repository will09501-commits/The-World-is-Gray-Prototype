extends Area2D


func _ready() -> void:
	await  get_tree().create_timer(2.0).timeout
	print('Timer completed')
	$Sprite2D.visible = false
	$Boom.visible = true
	queue_free()
	print(self.is_queued_for_deletion())
	
	
