extends Node


const MInput := preload("../script/input.gd")
const Preset := preload("./preset.gd")


@onready var _character := $SlimeCharacter
@onready var _controller: MInput.CTL.Act2D = _character.controller
@onready var _buttons := $HUD/Control/Buttons
@onready var _stage := $ActionStage

func _ready() -> void:
	var preset_cmds := Preset.robot_cmds(_character, _controller)
	for key in preset_cmds:
		var group: String = key.to_pascal_case()
		var button := Button.new()
		button.name = "Button#%s" % group
		button.text = group
		button.pressed.connect(func():
			_prepare_stage(group)
			button.release_focus()
			var cmds: Array[String] = preset_cmds[key]
			var robot = _controller.create_robot(_character, cmds) as MInput.Robot
			#robot.queue(cmds)
			robot.queue(["v:0,0.5,0.5,0.1", "close"])
		)
		_buttons.add_child(button)
	var close_button := _buttons.get_node("CloseButton")
	close_button.pressed.connect(func():
		_prepare_stage("")
		close_button.release_focus()
		_controller.clear_robot()
		_character.position = Vector2.ZERO
	)
	_prepare_stage("")


func _prepare_stage(group: String) -> void:
	for node in _stage.get_children():
		var show := node.name == group
		var mode := (
			Node.PROCESS_MODE_INHERIT if show
			else Node.PROCESS_MODE_DISABLED
		)
		node.process_mode = mode
		if node is CanvasItem:
			node.visible = show
