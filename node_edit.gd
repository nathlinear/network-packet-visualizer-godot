# this script handles camera controls, toggling nodes and links, deleting links,
# and timescale.
extends Node2D

@export var links: Array[Link]
@export var zoom_speed: float = 0.9

var dragged_node: NetworkNode
var dragged_prev_pos: Vector2
var camera: Camera2D
var is_paused: bool = false

func _ready():
	camera = $Camera2D

	for link in links:
		var n1 = get_node(link.node1)
		var n2 = get_node(link.node2)
		if n1 is NetworkNode and n2 is NetworkNode:
			# add each other's neighbor for both nodes
			n1.add_neighbor(n2, link.cost)
			n2.add_neighbor(n1, link.cost)
		else:
			print("Attempted to link a non-network node object!")


func _physics_process(_delta: float) -> void:
	if is_paused:
		Engine.time_scale = 0.0
	else:
		Engine.time_scale = $CanvasLayer/UIButtons/HScrollBar.value

	# handles showing the data of a packet on mouse hover
	var pos = get_global_mouse_position()
	var packet = null
	var dist = -1
	for obj in get_tree().get_nodes_in_group("packet"):
		var p_dist = obj.global_position.distance_to(pos)
		if dist < 0:
			dist = p_dist
			packet = obj
		elif p_dist < dist:
			dist = p_dist
			packet = obj
	
	if dist < 50.0 and packet:
		$MouseLabel.visible = true
		$MouseLabel.global_position = pos
		$MouseLabel.text = _data_to_text(packet.data)
	else:
		$MouseLabel.visible = false

func _data_to_text(distance_vector):
	var new_text = ""
	for elem in distance_vector:
		var info = distance_vector[elem]
		new_text += "node %s, distance: %s via %s \n" % [elem.name, info[0], info[1].name]
	
	return new_text

func _delete_paths_near_mouse() -> void:
	var paths: Array[VisualPath] = _get_paths_near_mouse()
	if len(paths) > 0:
		for path in paths:
			path.source.remove_neighbor(path.dest)
	return

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.key_label == KEY_SPACE:
			is_paused = !is_paused
		elif event.key_label == KEY_T:
			_delete_paths_near_mouse()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:

				dragged_node = _get_node_near_mouse()
				if dragged_node:
					dragged_prev_pos = dragged_node.position
			
			# mouse release, and there was a node clicked on
			elif dragged_node != null:
				if dragged_node.position == dragged_prev_pos:
					# didnt move
					dragged_node._send_packet()
				dragged_node = null

		# scroll wheel down
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera.zoom *= Vector2(zoom_speed, zoom_speed)
		
		# scrool wheel up
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera.zoom /= Vector2(zoom_speed, zoom_speed)
		
		# right click down
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var node = _get_node_near_mouse()

			# prioritize toggling nodes first, then if not see if user meant
			# path instead
			if node:
				node.toggle_disabled()
			else:
				var paths: Array[VisualPath] = _get_paths_near_mouse()
				if len(paths) > 0:
					for path in paths:
						path.toggle_disabled()
	
	# not a mouse click, just a mouse movement
	if event is InputEventMouseMotion:
		if dragged_node != null:
			dragged_node.global_position = get_global_mouse_position()

		# middle click drag
		elif event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			camera.position -= event.relative / camera.zoom

func _get_node_near_mouse() -> NetworkNode:
	var pos = get_global_mouse_position()
	for obj in get_tree().get_nodes_in_group("network"):
		if obj is NetworkNode:
			var dist = pos.distance_to(obj.position)
			if dist < 50.0:
				return obj
	return null

func _get_paths_near_mouse() -> Array[VisualPath]:
	var pos = get_global_mouse_position()
	var paths: Array[VisualPath] = []
	for path in get_tree().get_nodes_in_group("link"):
		if path is VisualPath:
			var start = path.get_curve().get_point_position(0)
			var end = path.get_curve().get_point_position(1)
			var closest_point = Geometry2D.get_closest_point_to_segment(pos, start, end)
			if pos.distance_to(closest_point) < 50.0:
				paths.append(path)
	return paths
