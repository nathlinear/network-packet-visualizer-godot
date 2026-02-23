# this script handles specifically drawing the lines connecting between nodes. i
# know that there is redundancy in having these 'paths' and also 'links', having
# the same information stored in two places which is a bad programming practice,
# but unfortunately its too late to change things now :(
extends Path2D
class_name VisualPath

@export var source: NetworkNode
@export var dest: NetworkNode
@export var distance: float = 1.0

# store the original distance for restoration when toggling on and off the path
var og_dist: float
var disabled: bool = false

var line: Line2D

func _ready() -> void:
	line = $Line2D
	og_dist = distance

	self.curve = Curve2D.new()
	self.curve.add_point(Vector2.ZERO)
	self.curve.add_point(Vector2.ZERO)

func _physics_process(_delta: float) -> void:
	# exit if no source or destination
	if !source or !dest:
		return
	
	# update path connection
	self.curve.set_point_position(0, source.global_position)
	self.curve.set_point_position(1, dest.global_position)
	
	# update visable line
	line.set_point_position(0, source.global_position)
	line.set_point_position(1, dest.global_position)
	
	# update label in the middle of line displaying length
	$PathFollow2D.progress_ratio = 0.5
	$PathFollow2D/Label.text = str(self.distance)

	if source.disabled or dest.disabled:
		self.set_disabled(true)

func set_disabled(new_state: bool) -> void:
	self.disabled = new_state
	_disabled_changed()

func toggle_disabled() -> void:
	self.disabled = !self.disabled
	_disabled_changed()


func _disabled_changed() -> void:
	# these visual paths are one-way, meaning that there is a duplicate visual
	# line coming from the destination to us as well. for changing its status,
	# we'll just handle one side and make sure that when we do make changes it
	# selects both at the same time
	if disabled:
		self.modulate = Color(0.795, 0.266, 0.354, 1.0)
		self.source.my_neighbors[self.dest] = 1000
		for a in self.source.distance_vector:
			# only change value if my source node even uses this line connection
			# to reach the destination. no point in changing it if there is
			# saved a different faster route that doesnt involve this line
			if self.source.distance_vector[a][1] == self.dest:
				self.source.distance_vector[a] = [1000, self.source]
		self.distance = 1000
	else:
		self.distance = og_dist
		self.modulate = Color(1.0, 1.0, 1.0, 1.0)
		self.source.my_neighbors[self.dest] = self.distance
		self.source.distance_vector[self.dest] = [self.distance, self.dest]
