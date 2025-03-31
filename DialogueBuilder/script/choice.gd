class_name ChoiceOption extends DialogueNode

func set_from_json(label,dict:Dictionary):
    name = label
    self.label.text = label
    %Message.text = dict.get("msg","Invalid")


func to_json():
    var dict = {}
    var id = str(name)
    
    dict.set(id,{})
    dict.get(id).set("msg",%Message.text)
    dict.get(id).set("next",["0"])
    
    return dict


func _ready() -> void:
    connect_buttons()
    add_child(link_visual)
    link_visual.clear_points()
    link_visual.add_point(Vector2(0,0)) # start 
    link_visual.add_point(Vector2(0,0)) # end
