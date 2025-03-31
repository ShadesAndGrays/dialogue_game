extends Node2D
const DIALOGUE_SYSTEM = preload("res://scene/dialogue_system.tscn")
var story = Story.new()


var current_dialogue = null

func _ready() -> void:
    progress_dialogue("a1")
    pass

func spawn_dialogue(msg:Dictionary):
    if is_instance_valid(current_dialogue):
        current_dialogue.queue_free() 
    current_dialogue = DIALOGUE_SYSTEM.instantiate()
    current_dialogue.dialogue = msg
    add_child(current_dialogue)
    current_dialogue.finished.connect(progress_dialogue)

func progress_dialogue(route:String):
    spawn_dialogue(story.get_dialogue(route))
    pass
