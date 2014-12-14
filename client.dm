client
	var
		matrix/transform
		list/vertices
		camera/camera
		is_moving
		#ifdef HAS_CANVAS
		Canvas/canvas
		obj/anchor_obj
		#endif
		angle = 0
		list/z_buffer[world.icon_size * world.maxx][world.icon_size * world.maxy]
		light/light

	verb
		frame_spin()

			var/x = 0
			var/y = 0
			var/z = -2

			var/matrix4/center_transform = new \
			(1, 0, 0, x, \
			0, 1, 0, y, \
			0, 0, 1, z, \
			0, 0, 0, 1)

			var/matrix4/origin_transform = new \
			(1, 0, 0, -1 * x, \
			0, 1, 0, -1 * y, \
			0, 0, 1, -1 * z, \
			0, 0, 0, 1)

			var/angle = 5

			var/matrix4/rotate_transform = new \
			(cos(angle), 0, sin(angle), 0, \
			0, 1, 0, 0, \
			-1 * sin(angle), 0, cos(angle), 0, \
			0, 0, 0, 1)

			var/matrix4/model_transform = center_transform.multiply(rotate_transform.multiply(origin_transform))

			for(var/vertex/v in vertices)
				v.position = model_transform.multiply(v.position)

			project_vertices(vertices, 1, 1)


		generate_spinning_triangle()
			var/icon/cache = icon()
			cache.Scale(320, 320)

			ortho_triangle()

			//prevent "reversal"
			move_back()

			var/x = 0
			var/y = 0
			var/z = -2

			var/matrix4/center_transform = new \
			(1, 0, 0, x, \
			0, 1, 0, y, \
			0, 0, 1, z, \
			0, 0, 0, 1)

			var/matrix4/origin_transform = new \
			(1, 0, 0, -1 * x, \
			0, 1, 0, -1 * y, \
			0, 0, 1, -1 * z, \
			0, 0, 0, 1)

			var/angle = 5

			var/matrix4/rotate_transform = new \
			(cos(angle), 0, sin(angle), 0, \
			0, 1, 0, 0, \
			-1 * sin(angle), 0, cos(angle), 0, \
			0, 0, 0, 1)

			var/matrix4/model_transform = center_transform.multiply(rotate_transform.multiply(origin_transform))

			var/frame = 1
			var/t
			var/elapsed
			var/total_frame = round(360 / angle)
			//one complete rotation
			while(frame <= total_frame)
				t = world.timeofday
				for(var/vertex/v in vertices)
					v.position = model_transform.multiply(v.position)

				project_vertices(vertices, 1, 1)

				fcopy(canvas.work_icon, "frames/frame[frame].dmi")
				cache.Insert(icon(canvas.work_icon), frame=frame)

				elapsed = world.timeofday - t
				src << "generated frame [frame] of [total_frame] (took [elapsed / 10] s)"

				frame++

				sleep(elapsed)
				//sleep(world.tick_lag)

			src << "replay started..."
			clear_screen()

			var/obj/O = new
			O.icon = cache
			O.screen_loc = "1,1"
			screen += O

			fcopy(cache, "anim.dmi")


		new_pyramid()
			vertices = list()

			//red front
			vertices += new /vertex(0, 1, 0, "#f00")
			vertices += new /vertex(-1, 0, 1, "#f00")
			vertices += new /vertex(1, 0, 1, "#f00")

			//right green
			vertices += new /vertex(0, 1, 0, "#0f0")
			vertices += new /vertex(1, 0, 1, "#0f0")
			vertices += new /vertex(0, 0, -1, "#0f0")

			//left blue
			vertices += new /vertex(0, 1, 0, "#00f")
			vertices += new /vertex(-1, 0, 1, "#00f")
			vertices += new /vertex(0, 0, -1, "#00f")

			//white base
			vertices += new /vertex(-1, 0, 1, "#fff")
			vertices += new /vertex(1, 0, 1, "#fff")
			vertices += new /vertex(0, 0, -1, "#fff")

			var/matrix4/translate = new \
			(1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, -2,
			0, 0, 0, 1)

			for(var/vertex/v in vertices)
				v.position = translate.multiply(v.position)

			project_vertices(vertices, 1, 1)

		translate_pyramid()
			var/matrix4/translate = new \
			(1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, -0.1,
			0, 0, 0, 1)

			for(var/vertex/v in vertices)
				v.position = translate.multiply(v.position)

			project_vertices(vertices, 1, 1)

		remove_light()
			light = null
			project_vertices(vertices, 1, 1)

		apply_white_light()
			//directional light
			if(!light)
				light = new
				light.direction = new(0, 1, 1)

			light.intensity = "#fff"

			project_vertices(vertices, 1, 1)

		apply_red_light()
			if(!light)
				light = new
				light.direction = new(0, 1, 1)

			light.intensity = "#f00"

			project_vertices(vertices, 1, 1)

		apply_green_light()
			if(!light)
				light = new
				light.direction = new(0, 1, 1)

			light.intensity = "#0f0"

			project_vertices(vertices, 1, 1)

		apply_blue_light()
			if(!light)
				light = new
				light.direction = new(0, 1, 1)

			light.intensity = "#00f"

			project_vertices(vertices, 1, 1)

		apply_black_light()
			if(!light)
				light = new
				light.direction = new(0, 1, 1)

			light.intensity = "#000"

			project_vertices(vertices, 1, 1)

		ortho_triangle()
			vertices = list()

			vertices += new /vertex(0, 1, -2, "#f00")
			vertices += new /vertex(-1, 0, -2, "#0f0")
			vertices += new /vertex(1, 0, -2, "#00f")


			if(!camera)
				camera = new
				camera.eye = new(0, 0, 2.6)
				camera.gaze = new(0, 0, 1)

			//assign normals
			var/vector3/normal = new(0, 0, 1)
			for(var/vertex/v in vertices)
				v.normal = normal.copy()

			project_vertices(vertices, 1, 1)

		move_back()
			camera.eye = camera.eye.add(camera.gaze.multiply(0.5))

			project_vertices(vertices, 1, 1)

		camera_info()
			if(!camera)
				return

			camera.eye.print()
			camera.gaze.print()
			camera.up.print()

		new_textured_pyramid()
			vertices = list()

			var/material/m = new(icon('texture.dmi'))

			//red front
			vertices += new /vertex(0, 1, 0, m, 0, 0)
			vertices += new /vertex(-1, 0, 1, m, 1, 0)
			vertices += new /vertex(1, 0, 1, m, 0, 1)

			//right green
			vertices += new /vertex(0, 1, 0, m, 0, 0)
			vertices += new /vertex(1, 0, 1, m, 1, 0)
			vertices += new /vertex(0, 0, -1, m, 0, 1)

			//left blue
			vertices += new /vertex(0, 1, 0, m, 0, 0)
			vertices += new /vertex(-1, 0, 1, m, 1, 0)
			vertices += new /vertex(0, 0, -1, m, 0, 1)

			//white base
			vertices += new /vertex(-1, 0, 1, m, 0, 0)
			vertices += new /vertex(1, 0, 1, m, 1, 0)
			vertices += new /vertex(0, 0, -1, m, 0, 1)

			var/matrix4/translate = new \
			(1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, -2,
			0, 0, 0, 1)

			for(var/vertex/v in vertices)
				v.position = translate.multiply(v.position)

			project_vertices(vertices, 1, 1)

		draw_vertices_with_view()
			project_vertices(vertices, 1)

		clear_screen()
			screen = null
			#ifdef HAS_CANVAS
			if(canvas)
				canvas.clear()
			#endif

		set_eye_position(x as num, y as num, z as num)
			camera.eye.set_x(x)
			camera.eye.set_y(y)
			camera.eye.set_z(z)

			project_vertices(vertices, 1, 1)

		up()
			camera.eye = camera.eye.add(camera.up)
			project_vertices(vertices, 1, 1)

		down()
			camera.eye = camera.eye.add(camera.up.multiply(-1))
			project_vertices(vertices, 1, 1)

		sidestep_left()
			//gaze x up
			var/vector3/left = camera.gaze.cross(camera.up)
			left.normalize()

			//step size
			camera.eye = camera.eye.add(left.multiply(0.1))

			project_vertices(vertices, 1)

		sidestep_right()
			var/vector3/right = camera.up.cross(camera.gaze)
			right.normalize()

			camera.eye = camera.eye.add(right.multiply(0.1))

			project_vertices(vertices, 1)

		continuously_move_forward()
			is_moving = 1
			while(is_moving)
				camera.eye = camera.eye.add(camera.gaze.multiply(-0.1))

				project_vertices(vertices, 1)

				sleep(10)

		gaze_right()
			var/x = camera.gaze.get_x() + 0.1
			camera.gaze.set_x(x)
			project_vertices(vertices, 1)

		stop()
			is_moving = 0

		move_backward()
			camera.eye = camera.eye.add(camera.gaze)
			project_vertices(vertices, 1, 1)

		move_cube_about_origin()

			if(!vertices || !vertices.len || is_moving)
				return

			//reposition camera
			if(!camera)
				camera = new

			camera.eye = new /vector3(0, 3, 4)
			camera.gaze = camera.eye.multiply(-1)

			is_moving = 1
			angle = 5
			while(is_moving)
				var/matrix4/rotate_transform = new \
				(cos(angle), 0, sin(angle), 0, \
				0, 1, 0, 0, \
				-1 * sin(angle), 0, cos(angle), 0, \
				0, 0, 0, 1)

				for(var/vertex/v in vertices)
					v.position = rotate_transform.multiply(v.position)

				project_vertices(vertices, 1)
				//angle += 0.05
				sleep(world.tick_lag)

		look_from_right_side()
			if(!camera)
				return

			camera.eye = new(2, 0, 0)
			camera.gaze = new(-1, 0, 0)

			project_vertices(vertices, 1, 1)

		look_from_an_angle()
			if(!camera)
				return

			camera.eye = camera.eye.add(new /vector3(0, 2, 0))
			camera.gaze = camera.eye.multiply(-1)

			project_vertices(vertices, 1, 1)

		look_closer()
			if(!camera)
				return

			//-ve z
			camera.eye = camera.eye.add(camera.gaze.multiply(-0.1))

			project_vertices(vertices, 1, 1)


	proc
		draw_triangle(xa, ya, za, h0, vertex/va, xb, yb, zb, h1, vertex/vb, xc, yc, zc, h2, vertex/vc)
			//should have at least 1 area
			if(round(abs((xa * yb + xb * yc + xc * ya - xa * yc - xb * ya - xc * yb) * 0.5)))
				src << "area: [round((xa * yb + xb * yc + xc * ya - xa * yc - xb * ya - xc * yb) * 0.5)]"

				var/list/va_rgb = ReadRGB(va.rgb || "#fff")
				var/list/vb_rgb = ReadRGB(vb.rgb || "#fff")
				var/list/vc_rgb = ReadRGB(vc.rgb || "#fff")

				src << "vertex color: [va.rgb], [vb.rgb], [vc.rgb]"

				ASSERT((ya - yb) * xc + (xb - xa) * yc + xa * yb - xb * ya)

				for(var/x = 1 to world.maxx * world.icon_size)
					for(var/y = 1 to world.maxy * world.icon_size)
						var/gamma = ((ya - yb) * x + (xb - xa) * y + xa * yb - xb * ya) \
									/\
									((ya - yb) * xc + (xb - xa) * yc + xa * yb - xb * ya)

						var/beta = ((ya - yc) * x + (xc - xa) * y + xa * yc - xc * ya) \
									/\
									((ya - yc) * xb + (xc - xa) * yb + xa * yc - xc * ya)

						var/alpha = 1 - beta - gamma

						if((alpha in 0 to 1) && (beta in 0 to 1) && (gamma in 0 to 1))
							var/z = alpha * za + beta * zb + gamma * zc

							if(!z_buffer[x][y] || z >= z_buffer[x][y])
								z_buffer[x][y] = z

								var/d = h1 * h2 + h2 * beta * (h0 - h1) + h1 * gamma * (h0 - h2)

								var/beta_w = h0 * h2 * beta / d
								var/gamma_w = h0 * h1 * gamma / d
								var/alpha_w = 1 - beta_w - gamma_w

								alpha = alpha_w
								beta = beta_w
								gamma = gamma_w

								var/reflectance
								var/rgb
								if(va.material)

									var/u = alpha * va.tex_coord[1] + beta * vb.tex_coord[1] + gamma * vc.tex_coord[1]
									var/v = alpha * va.tex_coord[2] + beta * vb.tex_coord[2] + gamma * vc.tex_coord[2]

									ASSERT(u in 0 to 1 && v in 0 to 1)

									reflectance = va.material.tex.GetPixel(va.material.tex.Width() * u, va.material.tex.Height() * v)

								else
									var/rr = alpha * va_rgb[1] + beta * vb_rgb[1] + gamma * vc_rgb[1]
									var/gg = alpha * va_rgb[2] + beta * vb_rgb[2] + gamma * vc_rgb[2]
									var/bb = alpha * va_rgb[3] + beta * vb_rgb[3] + gamma * vc_rgb[3]

									reflectance = rgb(rr, gg, bb)

								if(light)
									//diffuse shading
									var/list/rgb_reflectance = ReadRGB(reflectance)
									var/r = rgb_reflectance[1] / 255
									var/g = rgb_reflectance[2] / 255
									var/b = rgb_reflectance[3] / 255

									var/list/rgb_intensity = ReadRGB(light.intensity)
									for(var/i = 1 to rgb_intensity.len)
										rgb_intensity[i] /= 255

									var/rr = 255 * (r * rgb_intensity[1] * max(0, va.normal.dot(light.direction)))
									var/gg = 255 * (g * rgb_intensity[2] * max(0, va.normal.dot(light.direction)))
									var/bb = 255 * (b * rgb_intensity[3] * max(0, va.normal.dot(light.direction)))

									rgb = rgb(rr, gg, bb)
								else
									rgb = reflectance

								//set pixel
								draw_point(x, y, rgb)
								#ifndef HAS_CANVAS
								sleep(1)
								#endif


		clear_z_buffer()
			for(var/x = 1 to world.icon_size * world.maxx)
				for(var/y = 1 to world.icon_size * world.maxy)
					z_buffer[x][y] = null

		add_cube(vector4/center, project)
			var/list/vertices = list()

			var/matrix4/offset = new \
			(1, 0, 0, center.get_x(), \
			0, 1, 0, center.get_y(), \
			0, 0, 1, center.get_z() + 2, \
			0, 0, 0, 1)

			//front plane
			vertices += new /vertex(-1, 1, -1)
			vertices += new /vertex(1, 1, -1)
			vertices += new /vertex(1, 1, -1)
			vertices += new /vertex(1, -1, -1)
			vertices += new /vertex(1, -1, -1)
			vertices += new /vertex(-1, -1, -1)
			vertices += new /vertex(-1, -1, -1)
			vertices += new /vertex(-1, 1, -1)

			//side
			vertices += new /vertex(-1, 1, -1)
			vertices += new /vertex(-1, 1, -3)
			vertices += new /vertex(1, 1, -1)
			vertices += new /vertex(1, 1, -3)
			vertices += new /vertex(1, -1, -1)
			vertices += new /vertex(1, -1, -3)
			vertices += new /vertex(-1, -1, -1)
			vertices += new /vertex(-1, -1, -3)

			//back plane
			vertices += new /vertex(-1, 1, -3)
			vertices += new /vertex(1, 1, -3)
			vertices += new /vertex(1, 1, -3)
			vertices += new /vertex(1, -1, -3)
			vertices += new /vertex(1, -1, -3)
			vertices += new /vertex(-1, -1, -3)
			vertices += new /vertex(-1, -1, -3)
			vertices += new /vertex(-1, 1, -3)

			//offset
			for(var/vertex/v in vertices)
				v.position = offset.multiply(v.position)

			if(project)
				project_vertices(vertices, 1)

			return vertices

		project_vertices(list/vertices, apply_view, depth_test, skip_update=0)
			clear_screen()

			var/matrix4/view_transform = null

			if(apply_view)
				if(!camera)
					camera = new
				if(!camera.eye)
					camera.eye = new(0, 0, 2.6)
				var/vector3/e = camera.eye
				//src << "eye:"
				//e.print()
				if(!camera.gaze)
					camera.gaze = new(0, 0, 1)
				var/vector3/g = camera.gaze

				if(!camera.up)
					camera.up = new(0, 1, 0)

				var/vector3/t = camera.up

				//uvw
				var/vector3/w = g.multiply(-1)
				w.normalize()
				//src << "w-axis:"
				//w.print()

				var/vector3/u = t.cross(w)
				u.normalize()
				//src << "u-axis:"
				//u.print()

				var/vector3/v = w.cross(u)
				//src << "v-axis:"
				//v.print()

				//view
				var/matrix4/view_translate = new \
				(1, 0, 0, e.get_x(), \
				0, 1, 0, e.get_y(), \
				0, 0, 1, e.get_z(), \
				0, 0, 0, 1)

				var/matrix4/view_scale = new \
				(u.get_x(), u.get_y(), u.get_z(), 0, \
				v.get_x(), v.get_y(), v.get_z(), 0, \
				w.get_x(), w.get_y(), w.get_z(), 0, \
				0, 0, 0, 1)

				view_transform = view_scale.multiply(view_translate)
				//src << "view"
				//view_transform.print()

			//orthographic box
			var/l = -3
			var/r = 3
			var/t = 3
			var/b = -3
			var/n = -1
			var/f = -3

			//perspective
			var/matrix4/perspective2 = new \
			(1, 0, 0, 0, \
			0, 1, 0, 0, \
			0, 0, (n + f) / n, -f, \
			0, 0, 1 / n, 0)


			var/matrix4/perspective = new \
			(n, 0, 0, 0, \
			0, n, 0, 0, \
			0, 0, (n + f), -f * n, \
			0, 0, 1, 0)


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

			//src << "screen"
			//var/matrix4/screen_transform = window_transform.multiply(ortho_transform.multiply(perspective.multiply(view_transform)))
			var/matrix4/screen_transform = window_transform.multiply(perspective.multiply(view_transform))
			//screen_transform.print()
			var/matrix4/test = ortho_transform.multiply(perspective)
			//src << "composite"
			//test.print()
			//src << "projection"
			var/matrix4/projection = new \
			(2 * n / (r - l), 0, (l + r) / (l - r), 0, \
			0, 2 * n / (t - b), (b + t) / (b - t), 0, \
			0, 0, (f + n) / (n - f), 2 * f * n / (f - n),
			0, 0, 1, 0)
			//projection.print()

			ASSERT(test.equals(projection))
			screen_transform = window_transform.multiply(projection.multiply(view_transform))
			//screen_transform.print()

			if(depth_test)
				for(var/i = 1; i <= vertices.len; i += 3)
					if(i + 2 > vertices.len)
						return
					var/vertex/v1 = vertices[i]
					var/vector4/p1 = screen_transform.multiply(v1.position)
					var/vertex/v2 = vertices[i + 1]
					var/vector4/p2 = screen_transform.multiply(v2.position)
					var/vertex/v3 = vertices[i + 2]
					var/vector4/p3 = screen_transform.multiply(v3.position)

					var/h1 = p1.homogenize()
					var/h2 = p2.homogenize()
					var/h3 = p3.homogenize()

					draw_triangle(
					p1.get_x(), p1.get_y(), p1.get_z(), h1, v1, \
					p2.get_x(), p2.get_y(), p2.get_z(), h2, v2, \
					p3.get_x(), p3.get_y(), p3.get_z(), h3, v3, \
					)

					src << "draw triangle ([p1.get_x()],[p1.get_y()]) ([p2.get_x()],[p2.get_y()]) ([p3.get_x()],[p3.get_y()])"

			else

				for(var/vertex/v in vertices)
					var/vector4/screen_pos = screen_transform.multiply(v.position)
					screen_pos.homogenize()

					//src << "xyz [v.position.get_x()], [v.position.get_y()], [v.position.get_z()] => uvw: [uvw.get_x()], [uvw.get_y()], [uvw.get_z()]"
					draw_point(screen_pos.get_x(), screen_pos.get_y(), v.rgb)

				for(var/i = 1; i <= vertices.len; i += 2)
					if(i + 1 > vertices.len)
						return
					var/vertex/v1 = vertices[i]
					var/vector4/p1 = screen_transform.multiply(v1.position)
					var/vertex/v2 = vertices[i + 1]
					var/vector4/p2 = screen_transform.multiply(v2.position)
					p1.homogenize()
					p2.homogenize()
					draw_line(p1.get_x(), p1.get_y(), p2.get_x(), p2.get_y())

			if(!skip_update)
				update_screen()

		update_screen()
			clear_z_buffer()
			#ifdef HAS_CANVAS
			canvas.update()
			#endif

		draw_point(x, y, rgb, instant_update)
			#ifdef HAS_CANVAS

			rgb = rgb || rgb(255, 255, 255)
			if(!anchor_obj)
				anchor_obj = new(locate(1, 1, 1))
			if(!canvas)
				canvas = new(anchor_obj, 320, 320, rgb(0, 0, 0))
			canvas.drawPixel(x, y, rgb)

			#else
			//does not account if another point with the same coordinate already exists
			//new
			var/obj/O = new
			O.screen_loc = "1,1"
			screen += O

			O.transform = matrix(x, y, MATRIX_TRANSLATE)
			O.color = null
			O.color = rgb

			#endif

			if(instant_update)
				update_screen()

			//src << "draw point at [x]:[y]"

		draw_line(x0, y0, x1, y1, instant_update)
			#ifdef HAS_CANVAS
			if(!anchor_obj)
				anchor_obj = new(locate(1, 1, 1))
			if(!canvas)
				canvas = new(anchor_obj, 320, 320, rgb(0, 0, 0))

			canvas.drawLine(x0, y0, x1, y1, rgb(255, 255, 255), 1)
			#endif

			if(instant_update)
				update_screen()

			//src << "draw line: ([x0],[y0]) - ([x1],[y1])"





