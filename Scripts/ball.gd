extends CharacterBody2D

const START_SPEED: float = 500.0
@onready var speed: float = START_SPEED 
const SPEED_INCREASE: float = 1.1

@onready var collision1_sound = $Collision2_sfx
@onready var viewport: Vector2 = get_viewport_rect().size
var rng = RandomNumberGenerator.new()
var direction: Vector2  # Store direction separately

# Trail data
@onready var trail_sprite = $Ball_spr
var trail_container: Array = []
const TRAIL_DOWNSIZE_RATE: float = 0.2
const TRAIL_ALPHA_REDUCE_RATE: float = 0.1
const MAX_TRAIL_SIZE: int = 40

var trail_timer: float = 0               # Starting point for adding a new trail sprite
const TRAIL_FRAME_INCREASE: float = 1  # How fast the timer increases  (per frame add this many to the trail_timer)
const TRAIL_FRAME_LIMIT: int = 1         # The upper limit to a trail sprite being added (once trail_timer reaches this a new trail is added)



func _ready() -> void:
	# Start in center
	position = Vector2(viewport.x / 2, viewport.y / 2)
	direction = get_random_direction()

func get_random_direction() -> Vector2:
	# Define some good angles (in degrees)
	var angles = [30, 45, 60, -30, -45, -60]
	var angle = deg_to_rad(angles[rng.randi() % angles.size()])
	
	# Choose left or right
	var x_dir = 1 if rng.randf() > 0.5 else -1
	
	return Vector2(x_dir * cos(angle), sin(angle)).normalized()

func reset_ball() -> void:
	speed = START_SPEED
	position = viewport / 2
	direction = get_random_direction()
	for trail in trail_container:
		trail.self_modulate.a = 0
	trail_container.clear()

func _physics_process(delta: float) -> void:
	# Move the ball
	var collision = move_and_collide(direction * speed * delta)
	
	# Increase speed and bounce
	if collision:
		direction = direction.bounce(collision.get_normal())
		speed *= SPEED_INCREASE
		collision1_sound.play()
	
	
	# Bounce off top/bottom edges
	if position.y <= 0 or position.y >= viewport.y:
		direction.y *= -1
		position.y = clamp(position.y, 0, viewport.y)
		collision1_sound.play()
	
	# Reset if ball goes off the left/right side
	if position.x <= 0 or position.x >= viewport.x:
		reset_ball()
		
	trail_timer += TRAIL_FRAME_INCREASE
	if trail_container.size() < MAX_TRAIL_SIZE and trail_timer >= TRAIL_FRAME_LIMIT:
		create_trail()
		trail_timer = 0
	update_trail()

func update_trail():
	for i in range(trail_container.size() - 1, -1, -1):
		var trail = trail_container[i]
		trail.self_modulate.a -= TRAIL_ALPHA_REDUCE_RATE
		trail.scale -= Vector2(TRAIL_DOWNSIZE_RATE, TRAIL_DOWNSIZE_RATE)

		if trail.self_modulate.a <= 0 or trail.scale.x + trail.scale.y <= 0:
			trail.queue_free() # remove from scene
			trail_container.remove_at(i)



func create_trail(): 
	var trail = Sprite2D.new()
	trail.texture = trail_sprite.texture
	trail.scale = trail_sprite.scale
	trail.modulate = trail_sprite.modulate
	trail.position = position

	trail_container.append(trail)
	get_parent().add_child(trail)
