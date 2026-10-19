extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	body.update_respawn(global_position)
	sprite.play("active")
