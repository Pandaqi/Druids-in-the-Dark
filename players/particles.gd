extends CPUParticles2D

func _ready():
	set_emitting(false)

func play():
	set_emitting(true)
	await get_tree().create_timer(0.1).timeout
	set_emitting(false)
