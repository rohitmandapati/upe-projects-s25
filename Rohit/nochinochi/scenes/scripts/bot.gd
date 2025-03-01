extends Node2D

var botResult = []

#initalizes dice face
var bot_dice_faces = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Dice faces 1 to 6
	bot_dice_faces.append(load("res://textures/dice-1.png"))
	bot_dice_faces.append(load("res://textures/dice-2.png"))
	bot_dice_faces.append(load("res://textures/dice-3.png"))
	bot_dice_faces.append(load("res://textures/dice-4.png"))
	bot_dice_faces.append(load("res://textures/dice-5.png"))
	bot_dice_faces.append(load("res://textures/dice-6.png"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#rolls dice for bot.
func _botRoll(num_dice: int) -> Array:
	botResult.clear()
	for i in range(num_dice):
		botResult.append(randi() % 6 + 1)
	return botResult 


#shows bot dice.
func _showRoll(num_dice: int) -> void:
	#clears previous visuals.
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

	#creates visuals.
	for i in range(num_dice):
		var roll_result = randi() % 6 + 1
		botResult.append(roll_result)
		var sprite = Sprite2D.new()
		sprite.texture = bot_dice_faces[roll_result-1]
		sprite.position = Vector2(450 + (i * 100), 950)
		sprite.scale = Vector2(0.2, 0.2)
		add_child(sprite)


func _get_last_roll() -> Array:
	return botResult
