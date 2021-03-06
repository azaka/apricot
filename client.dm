world
	New()

		//log = file("log.txt")
		return ..()


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
		perspective_correction = 1
		fov
		obj_loader/obj_loader

	Stat()
		if(vertices)

			var/i = 1
			for(var/vertex/v in vertices)
				stat("vertex #[i] (world space)", v.position.string())
				if(v.clip_position)
					stat("vertex #[i] (clip space)", v.clip_position.string())
				if(v.normal)
					stat("vertex #[i] (normal)", v.normal.string())
				i++

		if(!camera)
			return ..()

		stat("camera (position)", camera.eye.string())
		stat("camera (gaze dir)", camera.gaze.string())
		stat("camera (up dir)", camera.up.string())
		stat("perspective correction", perspective_correction)
		stat("fov", fov)


	verb
		import_obj(f as file)
			set category = "World"

			if(f)
				if(!obj_loader)
					obj_loader = new

				var/list/result = obj_loader.load(f)

				src << "loaded [result.len / 3] polys"

				vertices = result

				if(!camera)
					camera = new

				camera.eye = new(3, 3, 3)
				look_at(0, 0, -2, 0)

				camera.eye = camera.eye.add(camera.gaze.multiply(3))

				set_intensity(rgb(100, 100, 100))

		toggle_perspective_correction()
			set category = "Camera"

			perspective_correction = 1 - perspective_correction
			src << perspective_correction

			project_vertices(vertices, 1, 1)

		generate_rotation()
			set category = "Model Transform"

			if(!vertices || !vertices.len)
				return

			var/icon/cache = icon()
			cache.Scale(320, 320)

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

			var/matrix4/normal_transform = model_transform.copy()
			normal_transform = normal_transform.inverse()
			normal_transform = normal_transform.transpose()

			var/frame = 1
			var/t
			var/elapsed
			var/total_frame = round(360 / angle)
			//one complete rotation
			var/vector4/n = new
			while(frame <= total_frame)
				t = world.timeofday
				for(var/vertex/v in vertices)
					v.position = model_transform.multiply(v.position)
					if(v.normal)
						n = normal_transform.multiply(new /vector4(v.normal, 0))
						v.normal = new(n.get_x(), n.get_y(), n.get_z())

				project_vertices(vertices, 1, 1)

				fcopy(canvas.work_icon, "frames/frame[frame].dmi")
				cache.Insert(icon(canvas.work_icon), frame=frame)

				elapsed = world.timeofday - t
				src << "generated frame [frame] of [total_frame] (took [elapsed / 10] s)"

				frame++

				//sleep(10)
				sleep(world.tick_lag)

			src << "replay started..."
			clear_screen()

			var/obj/O = new
			O.icon = cache
			O.screen_loc = "1,1"
			screen += O

			fcopy(cache, "anim.dmi")

		translate(x as num, y as num, z as num)
			set category = "Model Transform"

			var/matrix4/translate = new \
			(1, 0, 0, x,
			0, 1, 0, y,
			0, 0, 1, z,
			0, 0, 0, 1)

			for(var/vertex/v in vertices)
				v.position = translate.multiply(v.position)

			project_vertices(vertices, 1, 1)

		off()
			set category = "Light"

			light = null
			project_vertices(vertices, 1, 1)

		on(rgb as color)
			set category = "Light"

			//directional light
			if(!light)
				light = new
				light.direction = new(0, 1, 1)
				light.intensity = rgb

			project_vertices(vertices, 1, 1)

		set_intensity(rgb as color)
			set category = "Light"

			//directional light
			if(!light)
				light = new
				light.direction = new(0, 1, 1)

			light.intensity = rgb

			project_vertices(vertices, 1, 1)

		info()
			set category = "Camera"

			if(!camera)
				return

			camera.eye.print()
			camera.gaze.print()
			camera.up.print()

		empty()
			set category = "World"

			vertices = list()

		clear_screen()
			screen = null
			#ifdef HAS_CANVAS
			if(canvas)
				canvas.clear()
			#endif

		set_position(x as num, y as num, z as num)
			set category = "Camera"

			camera.eye = new(x, y, z)

			project_vertices(vertices, 1, 1)

		sidestep_left()
			set category = "Camera"

			//gaze x up
			var/vector3/left = camera.gaze.cross(camera.up)
			left.normalize()

			//step size
			camera.eye = camera.eye.add(left.multiply(0.1))

			project_vertices(vertices, 1)

		sidestep_right()
			set category = "Camera"

			var/vector3/right = camera.up.cross(camera.gaze)
			right.normalize()

			camera.eye = camera.eye.add(right.multiply(0.1))

			project_vertices(vertices, 1)

		up()
			set category = "Camera"

			camera.eye = camera.eye.add(camera.up)
			project_vertices(vertices, 1, 1)

		forward()
			set category = "Camera"

			camera.eye = camera.eye.add(camera.gaze)
			project_vertices(vertices, 1, 1)

		back()
			set category = "Camera"

			camera.eye = camera.eye.add(camera.gaze.multiply(-1))
			project_vertices(vertices, 1, 1)

		look_at(x as num, y as num, z as num, update=1 as num)
			set category = "Camera"

			if(!camera)
				return

			var/vector3/center = new(x, y, z)
			camera.gaze = center.subtract(camera.eye)
			camera.gaze.normalize()

			//gaze and world up is coplanar
			var/vector3/right = camera.gaze.cross(new /vector3(0, 1, 0))

			camera.up = right.cross(camera.gaze)

			if(update)
				project_vertices(vertices, 1, 1)

		set_ambience(rgb as color)
			set category = "Camera"

			if(!camera)
				return

			camera.ambience = rgb

			if(light)
				project_vertices(vertices, 1, 1)

		load_data(f as file)
			set category = "World"

			if(!f)
				return

			if(!vertices)
				vertices = list()

			var/list/lines = dd_file2list(f)
			var/offset = vertices.len + 1


			#define DATA_TYPE_VERTEX			1
			#define DATA_TYPE_CAMERA_POSITION	2
			#define DATA_TYPE_LOOKAT			3
			#define DATA_TYPE_MATERIAL			4

			var/list/materials = list()

			var/data_type = DATA_TYPE_VERTEX

			for(var/line in lines)
				//comment
				if(findtext(line, "#", 1, 2))
					continue

				//camera position
				if(findtext(line, "!position", 1, 10))
					data_type = DATA_TYPE_CAMERA_POSITION
					continue

				//camera lookat
				if(findtext(line, "!lookat", 1, 8))
					data_type = DATA_TYPE_LOOKAT
					continue

				//material
				if(findtext(line, "!material", 1, 10))
					data_type = DATA_TYPE_MATERIAL
					continue

				//process data
				var/list/data = dd_text2list(line, ",")
				if(data.len < 3 && data_type != DATA_TYPE_MATERIAL)
					continue

				switch(data_type)
					if(DATA_TYPE_MATERIAL)
						if(data.len)
							var/fname = data[1]
							if(istext(fname))
								materials += new/material(icon(file(fname)))

						data_type = DATA_TYPE_VERTEX

						continue
					if(DATA_TYPE_LOOKAT)
						if(!camera)
							camera = new
							camera.gaze = new(0, 0, -1)
							camera.eye = new

						var/x = text2num(data[1])
						var/y = text2num(data[2])
						var/z = text2num(data[3])

						if(!isnum(x) || !isnum(y) || !isnum(z))
							continue

						look_at(x, y, z, 0)
						data_type = DATA_TYPE_VERTEX

						continue

					if(DATA_TYPE_CAMERA_POSITION)
						if(!camera)
							camera = new
							camera.gaze = new(0, 0, -1)
							camera.eye = new

						var/x = text2num(data[1])
						var/y = text2num(data[2])
						var/z = text2num(data[3])

						if(!isnum(x) || !isnum(y) || !isnum(z))
							continue

						camera.eye.set_x(x)
						camera.eye.set_y(y)
						camera.eye.set_z(z)

						data_type = DATA_TYPE_VERTEX
						continue

					if(DATA_TYPE_VERTEX)
						var/list/vertex_data = data

						var/list/params = list()

						params += text2num(vertex_data[1])
						params += text2num(vertex_data[2])
						params += text2num(vertex_data[3])

						if(vertex_data.len > 3)
							if(isnum(text2num(vertex_data[4])))
								params += materials[text2num(vertex_data[4])]
								params += text2num(vertex_data[5])
								params += text2num(vertex_data[6])
								offset = 2
							else if(istext(vertex_data[4]))
								var/rgb = vertex_data[4]
								var/index = 0
								while(findtext(rgb, " ", ++index, index + 1))
								rgb = copytext(rgb, index)

								params += rgb
								offset = 0

						var/vertex/v = new /vertex(arglist(params))
						vertices += v

						if(vertex_data.len > 4 + offset)
							var/nx = text2num(vertex_data[5 + offset])
							var/ny = text2num(vertex_data[6 + offset])
							var/nz = text2num(vertex_data[7 + offset])

							v.normal = new(nx, ny, nz)




			#undef DATA_TYPE_VERTEX
			#undef DATA_TYPE_CAMERA_POSITION
			#undef DATA_TYPE_LOOKAT
			#undef DATA_TYPE_MATERIAL

			project_vertices(vertices, 1, 1)



		add(x as num, y as num, z as num, rgb as color)
			set category = "World"

			if(!vertices)
				vertices = list()

			vertices += new /vertex(x, y, z, rgb)

			project_vertices(vertices, 1, 1)

	proc
		draw_triangle(xa, ya, za, h0, vertex/va, xb, yb, zb, h1, vertex/vb, xc, yc, zc, h2, vertex/vc)
			//should have at least 1 area
			if(round(abs((xa * yb + xb * yc + xc * ya - xa * yc - xb * ya - xc * yb) * 0.5)))
				//src << "area: [round((xa * yb + xb * yc + xc * ya - xa * yc - xb * ya - xc * yb) * 0.5)]"

				var/list/va_rgb = ReadRGB(va.rgb || "#fff")
				var/list/vb_rgb = ReadRGB(vb.rgb || "#fff")
				var/list/vc_rgb = ReadRGB(vc.rgb || "#fff")

				//src << "vertex color: [va.rgb], [vb.rgb], [vc.rgb]"

				ASSERT((ya - yb) * xc + (xb - xa) * yc + xa * yb - xb * ya)

				var/vector3/normal = new
				var/vector3/avg_normal = null
				var/list/rgb_intensity = null
				var/list/rgb_ambience = null
				var/ar
				var/ag
				var/ab
				var/vector3/light_dir = null
				var/lambertian

				if(light)
					avg_normal = vc.normal.add(vb.normal.add(va.normal))
					avg_normal.normalize()

					rgb_intensity = ReadRGB(light.intensity)
					for(var/i = 1 to rgb_intensity.len)
						rgb_intensity[i] /= 255


					rgb_ambience = ReadRGB(camera.ambience)
					ar = rgb_ambience[1] / 255
					ag = rgb_ambience[2] / 255
					ab = rgb_ambience[3] / 255

					light_dir = light.direction.copy()
					light_dir.normalize()

					lambertian = max(0, avg_normal.dot(light.direction))


				var/minx = min(xa, xb, xc)
				var/maxx = max(xa, xb, xc)
				var/miny = min(ya, yb, yc)
				var/maxy = max(ya, yb, yc)

				var/matrix4/map = new
				if(va.material)
					map.make_identity()
					map.scale(va.material.tex.Width() - 1, va.material.tex.Height() - 1, 1)
					map.translate(1, 1, 0)

				for(var/x = round(minx) to round(maxx))
					for(var/y = round(miny) to round(maxy))
						var/gamma = ((ya - yb) * x + (xb - xa) * y + xa * yb - xb * ya) \
									/\
									((ya - yb) * xc + (xb - xa) * yc + xa * yb - xb * ya)

						var/beta = ((ya - yc) * x + (xc - xa) * y + xa * yc - xc * ya) \
									/\
									((ya - yc) * xb + (xc - xa) * yb + xa * yc - xc * ya)

						var/alpha = 1 - beta - gamma

						if((alpha in 0 to 1) && (beta in 0 to 1) && (gamma in 0 to 1))
							var/z = alpha * za + beta * zb + gamma * zc

							ASSERT(x in 0 to world.icon_size * world.maxx)
							ASSERT(y in 0 to world.icon_size * world.maxy)

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

									var/vector4/pixel = map.multiply(new /vector4(u, v, 0, 1))


									var/px = pixel.get_x()
									var/py = pixel.get_y()

									reflectance = va.material.tex.GetPixel(px, py)

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

									//world.log << "light direction: [light_dir.string()]"

									var/vector4/position = new
									position.set_x(alpha * va.position.get_x() + beta * vb.position.get_x() + gamma * vc.position.get_x())
									position.set_y(alpha * va.position.get_y() + beta * vb.position.get_y() + gamma * vc.position.get_y())
									position.set_z(alpha * va.position.get_z() + beta * vb.position.get_z() + gamma * vc.position.get_z())

									var/vector3/position3 = new(position)

									var/vector3/highlight = light_dir.add(position3.multiply(-1))
									highlight.normalize()

									//world.log << "highlight direction: [highlight.string()]"

									var/phong = 32
									normal.set_x(alpha * va.normal.get_x() + beta * vb.normal.get_x() + gamma * vc.normal.get_x())
									normal.set_y(alpha * va.normal.get_y() + beta * vb.normal.get_y() + gamma * vc.normal.get_y())
									normal.set_z(alpha * va.normal.get_z() + beta * vb.normal.get_z() + gamma * vc.normal.get_z())

									var/spec_factor = highlight.dot(normal) ** phong

									var/rr = 255 * (r * min(1, ar + rgb_intensity[1] * lambertian) \
													+ rgb_intensity[1] * spec_factor)
									var/gg = 255 * (g * min(1, ag + rgb_intensity[2] * lambertian) \
													+ rgb_intensity[2] * spec_factor)
									var/bb = 255 * (b * min(1, ab + rgb_intensity[3] * lambertian) \
													+ rgb_intensity[3] * spec_factor)

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

		project_vertices(list/vertices, apply_view, depth_test, skip_update=0)
			clear_screen()

			var/matrix4/view_transform = null

			if(apply_view)
				if(!camera)
					camera = new
				if(!camera.eye)
					camera.eye = new(0, 0, 0)
				var/vector3/e = camera.eye
				//src << "eye:"
				//e.print()
				if(!camera.gaze)
					camera.gaze = new(0, 0, -1)
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
				(1, 0, 0, -e.get_x(), \
				0, 1, 0, -e.get_y(), \
				0, 0, 1, -e.get_z(), \
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
			var/f = -30

			src.fov = 2 * arctan(t / abs(n))

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
			var/matrix4/view_proj = projection.multiply(view_transform)


			screen_transform = window_transform.multiply(projection.multiply(view_transform))
			//screen_transform.print()

			//var/matrix4/screen_transform = null
			if(perspective_correction)
				//(window * ortho) * persp * view
				//window * proj * view
				screen_transform = window_transform.multiply(projection.multiply(view_transform))
			else
				//(window * ortho) * view
				screen_transform = window_transform.multiply(ortho_transform.multiply(view_transform))

			var/matrix4/normal_transform = view_proj.copy()
			normal_transform = normal_transform.inverse()
			normal_transform = normal_transform.transpose()

			if(depth_test)
				for(var/i = 1; i <= vertices.len; i += 3)
					if(i + 2 > vertices.len)
						return

					var/vertex/v1 = vertices[i]
					var/vector4/p1 = screen_transform.multiply(v1.position)
					v1.clip_position = view_proj.multiply(v1.position)
					v1.clip_position.homogenize()

					var/vertex/v2 = vertices[i + 1]
					var/vector4/p2 = screen_transform.multiply(v2.position)
					v2.clip_position = view_proj.multiply(v2.position)
					v2.clip_position.homogenize()

					var/vertex/v3 = vertices[i + 2]
					var/vector4/p3 = screen_transform.multiply(v3.position)
					v3.clip_position = view_proj.multiply(v3.position)
					v3.clip_position.homogenize()

					var/h1 = p1.homogenize()
					var/h2 = p2.homogenize()
					var/h3 = p3.homogenize()



					draw_triangle(
					p1.get_x(), p1.get_y(), p1.get_z(), h1, v1, \
					p2.get_x(), p2.get_y(), p2.get_z(), h2, v2, \
					p3.get_x(), p3.get_y(), p3.get_z(), h3, v3, \
					)

					//src << "draw triangle ([p1.get_x()],[p1.get_y()]) ([p2.get_x()],[p2.get_y()]) ([p3.get_x()],[p3.get_y()])"

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
			if(canvas)
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





