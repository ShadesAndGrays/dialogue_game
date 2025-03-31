class_name DialogueNode extends Control
@onready var node_container: PanelContainer = %NodeContainer

@onready var focus: Panel 
@onready var label: Label = %label
@onready var delete_button: Button = %DeleteButton
@onready var link_button: Button = %LinkButton

var moving = false
var offset_mouse = Vector2(0,0)
var linking = false
var link_visual = Line2D.new()

signal link_attempt(node:DialogueNode)
signal free_me(node:DialogueNode)

var mouse_in_range = false

func set_from_json(label,dict:Dictionary):
    name = label
    self.label.text = label
    %Speaker.text = dict.get("speaker","Invalid")
    %Message.text = dict.get("msg","Invalid")
    global_position.x = dict.get("x",0)
    global_position.y = dict.get("y",0)


func to_json():
    var dict = {}
    var id = str(name)
    
    dict.set(id,{})
    dict.get(id).set("speaker",%Speaker.text)
    dict.get(id).set("msg",%Message.text)
    dict.get(id).set("x",global_position.x)
    dict.get(id).set("y",global_position.y)
    dict.get(id).set("next",["0"])
    
    return dict

func connect_buttons():
    delete_button.pressed.connect(_on_delete_button_pressed)
    link_button.pressed.connect(_on_link_button_pressed)
    pass
func connnect_node_container():
    focus = %Focus
    node_container.mouse_entered.connect(_on_node_container_mouse_entered)
    node_container.mouse_exited.connect(_on_node_container_mouse_exited)
    
func _ready() -> void:
    connect_buttons()
    connnect_node_container()
    add_child(link_visual)
    label.text = name
    link_visual.clear_points()
    link_visual.add_point(Vector2(0,0)) # start
    link_visual.add_point(Vector2(0,0)) # end

func _process(delta: float) -> void:
    if linking:
        link_visual.set_point_position(0,node_container.get_rect().end)
        link_visual.set_point_position(1,get_local_mouse_position())
        link_visual.visible = true
    else:
        link_visual.visible = false
    if is_instance_valid(focus):
        focus.visible = mouse_in_range

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and mouse_in_range:
            moving = true
            offset_mouse = get_local_mouse_position()
        elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
            moving = false

    if event is InputEventMouseMotion and moving:
        global_position = get_global_mouse_position() - offset_mouse


func _on_link_button_pressed() -> void:
    link_attempt.emit(self)


func _on_delete_button_pressed() -> void:
    free_me.emit(self)


func _on_node_container_mouse_entered() -> void:
    mouse_in_range = true
    pass # Replace with function body.


func _on_node_container_mouse_exited() -> void:
    mouse_in_range = false
    pass # Replace with function body.
