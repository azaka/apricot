vector3
	var
		list/dat[3][1]

	New(x = 0, y = 0, z = 0)
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

		multiply(x)
			for(var/i = 1 to 3)
				dat[i][1] *= x

		normalize()
			var/magnitude = magnitude()

			for(var/i = 1 to 3)
				dat[i][1] = dat[i][1] / magnitude

		magnitude()
			. = 0
			for(var/i = 1 to 3)
				. += dat[i][1] ** 2

			. = sqrt(.)

		cross(vector3/v)
			var/vector3/res = new
			res.dat[1][1] = dat[2][1] * v.dat[3][1] - dat[3][1] * v.dat[2][1]
			res.dat[2][1] = dat[1][1] * v.dat[3][1] - dat[3][1] * v.dat[1][1]
			res.dat[2][1] *= -1

			res.dat[3][1] = dat[1][1] * v.dat[2][1] - dat[2][1] * v.dat[1][1]

			return res