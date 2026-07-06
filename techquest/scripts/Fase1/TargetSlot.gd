extends Panel
class_name TargetSlot

signal item_dropped(value: String)

var current_value: String = ""
@onready var label: Label = $Label

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is String

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	current_value = data
	label.text = current_value
	item_dropped.emit(current_value)
