extends Node2D

@export var animation_name: String = "swim"
@export var bite_offset: Vector2 = Vector2(0, 0)

# Optional per-fish variation
@export var desync_phase: bool = true
@export var random_speed_range := Vector2(0.95, 1.10) # 1.0 = normal speed
@export var random_facing: bool = true                # random flip_h at start

const ROD_GROUP := "fishing_rod"

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Sprite2D/Hitbox

var biting := false
var target_rod: Node2D = null
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)

	if anim and anim.has_animation(animation_name):
		# Play first, then seek to a random phase so it's visible immediately
		anim.play(animation_name)

		if desync_phase:
			var a := anim.get_animation(animation_name)
			if a:
				var t := rng.randf_range(0.0, a.length)
				anim.seek(t, true)  # 'true' forces immediate update

		# Slight per-fish speed variance (optional)
		if random_speed_range.x != 1.0 or random_speed_range.y != 1.0:
			anim.speed_scale = rng.randf_range(random_speed_range.x, random_speed_range.y)

	# Random initial facing (optional, purely visual; doesn't change swim path)
	if random_facing and sprite:
		sprite.flip_h = (rng.randi() & 1) == 0

func _process(_delta: float):
	if biting and is_instance_valid(target_rod):
		global_position = target_rod.global_position + bite_offset
		rotation = -PI / 2
	elif not biting:
		rotation = 0

func _on_hitbox_area_entered(area: Area2D):
	var maybe_rod := area.get_parent()
	if maybe_rod and maybe_rod.is_in_group(ROD_GROUP):
		if maybe_rod.has_method("on_hit_fish"):
			maybe_rod.on_hit_fish(self)

func bite(rod: Node2D):
	if biting: return
	target_rod = rod
	biting = true
	if anim: anim.stop()

func release():
	biting = false
	target_rod = null
	rotation = 0
	if anim and anim.has_animation(animation_name):
		anim.play(animation_name)
