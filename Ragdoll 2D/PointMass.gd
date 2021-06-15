tool
extends Node2D
class_name PointMass

var velocity          := Vector2( 0.0, 0.0 )
var previous_position := Vector2( 0.0, 0.0 )
var force             := Vector2( 0.0, 0.0 )

var springObject  := load("res://Spring.tscn") as PackedScene

var mass              := 1.0 setget set_mass
var mu                := 1.0 # 1./mass
var neighbors         := []
var resting_length    := []

var vel := Vector2()
var springs := []
var link_object  := []
var acceleration := Vector2( 0.0, 0.0)

var padding := 0.0

export(bool) var is_static:bool = false setget set_static
func set_static(value):
	is_static = value
	if is_static:
		get_node("sprite").modulate = Color( 1.0, 0.0, 0.0 )
	else:
		get_node("sprite").modulate = Color( 1.0, 1.0, 1.0 )

func add_neighbor(point_mass):
	neighbors.append(point_mass)
	resting_length.append((point_mass.position - position).length())

func _ready():
	previous_position = position - velocity * get_physics_process_delta_time()

func get_force():
	force = Vector2.ZERO
	force += globals.gravity * mass
	
func euler( delta ):
	velocity += force * delta 
	position += velocity * delta

func symplectic_euler( delta ):
	velocity += force * delta
	position += velocity * delta 

func verlet( delta ):
	var new_position  = 2*position - previous_position 
	new_position     += force * pow( delta, 2.0 )
	
	previous_position = position
	position          = new_position
	velocity          = (position - previous_position)/delta
	
func set_velocity(v):
	velocity          = v
	previous_position = position - velocity * get_physics_process_delta_time()

func set_mass(m):
	mass = m
	mu   = pow( m, -1.0 )
	
func set_padding(p):
	padding = p
	
func solveConstraints():
	for spring in springs:
		spring.solve()
		
	if(position.x+padding> get_viewport().size.x):
		position.x = get_viewport().size.x -padding
		
	if(position.x-padding < 0.0):
		position.x = 0.0 +padding
		
	if(position.y+padding > get_viewport().size.y):
		position.y = get_viewport().size.y -padding
		
	if(position.y-padding < 0.0):
		position.y = 0.0 +padding
		
func myVerlet(delta):
	acceleration += force
	
	var vel = Vector2(position - previous_position)
	vel *= globals.medium_damping	#damping
	
	#verlet
	var nextPosition = position + vel + 0.5 * acceleration * delta * delta
	
	previous_position = position
	position = nextPosition
	acceleration = Vector2( 0.0, 0.0)
	

func attachTo(pointMass:PointMass, rest:float, stiffness:float):
	var newSpring = springObject.instance()
	newSpring.initializeLink( self, pointMass, rest, stiffness)
	springs.append( newSpring)
	
#func _draw():
#	draw_line(Vector2(),velocity, Color(0,0,0,0.2), 5 )
#	draw_line(Vector2(),damping, Color(1,0,0,0.5), 3 )
