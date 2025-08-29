# RedBall.gd (Godot 4)
extends Node2D

@export var radius: float = 20.0
@export var speed: float = 100.0
@export var bottom_y: float = 420.0
@export var spawn_offset_y: float = 32.0
@export var player_path: NodePath

var going_down := false
var returning_up := false
var spawn_position: Vector2
var player: Node2D
var caught_fish: Node = null

@onready var hitbox: Area2D = $Hitbox

func _ready():
	add_to_group("fishing_rod")
	hide()

	# Resolve player
	if player_path != NodePath():
		player = get_node_or_null(player_path) as Node2D
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D

	# Make sure the hitbox radius matches the drawn circle (optional convenience)
	var shape := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape and shape.shape is CircleShape2D:
		(shape.shape as CircleShape2D).radius = radius

func _process(delta: float):
	if Input.is_action_just_pressed("fish") and not going_down and not returning_up:
		if player == null:
			push_warning("RedBall: Player not found.")
			return
		spawn_position = player.global_position + Vector2(0, spawn_offset_y)
		global_position = spawn_position
		show()
		going_down = true

	if going_down:
		global_position.y += speed * delta
		if global_position.y >= bottom_y:
			going_down = false
			returning_up = true

	elif returning_up:
		global_position.y -= speed * delta
		if global_position.y <= spawn_position.y:
			returning_up = false
			hide()
			if caught_fish and caught_fish.is_inside_tree():
				if caught_fish.has_method("release"):
					caught_fish.release()
				caught_fish = null

	queue_redraw()

func _draw():
	if visible:
		draw_circle(Vector2.ZERO, radius, Color.RED)

# Called by a Fish when it collides with the ball
func on_hit_fish(fish: Node):
	if not visible:
		return
	going_down = false
	returning_up = true
	caught_fish = fish
	if fish and fish.has_method("bite"):
		fish.bite(self)
