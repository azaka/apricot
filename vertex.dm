vertex
	var
		vector4/position
		obj/pixel
		matrix/transform
		rgb

	New(x = 0, y = 0, z = -1)
		position = new(x, y, z, 1)
		rgb = rgb(rand(255), rand(255), rand(255))
		rgb = null

obj
	icon = 'icon.dmi'