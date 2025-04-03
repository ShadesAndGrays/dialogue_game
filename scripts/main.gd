extends Node2D
const DIALOGUE_SYSTEM = preload("res://scene/dialogue_system.tscn")
var story = Story.new("res://dialogue/enlightenment.json")

var current_dialogue:Dialogue = null

func _ready() -> void:
    progress_dialogue(["d#1"])
    pass

func spawn_dialogue(msg:Dictionary):
    if is_instance_valid(current_dialogue):
        current_dialogue.queue_free() 
    current_dialogue = DIALOGUE_SYSTEM.instantiate() as Dialogue
    current_dialogue.dialogue = msg
    add_child(current_dialogue)
    current_dialogue.finished.connect(progress_dialogue)

func progress_dialogue(route:Array):
    var next_route:String = route[0]
    if next_route.begins_with("e"):
        var story_node = story.get_dialogue(route[0])
        add_child(EventOverlay.init_overlay(story_node.get("msg")))
        await get_tree().create_timer(1).timeout
        if !str(story_node.get("msg")).contains("ENDING"):
            spawn_dialogue(story.get_dialogue(story_node.get("next")[0]))
        else:
            current_dialogue.clear()
    else:
        spawn_dialogue(story.get_dialogue(route[0]))
    pass
