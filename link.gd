# custom datastructure defining a bi-directional link from one network
# node to another and the associated cost/length of the link.

class_name Link
extends Resource

@export var node1: NodePath = NodePath("")
@export var node2: NodePath = NodePath("")
@export var cost: float = 0.0