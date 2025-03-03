extends Node2D

signal new_round
signal player_win
signal roll


@onready var prevTurn : int = 4
@onready var currentTurn : int = 0
@onready var players_left = 5

@onready var player = $Player
@onready var bot1 = $Bot1
@onready var bot2 = $Bot2
@onready var bot3 = $Bot3
@onready var bot4 = $Bot4

@onready var alive : Array[bool] = [true, true, true, true, true]
@onready var players : Array = [player, bot1, bot2, bot3, bot4]
@onready var callable : bool = false

@onready var dice_side = $OptionButton
@onready var num_dice = $SpinBox
@onready var confirm = $Confirm
@onready var dice_side_label = $DiceSide
@onready var num_dice_label = $Amount
@onready var invalid_label = $Invalid
@onready var call_button = $CallButton

@onready var assertFace = 0
@onready var assertNum = 0


	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dice_side.visible = false
	num_dice.visible = false
	confirm.visible = false
	dice_side_label.visible = false
	num_dice_label.visible = false
	invalid_label.visible = false
	call_button.visible = false
	
	

func _new_round(start : int) -> void:
	new_round.emit()
	if currentTurn == 0:
		dice_side.visible = true
		num_dice.visible = true
		confirm.visible = true
		dice_side_label.visible = true
		num_dice_label.visible = true
		invalid_label.visible = false
		call_button.visible = false
	else:
		dice_side.visible = false
		num_dice.visible = false
		confirm.visible = false
		dice_side_label.visible = false
		num_dice_label.visible = false
		invalid_label.visible = false
		call_button.visible = false
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_roll_button_pressed() -> void:
	roll.emit()
	_new_round(currentTurn)


func _combine_rolls() -> Array:
	var player = get_node_or_null("Player")
	var bot_1 = get_node_or_null("Bot1")
	var bot_2 = get_node_or_null("Bot2")
	var bot_3 = get_node_or_null("Bot3")
	var bot_4 = get_node_or_null("Bot4")
	
	var p_roll : Array = []
	var b_roll : Array = []

	if player:
		p_roll = player._get_last_roll()

	if bot1 and bot_1:
		b_roll += bot_1._get_last_roll()
	if bot2 and bot_2:
		b_roll += bot_2._get_last_roll()
	if bot3 and bot_3:
		b_roll += bot_3._get_last_roll()
	if bot4 and bot_4:
		b_roll += bot_4._get_last_roll()
	
	var combined_roll : Array = p_roll + b_roll
	return combined_roll
	
func _get_total() -> int:
	var temp : Array = _combine_rolls()
	return temp.size()
	
func _next_turn() -> int:
	callable = true
	prevTurn = currentTurn
	for i in range(players_left):
		currentTurn += 1
		@warning_ignore("integer_division")
		currentTurn /= 5
		if alive[currentTurn] == true:
			break
	
	if currentTurn == 0:
		if callable:
			call_button.visible = true
			# implement labels to display current call
		dice_side.visible = true
		num_dice.visible = true
		confirm.visible = true
		dice_side_label.visible = true
		num_dice_label.visible = true
		invalid_label.visible = false
	else:
		# implement labels to display current call
		call_button.visible = false
		dice_side.visible = false
		num_dice.visible = false
		confirm.visible = false
		dice_side_label.visible = false
		num_dice_label.visible = false
		invalid_label.visible = false
		
		#sleep here
		if callable:
			var chance = _calculate_chance(assertNum)
			if (chance < (1 - players[currentTurn].boldness_threshold)):
				_call()
			else:
				var assertions : Array = players[currentTurn]._make_assertion()
				assertFace = assertions[0]
				assertNum = assertFace[1]
		else:
			var assertions : Array = players[currentTurn]._make_assertion()
			assertFace = assertions[0]
			assertNum = assertFace[1]
	return currentTurn

func _call() -> bool:
	bot1._showRoll()
	bot2._showRoll()
	bot3._showRoll()
	bot4._showRoll()
	var rolls : Array = _combine_rolls()
	var out : bool
	var count = 0
	for i in rolls:
		if i == assertFace:
			count += 1
	if count >= assertNum:
		out = true
	else:
		out = false
	assertFace = 0
	assertNum = 0
	return out
	

# A helper to compute factorial
func factorial(n: int) -> float:
	var result := 1.0
	for i in range(1, n + 1):
		result *= i
	return result

# Compute "n choose k" = n! / (k! (n-k)!)
func combination(n: int, k: int) -> float:
	return factorial(n) / (factorial(k) * factorial(n - k))

# Probability that at least m of n dice show a chosen face (e.g., face "1")
func probability_at_least_m_dice(n: int, m: int) -> float:
	var total_probability := 0.0
	for k in range(m, n + 1):
		var c := combination(n, k)
		# (1/6)^k * (5/6)^(n-k)
		var p := pow(1.0 / 6.0, k) * pow(5.0 / 6.0, n - k)
		total_probability += c * p
	return total_probability

func _calculate_chance(num : int) -> float:
	var rolls : Array = _combine_rolls()
	var out : float = probability_at_least_m_dice(rolls.size(), num)
	return out

func _on_bot_1_dead() -> void:
	alive[1] = false

func _on_bot_2_dead() -> void:
	alive[2] = false

func _on_bot_3_dead() -> void:
	alive[3] = false

func _on_bot_4_dead() -> void:
	alive[4] = false

func _on_player_dead() -> void:
	pass
	
