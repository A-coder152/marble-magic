# Marble.gd
extends Control

@onready var marble_button = $MarbleButton
@onready var value_label = $MarbleButton/ValueLabel

var marble_index: int = -1 # To identify which marble this is (0-3)
var marble_value: int = 0 # The actual attack value of this marble

# Signal to emit when this marble is clicked
signal marble_clicked(index: int)

func _ready():
	# Connect the button's pressed signal to a local function
	marble_button.pressed.connect(_on_MarbleButton_pressed)
	# Initial state: value hidden
	value_label.text = "?"
	marble_button.text = "" # Clear button text as label handles it

# Sets the data for this marble instance
func set_marble_data(index: int, value: int):
	marble_index = index
	marble_value = value
	# print("Marble %d set with value %d" % [index, value])

# Updates the visual state of the marble (selected/deselected)
func set_selected(is_selected: bool):
	if is_selected:
		# Example visual feedback: change button style or add a border
		marble_button.add_theme_stylebox_override("normal", _get_selected_style())
		marble_button.add_theme_stylebox_override("hover", _get_selected_style())
		marble_button.add_theme_stylebox_override("pressed", _get_selected_style())
		# You could also add a child node like a TextureRect for a selection ring
	else:
		# Reset to normal style
		marble_button.add_theme_stylebox_override("normal", _get_normal_style())
		marble_button.add_theme_stylebox_override("hover", _get_hover_style())
		marble_button.add_theme_stylebox_override("pressed", _get_pressed_style())

# Reveals the marble's actual value
func reveal_value(reveal: bool):
	if reveal:
		value_label.text = str(marble_value)
		# Optional: change marble color when revealed
		#marble_button.add_theme_stylebox_override("normal", _get_revealed_style())
	else:
		value_label.text = "?"
		marble_button.add_theme_stylebox_override("normal", _get_normal_style())


# Callback for when the marble button is pressed
func _on_MarbleButton_pressed():
	marble_clicked.emit(marble_index) # Emit signal with its index

# --- Helper functions for dynamic styles (you can customize these) ---
func _get_normal_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("c3c3c3")) # Light gray
	style.set_corner_radius_all(50)
	style.set_border_width_all(2)
	style.set_border_color(Color("a0a0a0"))
	style.set_shadow_size(3)
	style.set_shadow_offset(Vector2(2,2))
	return style

func _get_hover_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("e0e0e0")) # Slightly lighter gray
	style.set_corner_radius_all(50)
	style.set_border_width_all(2)
	style.set_border_color(Color("a0a0a0"))
	style.set_shadow_size(4)
	style.set_shadow_offset(Vector2(3,3))
	return style

func _get_pressed_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("c0c0c0")) # Darker gray
	style.set_corner_radius_all(50)
	style.set_border_width_all(2)
	style.set_border_color(Color("808080"))
	style.set_shadow_size(1)
	style.set_shadow_offset(Vector2(1,1))
	return style

func _get_selected_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("6a5acd")) # Slate Blue for selected
	style.set_corner_radius_all(50)
	style.set_border_width_all(4)
	style.set_border_color(Color("483d8b")) # Darker blue
	style.set_shadow_size(5)
	style.set_shadow_offset(Vector2(3,3))
	return style

#func _get_revealed_style():
	#var style = StyleBoxFlat.new()
	#style.set_bg_color(Color("8a2be2")) # Blue Violet for revealed
	#style.set_corner_radius_all(50)
	#style.set_border_width_all(2)
	#style.set_border_color(Color("4b0082")) # Indigo
	#style.set_shadow_size(3)
	#style.set_shadow_offset(Vector2(2,2))
	#return style
