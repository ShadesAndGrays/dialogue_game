class_name EventNode extends DialogueNode

@onready var message_format_timer: Timer = $MessageFormatTimer

func _ready() -> void:
    super._ready()
    message_format_timer.timeout.connect(reformat_text)

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
    dict.get(id).set("next",["0"])

    return dict


func _on_message_text_changed() -> void:
    message_format_timer.start()

func format_text(txt:String):
    txt = txt.to_upper()
    txt = txt.replace(" ","_")
    return txt

func reformat_text():
    if %Message.text != format_text(%Message.text):
        var col = %Message.get_caret_column()
        %Message.text = format_text(%Message.text)
        %Message.set_caret_column(col)
