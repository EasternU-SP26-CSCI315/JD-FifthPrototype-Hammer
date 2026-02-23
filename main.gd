extends Node2D


var hammer_rest_pos: Vector2 = Vector2(852, 107)
var hammer_rest_rot: float = deg_to_rad(-15.0)
var hammer_down_pos: Vector2 = Vector2(616, 453)
var hammer_down_rot: float = deg_to_rad(-90.0)

var tween: Tween
var is_tweening: bool = false
var particles_active: bool = false


@onready var hammer: Sprite2D = $Hammer
@onready var hammer_2: Sprite2D = $Hammer2
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D


func _ready() -> void:
	hammer_2.hide()
	gpu_particles_2d.finished.connect(func(): particles_active = false)


func _unhandled_input(event: InputEvent) -> void:
	if (
		event.is_action_released("ui_accept")
		and not is_tweening
		and not particles_active
	):
		hammer_hit()


func interp_transforms(w: float, from_pos: Vector2, from_rot: float, to_pos: Vector2, to_rot: float) -> void:
	hammer.position = from_pos.lerp(to_pos, w)
	hammer.rotation = lerp_angle(from_rot, to_rot, w)


func hammer_hit() -> void:
	is_tweening = true

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()

	tween \
		.tween_method(
			interp_transforms.bind(
				hammer_rest_pos, hammer_rest_rot,
				hammer_down_pos, hammer_down_rot
			),
			0.0, 1.0, 1.0
		) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_BACK)

	tween.tween_callback(func(): gpu_particles_2d.restart())

	tween \
		.tween_method(
			interp_transforms.bind(
				hammer_down_pos, hammer_down_rot,
				hammer_rest_pos, hammer_rest_rot
			),
			0.0, 1.0, 2.0
		) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUART)

	tween.tween_callback(func(): is_tweening = false)
