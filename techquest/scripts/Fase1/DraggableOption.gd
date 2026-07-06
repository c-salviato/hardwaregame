extends Label
class_name DraggableOption

@export var value: String = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := Label.new()
	preview.text = text
	preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_theme_font_override("font", get_theme_font("font"))
	preview.add_theme_font_size_override("font_size", get_theme_font_size("font_size"))
	
	set_drag_preview(preview)
	return value
