# Multiplayer Inputer

## Online Demo:

https://zhengxiaoyao0716.itch.io/godot-plugin-multi-inputer

## Asset Project:

https://zhengxiaoyao0716.itch.io/cute-slime

## Godot Plugin:

https://godotengine.org/asset-library/asset/2666

## Preview, Examples & Api:

[issue#1](https://github.com/tensai-suraimu/godot-plugin-multi-player/issues/1)

## Usage:

```gdscript

var joypad_id: int


func _ready() -> void:
	MInput.regist(joypad_id)


# multi-inputer action name
func _ma(name: String) -> String:
	return MInput.action(joypad_id, name)


func handle():
	var direction := Input.get_axis(_ma("move_left"), _ma("move_right"))
  ...

```
