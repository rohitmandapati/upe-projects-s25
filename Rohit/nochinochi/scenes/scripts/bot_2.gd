extends Node2D

signal bot_2_dead # Differs

@onready var difficulty = 1
@onready var level = $".."

#current roll
var botResult : Array = []

#total dice left
var dice : int

#initalizes dice face
var bot_dice_faces = []


var boldness_threshold : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Dice faces 1 to 6
	bot_dice_faces.append(load("res://textures/dice-1.png"))
	bot_dice_faces.append(load("res://textures/dice-2.png"))
	bot_dice_faces.append(load("res://textures/dice-3.png"))
	bot_dice_faces.append(load("res://textures/dice-4.png"))
	bot_dice_faces.append(load("res://textures/dice-5.png"))
	bot_dice_faces.append(load("res://textures/dice-6.png"))
	dice = 6
	var init : float = randf_range(0.0, 1.0)
	boldness_threshold = -1.0 / (1.0 + pow(2.72,-5*(init-0.8))) + 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dice <= 0:
		bot_2_dead.emit() #Differs from bot to bot



#rolls dice for bot.
func _botRoll(num_dice: int) -> Array:
	botResult.clear()
	for i in range(num_dice):
		botResult.append(randi() % 6 + 1)
	return botResult 

func _clearRoll() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

#shows bot dice.
func _showRoll() -> void:
	#clears previous visuals.
	_clearRoll()

	#creates visuals.
	for i in range(dice):
		var sprite = Sprite2D.new()
		sprite.texture = bot_dice_faces[botResult[i]-1]
		sprite.position = Vector2(1130 + (i * 100), 100)
		sprite.scale = Vector2(0.2, 0.2)
		add_child(sprite)


func _get_last_roll() -> Array:
	return botResult


func _on_level_roll() -> void:
	_clearRoll()
	if level.alive[2]: #Differs from bot to bot
		_botRoll(dice)
		_showRoll()
