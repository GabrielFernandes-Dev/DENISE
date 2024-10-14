extends Node3D

func _ready() -> void:
	$camera_rig/AnimationPlayer.play("intro")
