class_name EventOverlay extends Control
const EVENT_OVERLAY = preload("res://scene/event_overlay.tscn")
@onready var label: Label = %Label

var event_message = ""

static func init_overlay(event:String):
    var event_overlay = EVENT_OVERLAY.instantiate()
    event_overlay.event_message = event.replace("_"," ")
    return event_overlay
    pass

func _ready() -> void:
    label.text = event_message
