extends Node2D

signal new_round
signal player_win
signal roll
signal assertion_made


@onready var prevTurn : int = 4
@onready var currentTurn : int = -1
@onready var players_left = 5

# Player and Bot references
@onready var player = $Player
@onready var bot1 = $Bot1
@onready var bot2 = $Bot2
@onready var bot3 = $Bot3
@onready var bot4 = $Bot4

@onready var alive : Array[bool] = [true, true, true, true, true]
@onready var players : Array = [player, bot1, bot2, bot3, bot4]
@onready var callable : bool = false

# Control logic, buttons, labels references
@onready var dice_side = $OptionButton
@onready var num_dice = $SpinBox
@onready var confirm = $Confirm
@onready var dice_side_label = $DiceSide
@onready var num_dice_label = $Amount
@onready var invalid_label = $Invalid
@onready var call_button = $CallButton
@onready var roll_button = $RollButton
@onready var info_box = $InfoBox
# Turn display references
@onready var player_turn = $PlayerTurn
@onready var bot1_turn = $Bot1Turn
@onready var bot2_turn = $Bot2Turn
@onready var bot3_turn = $Bot3Turn
@onready var bot4_turn = $Bot4Turn

@onready var assertFace : int = 0
@onready var assertNum : int = 0

@onready var assertFaceLabel = $CurrentDiceFace
@onready var assertNumLabel = $CurrentDIceNum

	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#dice_side.visible = false
	#num_dice.visible = false
	#confirm.visible = false
	#dice_side_label.visible = false
	#num_dice_label.visible = false
	#invalid_label.visible = false
	#call_button.visible = false
	callable = false
	_new_round()
	
	


func _new_round() -> void:
	assertFaceLabel.clear()
	assertNumLabel.clear()
	player_turn.visible = false
	bot1_turn.visible = false
	bot2_turn.visible = false
	bot3_turn.visible = false
	bot4_turn.visible = false
	dice_side.visible = false
	num_dice.visible = false
	confirm.visible = false
	dice_side_label.visible = false
	num_dice_label.visible = false
	invalid_label.visible = false
	call_button.visible = false
	roll_button.visible = true
	info_box.clear()
	callable = false
	#assertFace = 1
	#assertNum = 0
	await roll
	roll_button.visible = false
	
	print(bot1.boldness_threshold)
	print(bot2.boldness_threshold)
	print(bot3.boldness_threshold)
	print(bot4.boldness_threshold)
	#await get_tree().create_timer(2).timeout 
	_next_turn()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_roll_button_pressed() -> void:
	roll.emit()
	
	#_new_round(currentTurn)


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
	print("--------")
	#bot1._showRoll()
	#bot2._showRoll()
	#bot3._showRoll()
	#bot4._showRoll()
	print("Face: " + str(assertFace) + "\nNum: " + str(assertNum))
	player_turn.visible = false
	bot1_turn.visible = false
	bot2_turn.visible = false
	bot3_turn.visible = false
	bot4_turn.visible = false
	
	prevTurn = currentTurn
	for i in range(players_left):
		currentTurn += 1
		@warning_ignore("integer_division")
		currentTurn %= 5
		if alive[currentTurn] == true:
			break
	print(currentTurn)
	if currentTurn == 0:
		player_turn.visible = true
		if callable:
			call_button.visible = true
		else:
			call_button.visible = false
		dice_side.visible = true
		num_dice.visible = true
		confirm.visible = true
		dice_side_label.visible = true
		num_dice_label.visible = true
		invalid_label.visible = false
		await decision
		if player_call:
			bot1._showRoll()
			bot2._showRoll()
			bot3._showRoll()
			bot4._showRoll()
			var text = "You called Bot " + str(prevTurn)
			info_box.clear()
			info_box.append_text(text)
			var out = _call()
			await get_tree().create_timer(2).timeout
			if out:
				player.dice -= 1
				text = "Wrong! You lose a die"
				info_box.clear()
				info_box.append_text(text)
			elif !out:
				players[prevTurn].dice -= 1
				text = "Correct! Bot " + str(prevTurn) + " loses a die"
				info_box.clear()
				info_box.append_text(text)
			await get_tree().create_timer(2).timeout
			_new_round()
			return currentTurn
		elif player_assert:
			assertNum = num_dice.value
			assertFace = dice_side.get_selected_id() + 1
			var text = "You asserted " + str(assertNum) + " dice of face " + str(assertFace)
			info_box.clear()
			info_box.append_text(text)
			assertion_made.emit()
	else:
		# implement labels to display current asserts
		call_button.visible = false
		dice_side.visible = false
		num_dice.visible = false
		confirm.visible = false
		dice_side_label.visible = false
		num_dice_label.visible = false
		invalid_label.visible = false 
		if currentTurn == 1:
			print("Bot 1 Turn")
			bot1_turn.visible = true
			await get_tree().create_timer(2).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot1.boldness_threshold)):
					var call_result = _call()
					if call_result:
						bot1.dice -= 1
					else:
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 1 asserted " + str(assertNum) + " dice of face " + str(assertFace)
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 1 asserted " + str(assertNum) + " dice of face " + str(assertFace)
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
		if currentTurn == 2:
			print("Bot 2 Turn")
			bot2_turn.visible = true
			await get_tree().create_timer(2).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot2.boldness_threshold)):
					var call_result = _call()
					if call_result:
						bot2.dice -= 1
					else:
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 2 asserted " + str(assertNum) + " dice of face " + str(assertFace)
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 2 asserted " + str(assertNum) + " dice of face " + str(assertFace)
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
		if currentTurn == 3:
			print("Bot 3 Turn")
			bot3_turn.visible = true
			await get_tree().create_timer(2).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot3.boldness_threshold)):
					var call_result = _call()
					if call_result:
						bot3.dice -= 1
					else:
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 3 asserted " + str(assertNum) + " dice of face " + str(assertFace)
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 3 asserted " + str(assertNum) + " dice of face " + str(assertFace)
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
		if currentTurn == 4:
			print("Bot 4 Turn")
			bot4_turn.visible = true
			await get_tree().create_timer(2).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot4.boldness_threshold)):
					var call_result = _call()
					if call_result:
						bot4.dice -= 1
					else:
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 4 asserted " + str(assertNum) + " dice of face " + str(assertFace)
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 4 asserted " + str(assertNum) + " dice of face " + str(assertFace)
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
	callable = true
	_next_turn()
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
	assertFace = 1
	assertNum = 1
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
	
func _make_assertion() -> Array: # To be implemented
	var asserts = [0,0]
	var t = randf()
	if t <=0.4: #increase faces
		var new_face = ceil(randf_range(0.2,1.2))
		if assertFace + new_face >= 6:
			asserts[0] = 6
			asserts[1] = assertNum + ceil(randf_range(0.2,1.2))
		else:
			asserts[0] = assertFace + new_face
			asserts[1] = assertNum
	elif t <= 0.8: #increases num
		asserts[0] = assertFace
		asserts[1] = assertNum + ceil(randf_range(0.2,1.2))
	else: #increases both
		var new_face = ceil(randf_range(0.2,1.2))
		if assertFace + new_face >= 6:
			asserts[0] = 6
			asserts[1] = assertNum + ceil(randf_range(0.2,1.2))
		else:
			asserts[0] = assertFace + new_face
			asserts[1] = assertNum + ceil(randf_range(0.2,1.2))
	return asserts

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
	

signal decision
var player_call : bool
var player_assert : bool

func _on_call_button_pressed() -> void:
	player_call = true
	player_assert = false
	decision.emit()
	
func _is_valid_assertion(face : int, num : int) -> bool:
	if face > 6:
		return false
	if face == 1 and num == 1 and assertFace == 1 and assertNum == 1:
		return true
	if face < assertFace or num < assertNum:
		return false
	if face == assertFace and num == assertNum:
		return false
	
	return true

func _on_confirm_pressed() -> void:
	if dice_side.get_selected_id() == -1:
		invalid_label.visible = true
	elif !_is_valid_assertion(dice_side.get_selected_id() + 1, num_dice.value):
		invalid_label.visible = true
	else:
		player_call = false
		player_assert = true
		decision.emit()


func _on_assertion_made() -> void:
	assertFaceLabel.clear()
	assertFaceLabel.append_text("[center][b]" + str(assertFace) + "[/b]")
	assertNumLabel.clear()
	assertNumLabel.append_text("[center][b]" + str(assertNum) + "[/b]")
