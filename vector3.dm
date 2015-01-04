vector3
	var
		list/dat[3][1]

	New(x = 0, y = 0, z = 0)
		if(istype(x, /vector4))
			var/vector4/v = x
			dat[1][1] = v.get_x()
			dat[2][1] = v.get_y()
			dat[3][1] = v.get_z()

		else

			dat[1][1] = x
			dat[2][1] = y
			dat[3][1] = z

	proc
		get_x()
			return dat[1][1]

		get_y()
			return dat[2][1]

		get_z()
			return dat[3][1]

		set_x(x)
			dat[1][1] = x

		set_y(y)
			dat[2][1] = y

		set_z(z)
			dat[3][1] = z

		add(vector3/v)
			var/vector3/res = new
			for(var/i = 1 to 3)
				res.dat[i][1] = dat[i][1] + v.dat[i][1]

			return res

		subtract(vector3/v)
			var/vector3/res = new
			for(var/i = 1 to 3)
				res.dat[i][1] = dat[i][1] - v.dat[i][1]

			return res

		multiply(x)
			var/vector3/res = new
			for(var/i = 1 to 3)
				res.dat[i][1] = dat[i][1] * x

			return res

		normalize()
			var/magnitude = magnitude()

			if(!magnitude)
				world << "cannot normalize vector"
				print()
				return

			for(var/i = 1 to 3)
				dat[i][1] = dat[i][1] / magnitude

		magnitude()
			. = 0
			for(var/i = 1 to 3)
				. += dat[i][1] ** 2

			. = sqrt(.)

		equals(vector3/v)
			if(!istype(v))
				return 0

			for(var/i = 1 to 3)
				if(dat[i][1] != v.dat[i][1])
					return 0

			return 1

		copy()

			var/vector3/res = new
			for(var/i = 1 to 3)
				res.dat[i][1] = dat[i][1]

			return res

		dot(vector3/v)
			if(!istype(v))
				return

			var/vector3/v1 = copy()
			v1.normalize()
			var/vector3/v2 = v.copy()
			v2.normalize()

			. = 0
			for(var/i = 1 to 3)
				. += v1.dat[i][1] * v2.dat[i][1]

		cross(vector3/v)
			var/vector3/res = new
			res.dat[1][1] = dat[2][1] * v.dat[3][1] - dat[3][1] * v.dat[2][1]
			res.dat[2][1] = dat[1][1] * v.dat[3][1] - dat[3][1] * v.dat[1][1]
			res.dat[2][1] *= -1

			res.dat[3][1] = dat[1][1] * v.dat[2][1] - dat[2][1] * v.dat[1][1]

			return res

		string()
			return "([get_x()], [get_y()], [get_z()])"

		print()
			world << "\<[type]\>:\ref[src]"
			world << "([get_x()], [get_y()], [get_z()])"

