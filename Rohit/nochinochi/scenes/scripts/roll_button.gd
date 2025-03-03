extends Button

@onready var roll_button = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_level_new_round() -> void:
	roll_button.visible = true

func _on_pressed() -> void:
	roll_button.visible = false
