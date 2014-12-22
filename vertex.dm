vertex
	var
		vector4/position
		obj/pixel
		matrix/transform
		rgb
		material/material
		list/tex_coord
		vector3/normal
		vector4/clip_position

	New(x = 0, y = 0, z = -1)
		position = new(x, y, z, 1)
		if(args.len == 4 && istext(args[4]))
			src.rgb = args[4]
		else if(args.len == 6 && istype(args[4], /material))
			material = args[4]
			tex_coord = list(args[5], args[6])

obj
	icon = 'icon.dmi'
