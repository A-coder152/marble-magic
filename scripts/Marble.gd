# Marble.gd
extends Control

@onready var marble_button = $MarbleButton
@onready var value_label = $MarbleButton/ValueLabel

var marble_index: int = -1
var marble_value: int = 0
var marble_res: Marble

signal marble_clicked(index: int)

func _ready():
	marble_button.pressed.connect(_on_MarbleButton_pressed)
	value_label.text = "?"

func set_marble_data(index: int, res: Marble = null):
	marble_index = index
	marble_res = res
	if marble_res: marble_value = marble_res.damage

func set_selected(is_selected: bool):
	if is_selected:
		marble_button.add_theme_stylebox_override("normal", _get_selected_style())
		marble_button.add_theme_stylebox_override("hover", _get_selected_style())
		marble_button.add_theme_stylebox_override("pressed", _get_selected_style())
	else:
		marble_button.add_theme_stylebox_override("normal", _get_normal_style())
		marble_button.add_theme_stylebox_override("hover", _get_hover_style())
		marble_button.add_theme_stylebox_override("pressed", _get_pressed_style())

func reveal_value(reveal: bool):
	if reveal:
		value_label.text = str(marble_value)
		marble_button.visible = false
		$TextureRect.texture = marble_res.texture
	else:
		$TextureRect.texture = null
		marble_button.visible = true
		value_label.text = "?"
		marble_button.add_theme_stylebox_override("normal", _get_normal_style())


func _on_MarbleButton_pressed():
	marble_clicked.emit(marble_index)

func _get_normal_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("c3c3c3"))
	style.set_corner_radius_all(50)
	style.set_border_width_all(2)
	style.set_border_color(Color("a0a0a0"))
	style.set_shadow_size(3)
	style.set_shadow_offset(Vector2(2,2))
	return style

func _get_hover_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("e0e0e0"))
	style.set_corner_radius_all(50)
	style.set_border_width_all(2)
	style.set_border_color(Color("a0a0a0"))
	style.set_shadow_size(4)
	style.set_shadow_offset(Vector2(3,3))
	return style

func _get_pressed_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("c0c0c0"))
	style.set_corner_radius_all(50)
	style.set_border_width_all(2)
	style.set_border_color(Color("808080"))
	style.set_shadow_size(1)
	style.set_shadow_offset(Vector2(1,1))
	return style

func _get_selected_style():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color("6a5acd")) 
	style.set_corner_radius_all(50)
	style.set_border_width_all(4)
	style.set_border_color(Color("483d8b"))
	style.set_shadow_size(5)
	style.set_shadow_offset(Vector2(3,3))
	return style

#func _get_revealed_style():
	#var style = StyleBoxFlat.new()
	#style.set_bg_color(Color("8a2be2"))
	#style.set_corner_radius_all(50)
	#style.set_border_width_all(2)
	#style.set_border_color(Color("4b0082"))
	#style.set_shadow_size(3)
	#style.set_shadow_offset(Vector2(2,2))
	#return style
