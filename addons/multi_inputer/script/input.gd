extends Node


const CTL := preload("./ctl/controller.gd")
const Robot := preload("./robot.gd")

const MAX_JOYPAD_ID := 15


## Get the next usable joypad id
static func usable() -> int:
	var flag := 1
	for id in MAX_JOYPAD_ID + 1:
		if _reg_flag & flag == 0:
			return id
		flag <<= 1
	return -1


## Get the standalone action name of 'joypad_id'.
## It will returns 'action_name' directly if 'joypad_id' has not been registered.
static func action(joypad_id: int, action_name: String) -> String:
	if joypad_id < 0 or joypad_id > MAX_JOYPAD_ID:
		return action_name
	var flag := 1 << joypad_id
	if _reg_flag & flag == 0:
		return action_name
	return _action(joypad_id, action_name)


## Register a joypad as a standalone device.
## ‘joypad_id' should between [0, 7]
## Returns false if register failed.
static func regist(joypad_id: int) -> bool:
	if joypad_id < 0 or joypad_id > MAX_JOYPAD_ID:
		return false
	var flag := 1 << joypad_id
	if _reg_flag & flag != 0:
		return false
	if _reg_flag == 0:
		_prepare()
	_reg_flag |= flag
	_regist(joypad_id)
	return true


## Remove the registered joypad.
## ‘joypad_id' should between [0, 7]
## Returns false if remove failed.
static func remove(joypad_id: int) -> bool:
	if joypad_id < 0 or joypad_id > MAX_JOYPAD_ID:
		return false
	var flag := 1 << joypad_id
	if _reg_flag & flag == 0:
		return false
	_remove(joypad_id)
	_reg_flag -= flag
	if _reg_flag == 0:
		_restore()
	return true


## Remmove all registered joypads.
static func remove_all() -> void:
	for id in MAX_JOYPAD_ID + 1:
		if _reg_flag & 0b1 != 0:
			_remove(id)
		_reg_flag >>= 1
	_reg_flag = 0
	_restore()

#

#region inner

static var _reg_flag := 0
static var _action_names := PackedStringArray()


static func _action(id: int, name: String) -> String:
	return "m_%s_%02d" % [name, id]


static func _prepare() -> void:
	var action_names: = InputMap.get_actions()
	for name in action_names:
		if name.begins_with("ui_"): # ignore ui actions
			continue
		var events := InputMap.action_get_events(name)
		for event in events:
			if _is_joypad_event(event):
				event.device = (2 << MAX_JOYPAD_ID) - 1
		_action_names.append(name)

static func _restore() -> void:
	for name in _action_names:
		var events := InputMap.action_get_events(name)
		for event in events:
			if _is_joypad_event(event):
				event.device = -1
	_action_names = []

static func _regist(id: int) -> void:
	for name in _action_names:
		var new_name := _action(id, name)
		InputMap.add_action(new_name)
		var events := InputMap.action_get_events(name)
		for event in events:
			if _is_joypad_event(event):
				var new_event := event.duplicate()
				new_event.device = id
				InputMap.action_add_event(new_name, new_event)

static func _remove(id: int) -> void:
	for name in _action_names:
		var new_name := _action(id, name)
		InputMap.erase_action(new_name)


static func _is_joypad_event(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion

#endregion
