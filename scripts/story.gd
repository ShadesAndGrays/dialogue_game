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

func get_dialogue(key:String):
    if dialogue.has(key):
        return dialogue.get(key)
    else:
        return { msg = "Error: dialogue not found" , next = "0l"}
