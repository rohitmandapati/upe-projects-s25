extends Button

var difficulty: int = -1

signal please_select_diff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	if difficulty == 0:
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	elif difficulty == 1:
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	elif difficulty == 2:
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	else:
		please_select_diff.emit()

func _on_difficulty_item_selected(index: int) -> void:
	difficulty = index 
