extends Node2D

@export var fish_scene: PackedScene          # assign your Fish.tscn
@export var count: int = 20                  # how many fish to spawn instantly
@export var area_size := Vector2(1000, 300)  # spawn area (W x H), centered on this node

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if fish_scene == null:
		push_error("Assign 'fish_scene' in the inspector.")
		return

	for i in range(count):
		var f := fish_scene.instantiate() as Node2D
		add_child(f)

		# random position within the rectangle centered on this spawner
		var x = global_position.x - area_size.x * 0.5 + rng.randf() * area_size.x
		var y = global_position.y - area_size.y * 0.5 + rng.randf() * area_size.y
		f.global_position = Vector2(x, y)
