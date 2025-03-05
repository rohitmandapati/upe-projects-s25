extends Node2D

signal new_round
signal player_win
signal roll
signal assertion_made


@onready var prevTurn : int = 4
@onready var currentTurn : int = -1
@onready var players_left = 5
@onready var total_dice = 30

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
@onready var game_info = $GameInfo

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
	if Global.difficulty != 0:
		_game_state()
	_new_round()
	

func _process(delta : float) -> void:
	if alive[0] and !alive[1] and !alive[2] and !alive[3] and !alive[4]:
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/win.tscn")
	if !alive[0]:
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/lose.tscn")


func _new_round() -> void:
	if Global.difficulty == 0:
		_game_state()
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
	if Global.difficulty != 0:
		game_info.clear()

	print(bot1.boldness_threshold)
	print(bot2.boldness_threshold)
	print(bot3.boldness_threshold)
	print(bot4.boldness_threshold)
	#await get_tree().create_timer(2).timeout 
	_next_turn()


func _on_roll_button_pressed() -> void:
	roll.emit()
	
	#_new_round(currentTurn)


func _combine_rolls() -> Array:
	var p_roll : Array = []
	var b_roll : Array = []

	if player:
		p_roll = player._get_last_roll()

	for i in range(1, 5):
		if alive[i]:
			b_roll += get_node("Bot" + str(i))._get_last_roll()

	return p_roll + b_roll

func _game_state():
	game_info.clear()
	players_left = 1
	total_dice = player._dice()
	for i in range(1, 5):
		if alive[i]:
			players_left += 1
			total_dice += get_node("Bot" + str(i))._dice()
	game_info.append_text("Players: %d | Total Dice: %d" % [players_left, total_dice])
	
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
			var text = "You called Bot " + str(prevTurn) + " a liar!"
			info_box.clear()
			info_box.append_text(text)
			var out = _call()
			call_button.visible = false
			dice_side.visible = false
			num_dice.visible = false
			confirm.visible = false
			dice_side_label.visible = false
			num_dice_label.visible = false
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
			var text = "You bid " + str(assertNum) + " dice of face " + str(assertFace) + "."
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
			await get_tree().create_timer(2).timeout
			bot1_turn.visible = true
			await get_tree().create_timer(1).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot1.boldness_threshold)):
					var call_result = _call()
					var text = "Bot 1 thinks "
					if prevTurn == 0:
						text += "you are a liar!"
					else:
						text += "Bot " + str(prevTurn) + " is a liar!"
					info_box.clear()
					info_box.append_text(text)
					await get_tree().create_timer(2).timeout
					if call_result:
						bot1.dice -= 1
						text = "Wrong! Bot 1 loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
					else:
						players[prevTurn].dice -= 1
						text = "Correct! "
						if prevTurn == 0:
							text += "You lose a die"
						else:
							text += "Bot " + str(prevTurn) + " loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 1 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 1 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
		if currentTurn == 2:
			print("Bot 2 Turn")
			await get_tree().create_timer(2).timeout
			bot2_turn.visible = true
			await get_tree().create_timer(1).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot2.boldness_threshold)):
					var text = "Bot 2 thinks "
					if prevTurn == 0:
						text += "you are a liar!"
					else:
							text += "Bot " + str(prevTurn) + " is a liar!"
					info_box.clear()
					info_box.append_text(text)
					await get_tree().create_timer(2).timeout
					var call_result = _call()
					if call_result:
						text = "Wrong! Bot 2 loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
						bot2.dice -= 1
					else:
						text = "Correct! "
						if prevTurn == 0:
							text += "You lose a die"
						else:
							text += "Bot " + str(prevTurn) + " loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 2 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 2 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
		if currentTurn == 3:
			print("Bot 3 Turn")
			await get_tree().create_timer(2).timeout
			bot3_turn.visible = true
			await get_tree().create_timer(1).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot3.boldness_threshold)):
					var text = "Bot 3 thinks "
					if prevTurn == 0:
						text += "you are a liar!"
					else:
							text += "Bot " + str(prevTurn) + " is a liar!"
					info_box.clear()
					info_box.append_text(text)
					await get_tree().create_timer(2).timeout
					var call_result = _call()
					if call_result:
						text = "Wrong! Bot 3 loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
						bot3.dice -= 1
					else:
						text = "Correct! "
						if prevTurn == 0:
							text += "You lose a die"
						else:
							text += "Bot " + str(prevTurn) + " loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 3 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 3 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
				info_box.clear()
				info_box.append_text(text)
				assertion_made.emit()
		if currentTurn == 4:
			print("Bot 4 Turn")
			await get_tree().create_timer(2).timeout
			bot4_turn.visible = true
			await get_tree().create_timer(1).timeout
			if callable:
				var chance = _calculate_chance(assertNum)
				if (chance < (1 - bot4.boldness_threshold)):
					var text = "Bot 4 thinks "
					if prevTurn == 0:
						text.append("you are a liar!")
					else:
						text += "Bot " + str(prevTurn) + " is a liar!"
					info_box.clear()
					info_box.append_text(text)
					await get_tree().create_timer(2).timeout
					var call_result = _call()
					if call_result:
						text = "Wrong! Bot 4 loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
						bot4.dice -= 1
					else:
						text = "Correct! "
						if prevTurn == 0:
							text += "You lose a die"
						else:
							text += "Bot " + str(prevTurn) + " loses a die"
						info_box.clear()
						info_box.append_text(text)
						await get_tree().create_timer(2).timeout
						players[prevTurn].dice -= 1
					_new_round()
					return currentTurn
				else:
					var assertions : Array = _make_assertion()
					assertFace = assertions[0]
					assertNum = assertions[1]
					var text = "Bot 4 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
					info_box.clear()
					info_box.append_text(text)
					assertion_made.emit()
			else:
				var assertions : Array = _make_assertion()
				assertFace = assertions[0]
				assertNum = assertions[1]
				var text = "Bot 4 bids " + str(assertNum) + " dice with face " + str(assertFace) + "."
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
	print(rolls)
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
	var asserts = [1, 1]
	var t = randf()
	
	if assertFace < 1:
		assertFace = 1
	if assertNum < 1:
		assertNum = 1

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
	players_left -= 1
	info_box.clear()
	info_box.append_text("Bot 1 has lost")
func _on_bot_2_dead() -> void:
	alive[2] = false
	players_left -= 1
	info_box.clear()
	info_box.append_text("Bot 2 has lost")
func _on_bot_3_dead() -> void:
	alive[3] = false
	players_left -= 1
	info_box.clear()
	info_box.append_text("Bot 3 has lost")
func _on_bot_4_dead() -> void:
	players_left -= 1
	alive[4] = false
	info_box.clear()
	info_box.append_text("Bot 4 has lost")
func _on_player_dead() -> void:
	alive[0] = false
	players_left -= 1
	info_box.clear()
	info_box.append_text("You have lost")

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
