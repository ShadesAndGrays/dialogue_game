class_name Dialogue extends Control

var dialogue = {
    msg = "hero",
    choice = [
        {msg = "hero time" , next = "a1"},
        {msg = "nahh...", next= "a1"}
    ],
    next = "a1"
    }
@onready var button: Button = $Button

signal finished(choice:Array[String])
@onready var timer: Timer = $Timer

@onready var message_label: Label = %MessageLabel

@onready var delay: Timer = $delay
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var choices_panel: PanelContainer = %ChoicesPanel

func _ready() -> void:
    message_label.text = dialogue.get("msg")
    message_label.visible_characters = 0
    if dialogue.has("choice"):
        $Button.visible = false
    pass


func _process(delta: float) -> void:
    
    pass


func _on_button_pressed() -> void:
    finished.emit(dialogue.get("next"))
    pass # Replace with function body.


func _on_timer_timeout() -> void:
    if message_label.visible_characters < message_label.get_total_character_count():
        message_label.visible_characters +=1
    else:
        timer.stop()
        delay.start()
        if dialogue.has("choice"):
            choices_panel.visible = true
            for i in dialogue.get("choice"):
                var button = Button.new()
                var choice =  i.get(i.keys()[0])
                button.text = choice.get("msg","Error")
                button.pressed.connect(finished.emit.bind(choice.get("next")))
                choices_container.add_child(button)


func _on_delay_timeout() -> void:
    $Button/AnimationPlayer.play("flash")
    pass # Replace with function body.
