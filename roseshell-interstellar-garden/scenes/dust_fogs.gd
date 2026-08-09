extends Node2D

var dust_fog_index : int = 0
@onready var fog_particles = $FogParticles

func set_dust_fog_index(value: int):
	dust_fog_index = value
	if dust_fog_index == 1:
		print("Dust fog ACTIVATED")
		fog_particles.visible = true
		fog_particles.emitting = true
	else:
		print("Dust fog DEACTIVATED")
		fog_particles.visible = false
		fog_particles.emitting = false
