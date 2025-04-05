extends Control

@onready var save_icon: TextureRect = %save_icon
const CIRCLE_FILLED = preload("res://DialogueBuilder/asset/circle_filled.png")
const CIRCLE_SPACE = preload("res://DialogueBuilder/asset/circle_space.png")
@onready var auto_save_label: Label = %AutoSaveLabel

signal load_file
signal save_file
signal save_file_as
signal close_file
signal exit

signal add_dialogue
signal add_choice
signal add_event

signal toggle_degbug_info

enum FILE_POPUP_OPTIONS{
    LOAD = 1,
    SAVE = 2,
    SAVE_AS = 3,
    CLOSE = 5,
    EXIT = 0
}

enum NODE_POPUP_OPTIONS{
    DIALOGUE = 0,
    CHOICE = 1,
    EVENT = 2
}
enum INFO_POPUP_OPTIONS{
    DEBUG_CONN = 0,
}

func set_auto_save_visible(show:bool):
    auto_save_label.visible = show

func set_save_icon(save:bool):
    if save:
        save_icon.texture = CIRCLE_FILLED 
    else:
        save_icon.texture = CIRCLE_SPACE
        

func _on_file_id_pressed(id: int) -> void:
    match id:
        FILE_POPUP_OPTIONS.LOAD:
            load_file.emit()
        FILE_POPUP_OPTIONS.SAVE:
            save_file.emit()
        FILE_POPUP_OPTIONS.SAVE_AS:
            save_file_as.emit()
        FILE_POPUP_OPTIONS.CLOSE:
            close_file.emit()
        FILE_POPUP_OPTIONS.EXIT:
            exit.emit()


func _on_node_id_pressed(id: int) -> void:
    match id:
        NODE_POPUP_OPTIONS.DIALOGUE:
            add_dialogue.emit()
        NODE_POPUP_OPTIONS.CHOICE:
            add_choice.emit()
        NODE_POPUP_OPTIONS.EVENT:
            add_event.emit()


func _on_info_id_pressed(id: int) -> void:
    match id:
        INFO_POPUP_OPTIONS.DEBUG_CONN:
            toggle_degbug_info.emit()
    pass # Replace with function body.
