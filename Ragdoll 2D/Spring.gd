tool
extends Node2D
class_name SpringNode

export(NodePath) var node_path_1:NodePath setget set_node_1
export(NodePath) var node_path_2:NodePath setget set_node_2

var from:PointMass
var to:PointMass
var restingDistance:float
var stiffness:float

func set_node_1(value:NodePath):
	node_path_1 = value
	if Engine.is_editor_hint() and has_node(value):
		from = get_node(value) as PointMass
	
func set_node_2(value:NodePath):
	node_path_2 = value
	if Engine.is_editor_hint() and has_node(value):
		to = get_node(value) as PointMass
	
func initialize( node_1:PointMass, node_2:PointMass ):
	from = node_1
	to   = node_2
	restingDistance = sqrt(pow(from.position.x-to.position.x,2)+pow(from.position.y-to.position.y,2))
	print(restingDistance)
	
func initializeLink(nodeA:PointMass, nodeB:PointMass, rest:float, stiff:float):
	from = nodeA
	to = nodeB
	var dv = Vector2(to.position.x - from.position.x, to.position.y - from.position.y)
	if(rest != 0.0):
		restingDistance = rest
	else:
		restingDistance = sqrt(dv.x * dv.x + dv.y * dv.y)
	stiffness = stiff
	print(restingDistance)
	
func solve():
	var positionFrom = Vector2(from.position)
	var positionTo = Vector2(to.position)
	
	var currentVector = Vector2(positionFrom - positionTo)
	var currentDistance = sqrt(currentVector.x*currentVector.x + currentVector.y*currentVector.y)
	
	
	var difference
	if(currentDistance!=0.0):
		difference = (restingDistance - currentDistance) / currentDistance
	else:
		difference = 0.0 #?
	
	#inverse mass here
	
	var scalarP1 = (from.mass / (from.mass+to.mass)) * stiffness
	var scalarP2 = stiffness - scalarP1
	
	#not moving static node
	if !from.is_static && !to.is_static:
		from.position += Vector2(currentVector*scalarP1*difference)
		to.position -= Vector2(currentVector*scalarP2*difference)
		
	elif from.is_static && !to.is_static:
		to.position -= Vector2(currentVector*scalarP2*difference)
		
	elif !from.is_static && to.is_static:
		from.position += Vector2(currentVector*scalarP1*difference)
		
	
	
func _ready():
#	if !Engine.is_editor_hint():
	if !from:
		from = get_node(node_path_1) as PointMass
	if !to:
		to = get_node(node_path_2) as PointMass
	from.add_neighbor(to)
	to.add_neighbor(from)
		
		
func _process( _delta ):
	if from and to :
		position            = 0.5 * ( from.position + to.position )
		
		var relation_vector := from.position - to.position
		rotation            = atan2( relation_vector.x, -relation_vector.y )
		scale.y             = relation_vector.length() / 32.0
		scale.x             = 16.0/ max( relation_vector.length() , 64.0 )

