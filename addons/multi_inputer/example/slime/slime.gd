extends CharacterBody2D


const Act2D := preload("../../script/ctl/act_2d.gd")


## 控制器组件
@export var controller: Act2D

## 本进程玩家的 z_index。
## 覆盖 z_index 以令本进程玩家显示在其他玩家之上
@export var auth_z_index := 1

## 光照强度
@export var light_energy := 0.0:
	get:
		return $PointLight2D.energy
	set(value):
		if value <= 0.0:
			$PointLight2D.energy = 0.0
			$PointLight2D.enabled = false
		$PointLight2D.energy = value
		$PointLight2D.enabled = true


@export_subgroup("sync", "sync")
@export var sync_position: Vector2:
	get:
		return position
	set(value):
		position = value

@export var sync_velocity: Vector2:
	get:
		return velocity
	set(value):
		velocity = value

@export var sync_flip_h: bool:
	get:
		return $Sprite2D.flip_h
	set(value):
		$Sprite2D.flip_h = value

@export var sync_jumping: Act2D.JumpStatus = Act2D.JumpStatus.NONE


@onready var _sprite_2d := $Sprite2D
@onready var _anim_player := $AnimationPlayer
@onready var _ghosts := $Ghosts


func _ready() -> void:
	if auth_z_index and is_multiplayer_authority():
		z_index = auth_z_index


func _process(_delta: float) -> void:
	_handle_animation()
	# 固定拖影容器全局位置，避免残影被一起拖拽着移动。
	# 这个方案感觉不太合适，以后再看有没有更好的方案。
	_ghosts.global_position = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		controller.velocity_scale = scale
		controller.handle_move(self, delta)
	move_and_slide()


func _handle_animation() -> void:
	if is_multiplayer_authority():
		sync_jumping = controller.jumping
		_sprite_2d.flip_h = controller.direction > 0

	match sync_jumping:
		# 非跳跃状态
		Act2D.JumpStatus.NONE:
			if not velocity.x:
				_play_animation("idle")
			else:
				var move_slow := -0.5 <= controller.direction and controller.direction <= 0.5
				_play_animation("move", 1.0 if move_slow else 2.0)
		# 跳跃状态
		Act2D.JumpStatus.JUMP:
			_play_once_animation("jump")
		# 砸落状态
		Act2D.JumpStatus.DIVE:
			if is_on_floor():
				# 地面滑铲
				_play_once_animation("squat")
			else:
				# 加速砸落
				_play_once_animation("fall")
			_ghosts.auto_play(position / scale)
		# 其他状态暂且都视为正常降落
		_: # FALL, STAY
			_play_once_animation("fall")

func _play_animation(target: String, speed := 1.0):
	match _anim_player.assigned_animation:
		"squat":
			_anim_player.play("RESET")
			_anim_player.seek(0, true)
	_anim_player.play(target, -1, speed)

func _play_once_animation(target: String):
	if _anim_player.assigned_animation != target:
		_play_animation(target)
