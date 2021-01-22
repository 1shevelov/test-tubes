extends MarginContainer

signal clicked(node_num)

var label_text: String = ""

var menu # pointer to Menu scene


func _ready():
	#print_debug("%s added" % get_name())
	$RTLabel.append_bbcode(label_text)
	# warning-ignore:return_value_discarded
	connect("clicked", menu, "_on_label_clicked")


func _on_RTLabel_gui_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		#print_debug("Clicked ", get_name())
		emit_signal("clicked", int(get_name().right(1)))


#func _draw():
#	draw_rect(Rect2(get_position(), get_size()), Color.white, false)


func _on_RTLabel_mouse_entered():
	$RTLabel.set_bbcode("")
	$RTLabel.append_bbcode("[color=yellow]%s[/color]" % label_text)


func _on_RTLabel_mouse_exited():
	$RTLabel.set_bbcode("")
	$RTLabel.append_bbcode(label_text)



