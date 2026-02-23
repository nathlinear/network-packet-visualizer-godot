# class_name ConnectionInfo
extends Resource


var source: NetworkNode
var dest: NetworkNode
var distance: float
var time_recieved: float

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(ifrom=null, ito=null, idistance=99999.9, itime_recieved=0.0):
	self.source = ifrom
	self.dest = ito
	self.distance = idistance
	self.time_recieved = itime_recieved
	
