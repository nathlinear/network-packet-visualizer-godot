# network-packet-visualizer-godot
A visualizer for a distributed distance-vector algorithm made in Godot.

## Controls
- Left click on a node to force it to send packets out
	- Note that if you move the mouse at all during the click you will instead
	drag the node
- Right click on a node or line to disable or enable it
- Press T while the mouse is next to a line to delete it

In the top left
- Toggle on and off periodic random sending of packets from each node
- Toggle on and off automatically forwarding new distance vector information
when it changes for a node
- A slider for slowing down or speeding up the simulation
- A number representing the speed of the simulation

In the bottom left
- Add a new node with some user-defined label
- Add a new link given two nodes and a distance

Misc:
- Move camera with middle mouse drag
- Zoom camera with scroll wheel
- Move nodes with left mouse drag
- Spacebar to pause and resume the simulation
- Hover over packets with the mouse to view what data they are carrying
