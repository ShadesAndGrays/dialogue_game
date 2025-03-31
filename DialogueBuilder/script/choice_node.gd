class_name ChoiceNode extends DialogueNode

const CHOICE_OPTION = preload("res://DialogueBuilder/scene/choice_option.tscn")
@onready var new_choice_button: Button = %NewChoiceButton
@onready var choice_container: VBoxContainer = %ChoiceContainer

signal choice_option_created(choice_option:ChoiceOption)

func set_from_json(label,dict:Dictionary):
    name = label
    self.label.text = label
    %Message.text = dict.get("msg","Invalid")
    global_position.x = dict.get("x",0)
    global_position.y = dict.get("y",0)


func to_json():
    var dict = {}
    var id = str(name)
    
    dict.set(id,{})
    dict.get(id).set("msg",%Message.text)
    dict.get(id).set("x",global_position.x)
    dict.get(id).set("y",global_position.y)
    dict.get(id).set("choice",[])
    
    return dict

func _ready() -> void:
    super._ready()
    new_choice_button.pressed.connect(add_choice_option)

func add_choice_option():
    var choice_option:ChoiceOption = CHOICE_OPTION.instantiate()
    choice_container.add_child(choice_option)
    choice_option.link_attempt.connect(link_choice)
    choice_option.free_me.connect(remove_choice)
    choice_option_created.emit(choice_option)
    return choice_option


func remove_choice(choice:ChoiceOption):
    free_me.emit(choice)

func link_choice(choice:ChoiceOption):
    link_attempt.emit(choice)
