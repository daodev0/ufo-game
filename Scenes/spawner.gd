# spawner.gd
extends Node2D

@export var meteor_scene: PackedScene
@export var player: Node2D
@export var margin: float = 150.0

@export_group("Dificultad Escalable")
@export var spawn_interval: float = 3.0       # Tiempo inicial entre oleadas (segundos)
@export var min_interval: float = 0.8          # Límite mínimo de tiempo entre oleadas
@export var meteors_per_wave: int = 1         # Cantidad inicial de meteoritos por oleada
@export var max_meteors_per_wave: int = 6     # Máximo de meteoritos por oleada
@export var difficulty_interval: float = 10.0 # Cada cuántos segundos aumenta la dificultad

var spawn_timer: Timer
var difficulty_timer: Timer

func _ready() -> void:
	await get_tree().process_frame
	
	# 1. Timer principal de generación (spawn)
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# 2. Timer de dificultad (aumenta la cantidad/frecuencia periódicamente)
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = difficulty_interval
	difficulty_timer.autostart = true
	difficulty_timer.timeout.connect(_on_increase_difficulty)
	add_child(difficulty_timer)
	
	# Primera oleada
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	if meteor_scene == null or player == null:
		return

	# Instanciar 'meteors_per_wave' meteoritos en la misma oleada
	for i in range(meteors_per_wave):
		spawn_single_meteor()

func spawn_single_meteor() -> void:
	var spawn_pos = get_random_spawn_position()
	var meteor = meteor_scene.instantiate()
	get_tree().current_scene.add_child(meteor)
	
	# Enviamos la posición exterior y la posición actual del jugador
	meteor.call_deferred("setup", spawn_pos, player.global_position)

func _on_increase_difficulty() -> void:
	# Aumentar la cantidad de meteoritos por oleada hasta el máximo
	if meteors_per_wave < max_meteors_per_wave:
		meteors_per_wave += 1
		print("¡Dificultad aumentada! Meteoritos por oleada: ", meteors_per_wave)
	
	# Reducir el tiempo de espera entre oleadas hasta el mínimo
	if spawn_timer.wait_time > min_interval:
		spawn_timer.wait_time = max(min_interval, spawn_timer.wait_time - 0.3)
		print("¡Oleadas más rápidas! Nuevo intervalo: ", spawn_timer.wait_time)

func get_random_spawn_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	var camera = get_viewport().get_camera_2d()
	var center = camera.global_position if camera else player.global_position
	
	var half_width = (viewport_size.x / 2.0) + margin
	var half_height = (viewport_size.y / 2.0) + margin
	
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match edge:
		0: # Arriba
			spawn_pos.x = randf_range(center.x - half_width, center.x + half_width)
			spawn_pos.y = center.y - half_height
		1: # Abajo
			spawn_pos.x = randf_range(center.x - half_width, center.x + half_width)
			spawn_pos.y = center.y + half_height
		2: # Izquierda
			spawn_pos.x = center.x - half_width
			spawn_pos.y = randf_range(center.y - half_height, center.y + half_height)
		3: # Derecha
			spawn_pos.x = center.x + half_width
			spawn_pos.y = randf_range(center.y - half_height, center.y + half_height)
			
	return spawn_pos
