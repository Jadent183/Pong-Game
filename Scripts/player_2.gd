extends CharacterBody2D

const SPEED: float = 400.0
@onready var viewport: Vector2 = get_viewport_rect().size


func _ready() -> void:
	# Start in the middle
	self.position.y = viewport.y / 2


func _process(delta):
	move_and_slide()
	self.position.x = viewport.x - 50
	velocity = Vector2.ZERO # The player's movement vector.
	
	if Input.is_action_pressed(&"move_down_p2"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up_p2"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, viewport)
