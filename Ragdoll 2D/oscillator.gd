#tool
extends Node2D

# mouse drag params 
var selectionDistance := 8.0
var pressed           :bool= false
var selection:PointMass
var prev_mouse_position

var link_object  := load("res://Spring.tscn") as PackedScene
var point_object := load("res://PointMass.tscn")   as PackedScene

var pointMasses := []
var mainStiffness := 1.0

func _ready():
	if !Engine.is_editor_hint():
		generate_line(Vector2(200,100), 50.0, 3)
		generateStickMan( Vector2(300.0, 300.0), 28.0)
		globals.debug = get_node("../GUI/Debug")

func _process(_delta):
	# mouse drag
	if Input.is_action_pressed("LMB"):
		if pressed:
			if selection != null:
				selection.position          = get_global_mouse_position()
				selection.previous_position = get_global_mouse_position()
				selection.velocity          = Vector2()
	if Input.is_action_pressed("RMB"):
		if pressed:
			for node in get_children():
				if get_global_mouse_position().distance_to(node.position) < selectionDistance*selectionDistance:
					node.position          += (get_global_mouse_position()-prev_mouse_position) * (1-get_global_mouse_position().distance_to(node.position)/(selectionDistance*selectionDistance))
					node.previous_position += (get_global_mouse_position()-prev_mouse_position) * (1-get_global_mouse_position().distance_to(node.position)/(selectionDistance*selectionDistance))
	prev_mouse_position = get_global_mouse_position()

func _physics_process(delta):
	for child in get_children():
		if !child.is_static:
			child.solveConstraints()
			
	for child in get_children():
		if !child.is_static:
			child.get_force()
			
	for child in get_children():
		if !child.is_static:
			child.myVerlet(delta)

func add_spring( node_1, node_2 ):
	var link = link_object.instance()
	link.initialize( node_1, node_2 )
	$"../springs".add_child( link )

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			pressed   = true
			selection = null
			for node in get_children():
				if event.position.distance_to(node.position) < selectionDistance:
					selection = node
		else:
			pressed   = false
			selection = null
		
func generate_line( line_position:Vector2, node_spacing:float, nodes_in_line:int ):
	var previous_point:PointMass
	for i in range(nodes_in_line):
		var new_point := point_object.instance()
		new_point.position = Vector2( i * node_spacing, 0 ) + line_position
		add_child(new_point)
		if i>0:
			new_point.attachTo(previous_point, 0.0, mainStiffness)
			add_spring(new_point,previous_point)
		else:
			new_point.is_static = true
		previous_point = new_point
		
func generateStickMan(headPosition:Vector2, limbLenght:float):
	
		var head := point_object.instance()
		
		head.position = headPosition
		head.set_mass(2.0)
		head.get_node("sprite").scale *= 4.0
		head.set_padding(16.0)
		add_child(head)
		
		var shoulder := point_object.instance()
		shoulder.position = head.position + Vector2(0.0, 0.5*limbLenght)
		shoulder.set_mass(3.0)
		add_child(shoulder)
		add_spring(shoulder, head)
		shoulder.attachTo(head, 0.0, mainStiffness)
		
		var elbowL := point_object.instance()
		elbowL.position = shoulder.position + Vector2(-limbLenght, 0.0)
		elbowL.set_mass(2.0)
		add_child(elbowL)
		add_spring(elbowL, shoulder)
		elbowL.attachTo(shoulder, 0.0, mainStiffness)
	
		var elbowR := point_object.instance()
		elbowR.position = shoulder.position + Vector2(limbLenght, 0.0)
		elbowR.set_mass(2.0)
		add_child(elbowR)
		add_spring(elbowR, shoulder)
		elbowR.attachTo(shoulder, 0.0, mainStiffness)
		
		var handL := point_object.instance()
		handL.position = elbowL.position + Vector2(-limbLenght, 0.0)
		handL.set_mass(2.0)
		add_child(handL)
		add_spring(handL, elbowL)
		handL.attachTo(elbowL, 0.0, mainStiffness)
		
		var handR := point_object.instance()
		handR.position = elbowR.position + Vector2(limbLenght, 0.0)
		handR.set_mass(2.0)
		add_child(handR)
		add_spring(handR, elbowR)
		handR.attachTo(elbowR, 0.0, mainStiffness)
		
		var chest := point_object.instance()
		chest.position = shoulder.position + Vector2(0.0, limbLenght)
		chest.set_mass(4.0)
		add_child(chest)
		add_spring(chest, shoulder)
		chest.attachTo(shoulder, 0.0, mainStiffness)
		
		var pelvis := point_object.instance()
		pelvis.position = chest.position + Vector2(0.0, limbLenght)
		pelvis.set_mass(3.0)
		add_child(pelvis)
		add_spring(pelvis, chest)
		pelvis.attachTo(chest, 0.0, mainStiffness)
		
		var kneeL := point_object.instance()
		kneeL.position = pelvis.position + Vector2(-limbLenght, 0.0)
		kneeL.set_mass(2.5)
		add_child(kneeL)
		add_spring(kneeL, pelvis)
		kneeL.attachTo(pelvis,  0.0, mainStiffness)
		
		var kneeR := point_object.instance()
		kneeR.position = pelvis.position + Vector2(limbLenght, 0.0)
		kneeR.set_mass(2.5)
		add_child(kneeR)
		add_spring(kneeR, pelvis)
		kneeR.attachTo(pelvis,  0.0, mainStiffness)
		
		var footL := point_object.instance()
		footL.position = kneeL.position + Vector2(-limbLenght, 0.0)
		footL.set_mass(2.0)
		add_child(footL)
		add_spring(footL, kneeL)
		footL.attachTo(kneeL,  0.0, mainStiffness)
		
		var footR := point_object.instance()
		footR.position = kneeR.position + Vector2(limbLenght, 0.0)
		footR.set_mass(2.0)
		add_child(footR)
		add_spring(footR, kneeR)
		footR.attachTo(kneeR,  0.0, mainStiffness)
		
		#straightening
		pelvis.attachTo(shoulder, 0.0, 0.8)
		pelvis.attachTo(head, 0.0, 1.0)
		footL.attachTo(pelvis, 1.8*limbLenght, 0.8)
		footR.attachTo(pelvis, 1.8*limbLenght, 0.8)
		
		kneeL.attachTo(kneeR, limbLenght, 0.1)
		elbowL.attachTo(elbowR, limbLenght, 0.05)
		handL.attachTo(shoulder, 1.8*limbLenght, 0.8)
		handR.attachTo(shoulder, 1.8*limbLenght, 0.8)
		
		chest.attachTo(footL, 2.7*limbLenght, 0.5)
		chest.attachTo(footR, 2.7*limbLenght, 0.5)

#func draw_arrow( from, to, color = Color(1.0, 1.0, 1.0, 0.5) ):
#	var arrow_point = PoolVector2Array()
#	var color_point = PoolColorArray()
#	var vec = to - from
#	if vec.length() > 10.0:
#		arrow_point.append(to + 5.0  * vec.normalized().tangent())
#		color_point.append(color)
#		arrow_point.append(to - 5.0  * vec.normalized().tangent())
#		color_point.append(color)
#		arrow_point.append(to + 10.0 * vec.normalized())
#		color_point.append(color)
#		draw_line ( from, to, color, 3 )
#		draw_polygon(arrow_point,color_point)

func _on_Gravity_value_changed(value):
	globals.gravity = Vector2(0, value)
	globals.debug.text = "Gravity = " + str(value)
	
func _on_Stiffness_value_changed(value):
	globals.stiffness = value
	globals.debug.text = "Stiffness = " + str(value)
	
func _on_Medium_value_changed(value):
	globals.medium_damping = value
	globals.debug.text = "Medium damping = " + str(value)
