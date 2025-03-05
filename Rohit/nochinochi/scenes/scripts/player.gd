extends Node2D

var result = []

var dice : int

#initalizes dice face
var dice_faces = []

signal player_dead



# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Dice faces 1 to 6
	dice_faces.append(load("res://textures/dice-1.png"))
	dice_faces.append(load("res://textures/dice-2.png"))
	dice_faces.append(load("res://textures/dice-3.png"))
	dice_faces.append(load("res://textures/dice-4.png"))
	dice_faces.append(load("res://textures/dice-5.png"))
	dice_faces.append(load("res://textures/dice-6.png"))
	
	dice = 2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dice <= 0:
		player_dead.emit()
	
func _on_level_roll() -> void:
	_roll(dice)

func _clear() -> void:
	#clears previous visuals
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

# Called at the start of the round. Rolls a number of dice and returns the result.
func _roll(num_dice: int) -> void:
	_clear()
	result = []
	#rolls dice and creates visuals
	for i in range(num_dice):
		var roll_result = randi() % 6 + 1
		result.append(roll_result)
		var sprite = Sprite2D.new()
		sprite.texture = dice_faces[roll_result-1]
		sprite.position = Vector2(710 + (i * 100), 950)
		sprite.scale = Vector2(0.2, 0.2)
		add_child(sprite)


func _get_last_roll() -> Array:
	return result
	
	
func _dice() -> int:
	return dice
