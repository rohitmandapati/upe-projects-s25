extends Node2D


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
	
	player._roll(6)
	bot._botRoll(6)
	roll_button.hide()
