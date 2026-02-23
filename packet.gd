# this script handles packets, specifically their data and attaching them onto
# the path between two nodes
extends PathFollow2D
class_name Packet


@export var path: VisualPath
var data

# these variables save the information about the path in case it changes, like
# the length or something, while the packet is traversing it. but changing the
# properties of a path isn't currently possible
var _path_dist
var _path_source
var _path_dest

# was going to be used either as the packet's timestamp or the time taken to
# reach the destination, but it got replaced with the link's cost/distance
var _time: float = 0.0

func _ready() -> void:
	_path_dist = path.distance
	_path_source = path.source
	_path_dest = path.dest
	
	_set_label()
	if data is not Dictionary:
		if data == 0:
			self.scale = Vector2(0.5, 0.5)
			$Sprite2D.self_modulate = Color(0.586, 0.419, 0.775, 1.0)
		if data == 1:
			self.scale = Vector2(0.5, 0.5)
			$Sprite2D.self_modulate = Color(0.515, 0.296, 0.714, 1.0)

func _physics_process(delta: float) -> void:
	self._time += delta

	# move from 0.0 to 1.0 over the amount of seconds of the distance
	self.progress_ratio = _time / _path_dist
	
	if progress_ratio == 1.0:
		_path_dest.inform(_path_dist, _path_source, _path_dest, data)
		self.queue_free()

func _set_label() -> void:
	var new_text = ""
	new_text += "%s to %s" % [_path_source.name, _path_dest.name]
	$Label.text = new_text
