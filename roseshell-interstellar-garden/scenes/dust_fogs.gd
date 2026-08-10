extends Node2D

var dust_fog_index : int = 0
@onready var fog_particles = $FogParticles

func set_dust_fog_index(value: int):
	dust_fog_index = value
	if dust_fog_index >= 1 and dust_fog_index <= 5:
		fog_particles.visible = true
		fog_particles.emitting = true
		apply_color_scheme(dust_fog_index)
	else:
		fog_particles.visible = false
		fog_particles.emitting = false

func apply_color_scheme(index: int):
	var material = fog_particles.process_material
	if material == null:
		return
	
	var gradient = Gradient.new()
	
	match index:
		1:
			gradient.colors = [
				Color(0.0, 0.8, 0.0, 0.0),
				Color(0.68, 0.829, 0.638, 0.8),
				Color(0.441, 0.664, 0.149, 1.0),
				Color(0.8, 0.9, 0.1, 0.8),
				Color(0.6, 0.8, 0.9, 0.6),
				Color(0.0, 0.5, 0.8, 0.0)
			]
			gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
			
		2:
			gradient.colors = [
				Color(0.8, 0.0, 0.4, 0.0),
				Color(1.0, 0.2, 0.6, 0.8),
				Color(0.983, 0.358, 0.79, 1.0),
				Color(0.638, 0.146, 0.851, 0.9),
				Color(0.5, 0.0, 0.8, 0.6),
				Color(0.3, 0.0, 0.6, 0.0)
			]
			gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
			
		3:
			gradient.colors = [
				Color(0.0, 0.3, 0.8, 0.0),
				Color(0.0, 0.6, 1.0, 0.8),
				Color(0.0, 0.8, 1.0, 1.0),
				Color(0.3, 0.9, 1.0, 0.9),
				Color(0.8, 0.9, 1.0, 0.6),
				Color(0.9, 0.9, 1.0, 0.0)
			]
			gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
			
		4:
			gradient.colors = [
				Color(0.8, 0.2, 0.0, 0.0),
				Color(1.0, 0.3, 0.0, 0.8),
				Color(1.0, 0.5, 0.0, 1.0),
				Color(1.0, 0.7, 0.1, 0.9),
				Color(0.9, 0.8, 0.2, 0.6),
				Color(0.8, 0.7, 0.1, 0.0)
			]
			gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
			
		5:
			gradient.colors = [
				Color(0.1, 0.0, 0.2, 0.0),
				Color(0.3, 0.0, 0.5, 0.8),
				Color(0.5, 0.0, 0.7, 1.0),
				Color(0.7, 0.1, 0.9, 0.9),
				Color(0.5, 0.0, 0.6, 0.6),
				Color(0.2, 0.0, 0.3, 0.0)
			]
			gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
