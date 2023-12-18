@tool
extends StaticBody2D

func _ready():
	if not Engine.is_editor_hint():
		var coll = CollisionPolygon2D.new()
		coll.polygon = $Polygon2D.polygon
		add_child(coll)
#		$Outline.points = $Polygon2D.polygon
#		$Outline.visible = true

func _process(delta):
	if Engine.is_editor_hint():
		var points = PackedVector2Array($Polygon2D.polygon)
		points.append($Polygon2D.polygon[0])
		$Outline.points = points

