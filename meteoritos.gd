# meteoritos.gd (Asignado a la raíz Area2D del meteorito)
extends Area2D

@export var speed: float = 150.0
@export var rotation_speed: float = 3.0 # Velocidad a la que gira el meteorito sobre su eje

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.ZERO

func setup(spawn_position: Vector2, player_target: Vector2) -> void:
	global_position = spawn_position
	
	# Dirección fija en la que va a avanzar
	direction = (player_target - global_position).normalized()
	
	if animated_sprite:
		animated_sprite.play("default") # Ajusta al nombre de tu animación

func _process(delta: float) -> void:
	# 1. Movimiento en línea recta
	global_position += direction * speed * delta
	
	# 2. Rotación continua sobre su propio eje
	rotation += rotation_speed * delta
