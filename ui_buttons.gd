# this script was ment to simply handle the user interface and hand over
# information to a more appropriate script, but then it became responsible for
# adding links and nodes as well
extends VBoxContainer

var network_node_scene = preload("res://network_node.tscn")
var link = preload("res://visual_path.tscn")

func _ready() -> void:
	$"../VBoxAdd/HBoxNode/NodeAdd".pressed.connect(_add_node)
	$"../VBoxAdd/HBoxLink/LinkAdd".pressed.connect(_add_link)
	$CheckBox.toggled.connect(_on_check_box_toggled)

func _add_node():
	var new_id: String = $"../VBoxAdd/HBoxNode/NodeName".text
	var exists_already: bool = false

	# check to see if there is already a NetworkNode with this name
	for obj in get_tree().get_nodes_in_group("network"):
		if obj is NetworkNode:
			if obj.router_name == new_id:
				exists_already = true
	
	# don't add if a node with the same name already exists
	if !exists_already:
		var new_node: NetworkNode = network_node_scene.instantiate()
		new_node.router_name = new_id
		get_tree().current_scene.add_child(new_node)

func _add_link():
	var n1_name: String = $"../VBoxAdd/HBoxLink/LinkSource".text
	var n2_name: String = $"../VBoxAdd/HBoxLink/LinkDest".text
	
	var n1: NetworkNode
	var n2: NetworkNode
	for obj in get_tree().get_nodes_in_group("network"):
		if obj is NetworkNode:
			if obj.router_name == n1_name:
				n1 = obj
			elif obj.router_name == n2_name:
				n2 = obj
	
	# dont add if the source nor destination don't exist
	if n1 == null or n2 == null:
		return
	
	var cost_string: String = $"../VBoxAdd/HBoxLink/LinkDist".text
	
	# please dont put letters in the number field
	if !cost_string.is_valid_float():
		return
	
	var cost: float = float(cost_string)
	
	n1.add_neighbor(n2, cost)
	n2.add_neighbor(n1, cost)

func _on_check_box_toggled(toggled_on: bool) -> void:
	Global.auto = toggled_on

func _physics_process(_delta: float) -> void:
	Global.auto_forward = $ForwardChanges.button_pressed
	$SpeedLabel.text = str(Engine.time_scale)

	
