## 计算并跟随若干节点的中心位置

extends Node


## 存储中心位置的目标节点
@export var target_node: Node = self

## 追踪中心位置的插值系数
@export var follow_lerp := 0.1
## 追踪中心位置的距离阈值
@export var follow_threshold := 128
## 追踪坐标维度
@export_enum("x:1", "xy:2", "xyz:3") var follow_dimension := 3
## 纳入坐标计算的节点列表
@export var follow_nodes: Array[Node] = []

#

@onready var _position: Variant = target_node.position

func _physics_process(delta: float) -> void:
	var num := follow_nodes.size()
	if num == 0:
		target_node.position = _position
		return
	elif num == 1:
		var node := follow_nodes[0]
		_follow(delta, 0, node.position.x)
		if follow_dimension <= 1:
			return
		_follow(delta, 1, node.position.y)
		if follow_dimension <= 2:
			return
		_follow(delta, 2, node.position.z)
		return

	var min := +INF
	var max := -INF
	for node in follow_nodes:
		var pos = node.position
		if pos.x < min:
			min = pos.x
		if max < pos.x:
			max = pos.x
	_follow(delta, 0, (min + max) / num)
	if follow_dimension <= 1:
		return
	min = +INF
	max = -INF
	for node in follow_nodes:
		var pos = node.position
		if pos.y < min:
			min = pos.y
		if max < pos.y:
			max = pos.y
	_follow(delta, 1, (min + max) / num)
	if follow_dimension <= 2:
		return
	min = +INF
	max = -INF
	for node in follow_nodes:
		var pos = node.position
		if pos.z < min:
			min = pos.z
		if max < pos.z:
			max = pos.z
	_follow(delta, 2, (min + max) / num)

var _buffer_pos := Vector3.ZERO
var _catching := 0

func _follow(delta: float, index: int, target: float):
	var current: float = target_node.position[index]
	var result := target
	var diff := target - current
	var over := absf(diff) / follow_threshold
	var flag := 1 << index

	if over >= 1:
		_catching |= flag
	elif over < 0.01 and (flag & _catching):
		_catching -= flag

	if (flag & _catching):
		result = current + target - _buffer_pos[index]
		# 由于误差，偏移距离可能仍然会加大，超过阈值两倍开始时强制修正
		if over >=2:
			result += diff * delta
	else:
		result = lerpf(current, target, follow_lerp)
	_buffer_pos[index] = target
	target_node.position[index] = result
