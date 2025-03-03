extends Node2D


var p_dice = 6
var b_dice = 6


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_roll_button_pressed() -> void:
	var player = get_node_or_null("Player")
	var bot = get_node_or_null("Bot")
	var roll_button = get_node_or_null("RollButton")
	
	player._roll(p_dice)
	bot._botRoll(b_dice)
	roll_button.hide()


func _combine_rolls():
	var player = get_node_or_null("Player")
	var bot = get_node_or_null("Bot")
	var p_roll = []
	var b_roll = []

	if player:
		p_roll = player._get_last_roll()

	if bot:
		b_roll = bot._get_last_roll()
	
	var combined_roll = p_roll + b_roll
	return combined_roll
