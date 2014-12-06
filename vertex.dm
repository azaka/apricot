vertex
	var
		vector4/position
		obj/pixel
		matrix/transform
		rgb

	New(x = 0, y = 0, z = -1, rgb)
		position = new(x, y, z, 1)
		src.rgb = rgb

	proc
		get_color()
			return rgb

obj
	icon = 'icon.dmi'
