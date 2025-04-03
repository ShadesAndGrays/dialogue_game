class_name Story extends Node

var dialogue = {
    a1 = {
        msg = "What a morning", 
        next = "a2"
        },
    a2 = {
        msg = "I should get out head now",
        choice = [
            {msg = "Nah" , next = "a1"},
            {msg = "Fine...", next = "a3"}
        ],
        next = "a3"
        }
}

func load_story(path:String):
    var file = FileAccess.open(path,FileAccess.READ)
    if not file.is_open():
        printerr("File failed to open", file)
        return
    dialogue = JSON.parse_string(file.get_as_text())
    
func _init(path:String) -> void:
    load_story(path)

func get_dialogue(key:String):
    if dialogue.has(key):
        return dialogue.get(key)
    else:
        return { msg = "Error: dialogue not found" , next = "0l"}
