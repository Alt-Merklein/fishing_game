extends Node2D

@export var bite_offset: Vector2 = Vector2(0, 0)
@export var speed: float = 120.0
@export var amplitude: float = 200.0
@export var start_moves_right: bool = true
@export var random_speed_range := Vector2(0.95, 1.10)
@export var head_offset_right: Vector2 = Vector2(18, 0)
@export var head_offset_left: Vector2 = Vector2(-18, 0)
@export var draw_hitbox: bool = false

const ROD_GROUP := "fishing_rod"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $AnimatedSprite2D/Hitbox

var biting := false
var target_rod: Node2D = null
var rng := RandomNumberGenerator.new()
var dir := 1
var start_x := 0.0
var speed_scale := 1.0

func _ready():
	rng.randomize()
	dir = 1 if start_moves_right else -1
	speed_scale = rng.randf_range(random_speed_range.x, random_speed_range.y)
	start_x = global_position.x
	var phase_x := rng.randf_range(-amplitude, amplitude)
	global_position.x = start_x + phase_x
	_apply_facing()
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		_update_head_hitbox_offset()

func _process(delta: float):
	if biting and is_instance_valid(target_rod):
		global_position = target_rod.global_position + bite_offset
		rotation = +PI / 2
		return
	else:
		rotation = 0

	if amplitude > 0.0:
		global_position.x += speed * speed_scale * dir * delta
		var dx := global_position.x - start_x
		if absf(dx) >= amplitude:
			global_position.x = start_x + signf(dx) * amplitude
			dir *= -1
			_apply_facing()
			_update_head_hitbox_offset()

	queue_redraw()

func _apply_facing():
	if sprite:
		sprite.flip_h = (dir > 0)

func _update_head_hitbox_offset():
	if hitbox:
		hitbox.position = head_offset_right if (dir >= 0) else head_offset_left

func _on_hitbox_area_entered(area: Area2D):
	var maybe_rod := area.get_parent()
	if maybe_rod and maybe_rod.is_in_group(ROD_GROUP):
		if maybe_rod.has_method("on_hit_fish"):
			maybe_rod.on_hit_fish(self)

func bite(rod: Node2D):
	if biting: return
	target_rod = rod
	biting = true

func release():
	biting = false
	target_rod = null
	rotation = 0

func _draw():
	if draw_hitbox and hitbox:
		var pos := hitbox.position
		draw_circle(pos, 6, Color.RED)
