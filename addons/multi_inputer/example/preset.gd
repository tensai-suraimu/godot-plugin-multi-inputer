const Act2D := preload("../script/ctl/act_2d.gd")

## 机器人预设指令
static func robot_cmds(target: Node2D, action: Act2D) -> Dictionary:
	var x := target.position.x
	var y := target.position.y
	# 基础运动
	var base: Array[String] = [
		# 原地跳跃
		"t:%s,0.5" % action.act_jump,
		"t:0.5",
		# 左右移动
		"t:%s,0.5" % action.move_right,
		"t:%s,0.5" % action.move_left,
		"t:0.25",
		"t:%s,%s,0.5" % [action.move_left, action.move_slow],
		"t:%s,%s,0.5" % [action.move_right, action.move_slow],
		"t:0.25",
		# 滑铲移动
		"t:%s,%s,%s,0.2" % [action.move_right, action.move_down, action.act_jump],
		"t:%s,%s,%s,0.3" % [action.move_left, action.move_down, action.act_jump],
		"t:0.25",
		"t:%s,%s,%s,0.2" % [action.move_left, action.move_down, action.act_jump],
		"t:%s,%s,%s,0.3" % [action.move_right, action.move_down, action.act_jump],
		"t:0.5",
		# 二段跳跃
		"t:%s,%s,0.25" % [action.act_jump, action.move_left],
		"t:%s,0.25" % action.move_left,
		"t:%s,%s,0.25" % [action.act_jump, action.move_right],
		"t:%s,0.25" % action.move_right,
		"t:0.25",
	]
	# 高级跳跃
	var adv_jump: Array[String] = [
		# 攀上平台
		"t:%s,0.5" % action.act_jump,
		"t:0.5",
		# 普通对照
		"t:%s,0.5" % action.act_jump,
		"t:%s,0.5" % action.act_jump,
		"t:0.75",
		# 冲刺砸落
		"t:%s,0.5" % action.act_jump,
		"t:%s,0.5" % action.act_jump,
		"t:%s,%s,0.55" % [action.move_down, action.act_jump],
		# 低速滑翔
		"t:%s,0.5" % action.act_jump,
		"p:%s" % action.act_jump,
		"t:1.5",
		"r:%s" % action.act_jump,
		# 跃下平台
		"t:0.25",
		"t:%s,%s,0.25" % [action.act_jump,action.move_down],
		"t:0.5",
	]
	# 攀墙跳跃
	var wall_jump: Array[String] = [
		"t:%s,0.5" % action.move_right,
		"t:%s,0.5" % action.act_jump,
		"t:%s,%s,1.0" % [action.move_right, action.act_jump],
		"p:%s" % action.act_jump,
		"t:%s,0.05" % action.move_right,
		"p:%s" % action.move_left,
		"t:0.45",
		"r:%s" % action.act_jump,
		"t:0.25",
		"r:%s" % action.move_left,
		"t:%s,0.25" % action.move_right,
		"t:0.25",
		"m:%s,%s" % [x, y],
	]

	return {
		"base": base,
		"adv_jump": adv_jump,
		"wall_jump": wall_jump,
		#"walking": ,
	}
