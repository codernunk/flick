extends Panel


func _ready() -> void:
	SavedData.beans_changed.connect(_update_bean_count)
	for c in Constants.Colors.values():
		_update_bean_count(c)

func _update_bean_count(color: Constants.Colors):
	var bean_count_node = $BeanCounts.get_node(Constants.Colors.keys()[color].to_lower())
	bean_count_node.get_node("Count").text = "x%s" % SavedData.beans[color]
