obj_loader
	proc
		load(f)
			if(!f || !isfile(f))
				return

			var/list/vertex_data = list()
			var/list/elements = list()
			var/list/lines = dd_file2list(f)

			for(var/line in lines)
				var/list/data = dd_text2list(line, " ")

				switch(data[1])
					if("v")
						var/x = text2num(data[2])
						var/y = text2num(data[3])
						var/z = text2num(data[4])

						vertex_data += new /vector3(x, y, z)

					if("f")
						elements += text2num(data[2])
						elements += text2num(data[3])
						elements += text2num(data[4])

			var/list/vertices = list()
			for(var/i = 1; i <= elements.len; i += 3)
				var/ia = elements[i]
				var/ib = elements[i + 1]
				var/ic = elements[i + 2]

				var/vector3/v1 = vertex_data[ia]
				var/vector3/v2 = vertex_data[ib]
				var/vector3/v3 = vertex_data[ic]

				var/vector3/v21 = v2.subtract(v1)
				var/vector3/v31 = v3.subtract(v1)

				var/vector3/normal = v21.cross(v31)
				normal.normalize()

				var/vertex/a = new
				a.position = new(v1, 1)
				a.normal = normal.copy()

				var/vertex/b = new
				b.position = new(v2, 1)
				b.normal = normal.copy()

				var/vertex/c = new
				c.position = new(v3, 1)
				c.normal = normal.copy()

				vertices += a
				vertices += b
				vertices += c

			return vertices
