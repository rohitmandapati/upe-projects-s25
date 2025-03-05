extends Button

var difficulty: int = -1


signal difficulty_easy
signal difficulty_medium
signal difficulty_hard

signal please_select_diff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	if difficulty == 0:
		difficulty_easy.emit()
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	elif difficulty == 1:
		difficulty_medium.emit()
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	elif difficulty == 2:
		difficulty_hard.emit()
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	else:
		please_select_diff.emit()

func _on_difficulty_item_selected(index: int) -> void:
	difficulty = index 
	Global.difficulty = index
