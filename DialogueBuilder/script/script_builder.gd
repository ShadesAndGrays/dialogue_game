extends Node2D

var middle_clicked = false
@onready var camera_2d: Camera2D = $Camera2D
const DIALOGUE_NODE = preload("res://DialogueBuilder/scene/dialogue_node.tscn")
const CHOICE_NODE = preload("res://DialogueBuilder/scene/choice_node.tscn")
@onready var dialogues: Marker2D = %Dialogues
@onready var spawn_marker: Marker2D = %SpawnMarker
@onready var info_label: Label = %InfoLabel
@onready var info_container: ScrollContainer = %InfoContainer

var dialogue_nodes:Dictionary[DialogueNode,Array] = {} 

var current_link:DialogueNode = null

var current_index = 1

var save_file_dialog: FileDialog
var load_file_dialog: FileDialog

func extract_name(d:Node) -> String:
    return str(d.name)

func save():

    if not is_instance_valid(save_file_dialog):
        save_file_dialog = FileDialog.new()
        save_file_dialog.add_filter("*.json")
        add_child(save_file_dialog)
        save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

    save_file_dialog.show()
    var file = await save_file_dialog.file_selected
    file = FileAccess.open(file,FileAccess.WRITE_READ)

    var content = {}
    for key in dialogue_nodes:
        var key_dict = {}
        if is_instance_of(key,ChoiceNode):
            key_dict = format_choice(key)
        
        elif is_instance_of(key,ChoiceOption):
            pass
        else:
            key_dict = format_dialogue(key)
        content.merge(key_dict)
    file.store_string(JSON.stringify(content))
    file.close()

func format_dialogue(key:DialogueNode) -> Dictionary:
    var key_dict = key.to_json()
    var next = key_dict.get(extract_name(key)).get("next")

    if not dialogue_nodes[key].is_empty():
        (next as Array).clear()

    for value in dialogue_nodes[key]:
        next.append(extract_name(value))

    return key_dict

func format_choice(key:ChoiceNode):
    var key_dict = key.to_json()
    var choice = key_dict.get(extract_name(key)).get("choice")
    
    if not dialogue_nodes[key].is_empty():
        (choice as Array).clear()
        
    for value in dialogue_nodes[key]:
        choice.append(format_option(value))
        
    return key_dict

func format_option(option:ChoiceOption):
    var key_dict = option.to_json()
    var next = key_dict.get(extract_name(option)).get("next")

    if not dialogue_nodes[option].is_empty():
        (next as Array).clear()

    for value in dialogue_nodes[option]:
        next.append(extract_name(value))
    return key_dict
    
func load_save():
    if not is_instance_valid(load_file_dialog):
        load_file_dialog = FileDialog.new()
        add_child(load_file_dialog)
        load_file_dialog.add_filter("*.json")
        load_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE

    load_file_dialog.show()
    var file = await load_file_dialog.file_selected
    if not FileAccess.file_exists(file):
        print("file does not exsist",file)
    file = FileAccess.open(file,FileAccess.READ)
    var content = JSON.parse_string(file.get_as_text()) as Dictionary
    for id:String in content.keys(): # creates top link list heads
        var id_arr = id.split("#")
        match id_arr[0]:
            "c":
                var choice:ChoiceNode = spawn_choice()
                choice.set_from_json(id,content.get(id))
                for choice_option_content in content.get(id).get("choice",[]):
                    var choice_option:ChoiceOption = choice.add_choice_option()
                    var values = choice_option_content[choice_option_content.keys()[0]] 
                    choice_option.set_from_json(choice_option_content.keys()[0],values)
            "d":
                var dialogue:DialogueNode = spawn_dialogue()
                dialogue.set_from_json(id,content.get(id))
    for id:String in content.keys(): # create link list values 
        var id_arr = id.split("#")
        match  id_arr[0]:
            "c":
                var choice_node:ChoiceNode = dialogues.get_node(id) # choice node that has choice options
                var choice_options = content.get(id)["choice"]
                for choice_option in choice_options:
                    for i in choice_option.get(choice_option.keys()[0]).get("next"):
                        if i  == "0":
                            continue
                        var co = choice_node.choice_container.get_node(choice_option.keys()[0]) # get from nested choice option
                        link_nodes(co)
                        link_nodes(dialogues.get_node(i))
                    pass
                pass
            "d":
                for i in content.get(id).get("next"):
                    if i  == "0":
                        continue
                    link_nodes(dialogues.get_node(id))
                    link_nodes(dialogues.get_node(i))
                pass

func parse_dialogue_nodes() -> String:
    var text = ""
    for key in dialogue_nodes:
        var start = key.name
        text += "{0}\n".format([start])
        for value in dialogue_nodes[key]:
            var end = value.name
            text += "   ->  {0}\n".format([end])
        text += "----------------\n"
    return text

func _process(delta: float) -> void:
    queue_redraw()
    if info_container.visible:
        info_label.text = parse_dialogue_nodes()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            camera_2d.zoom.x += 0.1
            camera_2d.zoom.y += 0.1
        elif event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            if camera_2d.zoom.x > 0.1 and camera_2d.zoom.y > 0.1:
                camera_2d.zoom.x = max(camera_2d.zoom.x - 0.1 , 0.1)
                camera_2d.zoom.y = max(camera_2d.zoom.x - 0.1 , 0.1)
    if event is InputEventMouseButton:
        middle_clicked = event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE
    if middle_clicked:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        if event is InputEventMouseMotion:
            camera_2d.position -= event.relative / camera_2d.zoom
    else:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _draw() -> void:
    for key in dialogue_nodes:
        var start = key.node_container.get_global_rect()
        if not is_instance_of(key,ChoiceNode):
            
            for value in dialogue_nodes[key]:
                var end = value.node_container.get_global_rect()
                draw_line(
                    start.end - Vector2(0,start.size.y /2),
                    end.position + Vector2(0,end.size.y/2),
                    Color.WHITE,
                    1
                )
            draw_circle(start.end - Vector2(0,start.size.y /2),5,Color.DARK_GREEN)
        draw_circle(start.position + Vector2(0,start.size.y/2),5,Color.DARK_RED)

func spawn_dialogue():
    var d = DIALOGUE_NODE.instantiate()
    d.name = "d#" + str(current_index)
    current_index += 1
    dialogues.add_child(d)
    dialogue_nodes.set(d,[])
    d.global_position = spawn_marker.global_position - d.node_container.get_rect().end/2.0
    d.link_attempt.connect(link_nodes)
    d.free_me.connect(free_node)
    return d

func spawn_choice():
    var c = CHOICE_NODE.instantiate()
    c.name = "c#"+str(current_index)
    current_index += 1
    dialogues.add_child(c)
    dialogue_nodes.set(c,[])
    c.global_position = spawn_marker.global_position - c.node_container.get_rect().end/2.0
    c.link_attempt.connect(link_nodes)
    c.free_me.connect(free_node)
    c.choice_option_created.connect(_on_choice_option_created.bind(c))
    return c

func _on_choice_option_created(choice_option:ChoiceOption,choice_node:ChoiceNode):
    choice_option.name = "co#"+str(current_index)
    choice_option.label.text = choice_option.name # don't know where to place this 
    current_index += 1
    dialogue_nodes.set(choice_option,[])
    dialogue_nodes.get(choice_node).append(choice_option)

func free_node(d:DialogueNode):
    if is_instance_valid(current_link):
        current_link.linking = false
    if is_instance_valid(d):
        for key in dialogue_nodes:
            for value in dialogue_nodes[key]:
                if (dialogue_nodes[key] as Array).has(d):
                    dialogue_nodes[key].erase(d)
        if dialogue_nodes.has(d):
            dialogue_nodes.erase(d)
        d.queue_free()

func link_nodes(d:DialogueNode):
    if is_instance_valid(current_link):
        if d != current_link:
            var arr = dialogue_nodes.get(current_link) as Array
            if !arr.has(d):
                arr.append(d)
            else:
                arr.erase(d)
        current_link.linking = false
        current_link = null
    else:
        if not is_instance_of(d,ChoiceNode):
            d.linking = true
            current_link = d

func _on_add_dialogue_button_pressed() -> void:
    spawn_dialogue()

func _on_add_choice_button_pressed() -> void:
    spawn_choice()

func _on_hide_info_pressed() -> void:
    info_container.visible = not info_container.visible


func _on_save_script_button_pressed() -> void:
    save()
    pass # Replace with function body.


func _on_load_script_button_pressed() -> void:
    load_save()
    pass # Replace with function body.
