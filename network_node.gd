extends Node2D
class_name NetworkNode

@export var router_name: String

var packet_scene: Resource = preload("res://packet.tscn")
var visual_scene : Resource = preload("res://visual_path.tscn")

# dictionary representing a distance vector table. the 'key' is the target node.
# in the array, the first element is a float representing the total
# cost/distance it currently thinks it takes to be able to reach this target
# node from itself. the second element is the node it should 'forward' to
var distance_vector: Dictionary[NetworkNode, Array] = {self: [0.0, self]}

# dictionary with only directly connected neighbors. only stores the distance
# cause, well, its directly connected. if this node becomes disabled, all of
# the other neighbors who directly connect to this node will *immediately* know
# that the distance to this node is infinity (in reality it should not be immediate
# for the neighbors to know but i'm cheating)
var my_neighbors: Dictionary[NetworkNode, float] = {}

# an array storing the visually drawn line connecting this node. if a link is deleted,
# this object has to handle deleting this visually drawn line itself
var paths: Array[VisualPath]

var disabled: bool = false

func _ready() -> void:
	if router_name:
		$Label.text = router_name

	# connect this object's internal timer to the _packet_timer method
	$Timer.timeout.connect(_packet_timer)

func _packet_timer():

	# the internal timer timed-out. if automatically sending distance vector
	# tables is enabled, do it
	if Global.auto:
		_send_packet()

	# start the timer again with a random amount of time
	$Timer.start(randf_range(1.0, 10.0))

func _process(_delta: float) -> void:
	self.update_description()

func add_neighbor(neighbor, cost):
	self.my_neighbors[neighbor] = cost
	self.distance_vector[neighbor] = [cost, neighbor]
	add_path(neighbor, cost)

func add_path(neighbor, cost):
	var new_path = visual_scene.instantiate()
	new_path.source = self
	new_path.dest = neighbor
	new_path.distance = cost
	add_child(new_path)
	paths.append(new_path)

func remove_neighbor(neighbor):
	self.my_neighbors[neighbor] = 99999
	self.distance_vector[neighbor] = [99999, neighbor]
	
	# iterate over duplicate so that we can remove from the original as we iterate
	for path in paths.duplicate():
		if path.dest == neighbor:
			path.queue_free()
			paths.erase(path)


func update_distances(from_node: NetworkNode, new_data: Dictionary):
	var prev_distances = distance_vector.duplicate()
	var link_cost: float = self.my_neighbors[from_node]
	
	for dest in new_data:
		if dest == self:
			continue
		var their_cost: float = new_data[dest][0]
		var new_cost: float = link_cost + their_cost
		var old_cost: float = distance_vector.get(dest, [999999, null])[0]
	
		if new_cost < old_cost:
			self.distance_vector[dest] = [new_cost, from_node]
		
		# if my current route to some destination routes via the node that i
		# just got information from, that means i have to override what value i
		# have with theirs + my cost to them
		if self.distance_vector[dest][1] == from_node:
			self.distance_vector[dest] = [new_cost, from_node]
	
	if distance_vector != prev_distances and Global.auto_forward:
		self._send_packet()

func _send_packet():
	for path in paths:
		if path.distance >= 999:
			continue
		var packet = packet_scene.instantiate()
		packet.path = path
		packet.data = distance_vector.duplicate()
		path.add_child(packet)
	
func set_disabled(new_state: bool) -> void:
	self.disabled = new_state
	_disabled_changed()

func toggle_disabled():
	self.disabled = !self.disabled
	_disabled_changed()

func _disabled_changed():
	if disabled:
		self.modulate = Color(0.795, 0.266, 0.354, 1.0)
	else:
		self.modulate = Color(1.0, 1.0, 1.0, 1.0)

func inform(_packet_dist: float, packet_source: NetworkNode, _packet_dest: NetworkNode, incoming_data):
	# function that packet calls on the destination node once it reaches here
	
	#print(self.name + " ----------------------------")
	update_distances(packet_source, incoming_data)

	#for elem in distance_vector:
		#var s = "node %s, distance: %s" % [elem.name, distance_vector[elem]]
		#print(s)
	#print()

func update_description():
	# display the distance vector data in a more readable format
	var new_text = ""
	for elem in distance_vector:
		var info = distance_vector[elem]
		# omit displaying the self-connection cost of 0
		#if info[1] == self:
			#continue   
		new_text += "node %s, distance: %s via %s \n" % [elem.router_name, info[0], info[1].router_name]

	$Label2.text = new_text
