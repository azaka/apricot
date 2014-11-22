client
	var
		matrix/transform

	verb
		new_matrix4x4()
			var/matrix4/mat = new \
			(1, 2, 3, 4, \
			3, 2, 3, 4, \
			1, 2, 2, 2, \
			1, 1, 4, 1)
			world << "mat"
			mat.print()


			var/matrix4/mat2 = new \
			(4, 2, 2, 2, \
			1, 2, 3, 4, \
			1, 2, 3, 4, \
			4, 2, 1, 1)

			world << "mat2"
			mat2.print()

			world << "mat1 x mat2"
			var/matrix4/res = mat.multiply(mat2)

			res.print()

			var/vector4/v = new \
			(1, \
			1, \
			1, \
			1)

			var/vector4/vres = mat.multiply(v)

			vres.print()

			//0, 3, -1	//front of orthographic box
			var/vertex/v1 = new(0, 0, -1)

			src << "sample vertex:"
			v1.position.print(1)

			//orthographic box
			var/l = -3
			var/r = 3
			var/t = 3
			var/b = -3
			var/n = -1
			var/f = -3

			//origin
			var/matrix4/ortho_translate = new \
			(1, 0, 0, (l + r) / -2, \
			0, 1, 0, (b + t) / -2, \
			0, 0, 1, (n + f) / -2, \
			0, 0, 0, 1)

			src << "ortho translate:"
			ortho_translate.print()



			//scale
			var/matrix4/ortho_scale = new \
			(2 / (r - l), 0, 0, 0, \
			0, 2 / (t - b), 0, 0, \
			0, 0, 2 / (n - f), 0, \
			0, 0, 0, 1)

			src << "ortho scale:"
			ortho_scale.print()

			src << "ortho transform:"
			var/matrix4/ortho_transform = ortho_scale.multiply(ortho_translate)
			ortho_transform.print()

			//map to canonical
			var/vector4/pos1 = ortho_translate.multiply(v1.position)
			var/vector4/pos2 = ortho_scale.multiply(pos1)

			src << "orthographic x vertex"
			pos2.print(1)

			//ASSERT(pos2.get_x() == 0 && pos2.get_y() == 1 && pos2.get_z() == 1)

			//screen
			//640x640
			var/nx = world.maxx * world.icon_size
			var/ny = world.maxy * world.icon_size

			world << world.maxx
			world << world.maxy
			world << world.icon_size

			var/matrix4/screen_transform = new \
			(nx / 2, 0, 0, (nx - 1) / 2, \
			0, ny / 2, 0, (ny - 1) / 2, \
			0, 0, 1, 0, \
			0, 0, 0, 1)

			var/vector4/screen_pos = screen_transform.multiply(pos2)

			src << "screen coord: [screen_pos.get_x()]:[screen_pos.get_y()]"
			draw_point(screen_pos.get_x(), screen_pos.get_y())

		draw_cube()
			var/list/vertices = list()
			//front
			vertices += new /vertex(1, 1, -1)
			vertices += new /vertex(-1, 1, -1)
			vertices += new /vertex(1, -1, -1)
			vertices += new /vertex(-1, -1, -1)

			vertices += new /vertex(1, 1, 1)
			vertices += new /vertex(-1, 1, 1)
			vertices += new /vertex(1, -1, 1)
			vertices += new /vertex(-1, -1, 1)

			vertices += new /vertex(0, 0, 0)

			project_vertices(vertices)


	proc
		project_vertices(list/vertices)
			//orthographic box
			var/l = -3
			var/r = 3
			var/t = 3
			var/b = -3
			var/n = -1
			var/f = -3

			//origin
			var/matrix4/ortho_translate = new \
			(1, 0, 0, (l + r) / -2, \
			0, 1, 0, (b + t) / -2, \
			0, 0, 1, (n + f) / -2, \
			0, 0, 0, 1)

			var/matrix4/ortho_scale = new \
			(2 / (r - l), 0, 0, 0, \
			0, 2 / (t - b), 0, 0, \
			0, 0, 2 / (n - f), 0, \
			0, 0, 0, 1)

			var/matrix4/ortho_transform = ortho_scale.multiply(ortho_translate)

			var/nx = world.maxx * world.icon_size
			var/ny = world.maxy * world.icon_size

			var/matrix4/window_transform = new \
			(nx / 2, 0, 0, (nx - 1) / 2, \
			0, ny / 2, 0, (ny - 1) / 2, \
			0, 0, 1, 0, \
			0, 0, 0, 1)

			var/matrix4/screen_transform = window_transform.multiply(ortho_transform)

			for(var/vertex/v in vertices)
				var/vector4/screen_pos = screen_transform.multiply(v.position)
				draw_point(screen_pos.get_x(), screen_pos.get_y())

		draw_point(x, y)
			//does not account if another point with the same coordinate already exists
			//new
			var/obj/O = new
			O.screen_loc = "1,1"
			screen += O

			O.transform = matrix(x, y, MATRIX_TRANSLATE)

			src << "draw point at [x]:[y]"

