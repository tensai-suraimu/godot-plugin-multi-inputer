@tool
extends Node2D
## 幽灵拖影生成器


const opacity := Color(1.0, 1.0, 1.0, 0.0)


## 幽灵数量
@export var size := 0:
	get:
		return size
	set(value):
		size = value
		if Engine.is_editor_hint() and is_inside_tree():
			_create_ghosts()
			
## 本体精灵
@export var sprite: Sprite2D
## 生成间隔
@export var interval := 0.05
## 持续时长
@export var duration := 0.50


func _create_ghosts() -> void:
	var count := get_child_count()
	if count < size:
		for i in range(count, size):
			var ghost = get_child(0).duplicate() if count else Sprite2D.new()
			ghost.name = "Ghost#%d" % i
			ghost.visible = false
			add_child(ghost)
			ghost.owner = get_tree().edited_scene_root
	elif size < count:
		for i in range(count, size, -1):
			var ghost := get_child(i - 1)
			if ghost and ghost is Node:
				ghost.queue_free()


var _next_timer := 0.0
var _ghost_index := 0

func auto_play(pos: Vector2) -> void:
	if _next_timer > 0.0:
		return
	var count := get_child_count()
	if not count:
		return
	visible = true
	var ghost := get_child(_ghost_index)
	if not ghost is Sprite2D:
		return
	ghost.visible = true
	ghost.texture = sprite.texture
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.scale = sprite.scale
	ghost.position = pos + sprite.position

	_next_timer = interval
	_ghost_index += 1
	if _ghost_index >= count:
		_ghost_index = 0
	var tween := create_tween() # Tween 并不是针对重用设计的，尝试重用会造成未定义行为。
	var property := tween.tween_property(ghost, "self_modulate", opacity, duration)
	property.from(Color.WHITE)


func _process(delta: float) -> void:
	if _next_timer > 0.0:
		_next_timer -= delta
