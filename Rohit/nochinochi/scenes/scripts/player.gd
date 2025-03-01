extends Node2D

var result = []

#initalizes dice face
var dice_faces = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Dice faces 1 to 6
	dice_faces.append(load("res://textures/dice-1.png"))
	dice_faces.append(load("res://textures/dice-2.png"))
	dice_faces.append(load("res://textures/dice-3.png"))
	dice_faces.append(load("res://textures/dice-4.png"))
	dice_faces.append(load("res://textures/dice-5.png"))
	dice_faces.append(load("res://textures/dice-6.png"))
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called at the start of the round. Rolls a number of dice and returns the result.
func _roll(num_dice: int) -> void:
	#clears previous visuals
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

	#rolls dice and creates visuals
	for i in range(num_dice):
		var roll_result = randi() % 6 + 1
		result.append(roll_result)
		var sprite = Sprite2D.new()
		sprite.texture = dice_faces[roll_result-1]
		sprite.position = Vector2(725 + (i * 100), 950)
		sprite.scale = Vector2(0.2, 0.2)
		add_child(sprite)
