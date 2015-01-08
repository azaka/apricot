matrix4
	var
		list/dat[4][4]
	New()
	#ifdef VERBOSE
		world << "[args.len] arguments received"
	#endif
		if(args.len < 4 * 4)
			return

		var/i = 0
		for(var/r = 1 to 4)
			for(var/c = 1 to 4)
				dat[r][c] = args[++i]

	proc
		scale(sx, sy, sz)
			if(!isnum(sx) || !isnum(sy) || !isnum(sz))
				return

			var/matrix4/transform = new(\
			sx, 0, 0, 0,
			0, sy, 0, 0,
			0, 0, sz, 0,
			0, 0, 0, 1)

			var/matrix4/res = transform.multiply(src)
			dat = res.dat.Copy()

		translate(dx, dy, dz)
			if(!isnum(dx) || !isnum(dy) || !isnum(dz))
				return

			var/matrix4/transform = new(\
			1, 0, 0, dx,
			0, 1, 0, dy,
			0, 0, 1, dz,
			0, 0, 0, 1)

			var/matrix4/res = transform.multiply(src)
			dat = res.dat.Copy()

		make_identity()
			var/matrix4/temp = new(\
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1)

			dat = temp.dat.Copy()

		multiply(matrix4/m)
			if(istype(m))

				var/matrix4/res = new
				for(var/r = 1 to 4)
					for(var/c = 1 to 4)
						res.dat[r][c] = 0
						for(var/i = 1 to 4)
							res.dat[r][c] += dat[r][i] * m.dat[i][c]

				return res
			else if(istype(m, /vector4))
				var/vector4/res = new
				var/vector4/v = m
				for(var/r = 1 to 4)
					var/c = 1
					res.dat[r][c] = 0
					for(var/i = 1 to 4)
						res.dat[r][c] += dat[r][i] * v.dat[i][c]

				return res
			else if(isnum(m))
				var/n = m
				var/matrix4/res = new
				for(var/r = 1 to 4)
					for(var/c = 1 to 4)
						res.dat[r][c] = dat[r][c] * n
				return res

		transpose()
			var/matrix4/res = new

			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					res.dat[r][c] = dat[c][r]

			return res

		cofactor()
			#define a (dat)
			var/list/b[4][4]

			b[1][1] = a[2][2] * a[3][3] * a[4][4] + a[2][3] * a[3][4] * a[4][2] + a[2][4] * a[3][2] * a[4][3] - a[2][2] * a[3][4] * a[4][3] - a[2][3] * a[3][2] * a[4][4] - a[2][4] * a[3][3] * a[4][2]
			b[1][2] = a[1][2] * a[3][4] * a[4][3] + a[1][3] * a[3][2] * a[4][4] + a[1][4] * a[3][3] * a[4][2] - a[1][2] * a[3][3] * a[4][4] - a[1][3] * a[3][4] * a[4][2] - a[1][4] * a[3][2] * a[4][3]
			b[1][3] = a[1][2] * a[2][3] * a[4][4] + a[1][3] * a[2][4] * a[4][2] + a[1][4] * a[2][2] * a[4][3] - a[1][2] * a[2][4] * a[4][3] - a[1][3] * a[2][2] * a[4][4] - a[1][4] * a[2][3] * a[4][2]
			b[1][4] = a[1][2] * a[2][4] * a[3][3] + a[1][3] * a[2][2] * a[3][4] + a[1][4] * a[2][3] * a[3][2] - a[1][2] * a[2][3] * a[3][4] - a[1][3] * a[2][4] * a[3][2] - a[1][4] * a[2][2] * a[3][3]

			b[2][1] = a[2][1] * a[3][4] * a[4][3] + a[2][3] * a[3][1] * a[4][4] + a[2][4] * a[3][3] * a[4][1] - a[2][1] * a[3][3] * a[4][4] - a[2][3] * a[3][4] * a[4][1] - a[2][4] * a[3][1] * a[4][3]
			b[2][2] = a[1][1] * a[3][3] * a[4][4] + a[1][3] * a[3][4] * a[4][1] + a[1][4] * a[3][1] * a[4][3] - a[1][1] * a[3][4] * a[4][3] - a[1][3] * a[3][1] * a[4][4] - a[1][4] * a[3][3] * a[4][1]
			b[2][3] = a[1][1] * a[2][4] * a[4][3] + a[1][3] * a[2][1] * a[4][4] + a[1][4] * a[2][3] * a[4][1] - a[1][1] * a[2][3] * a[4][4] - a[1][3] * a[2][4] * a[4][1] - a[1][4] * a[2][1] * a[4][3]
			b[2][4] = a[1][1] * a[2][3] * a[3][4] + a[1][3] * a[2][4] * a[3][1] + a[1][4] * a[2][1] * a[3][3] - a[1][1] * a[2][4] * a[3][3] - a[1][3] * a[2][1] * a[3][4] - a[1][4] * a[2][3] * a[3][1]

			b[3][1] = a[2][1] * a[3][2] * a[4][4] + a[2][2] * a[3][4] * a[4][1] + a[2][4] * a[3][1] * a[4][2] - a[2][1] * a[3][4] * a[4][2] - a[2][2] * a[3][1] * a[4][4] - a[2][4] * a[3][2] * a[4][1]
			b[3][2] = a[1][1] * a[3][4] * a[4][2] + a[1][2] * a[3][1] * a[4][4] + a[1][4] * a[3][2] * a[4][1] - a[1][1] * a[3][2] * a[4][4] - a[1][2] * a[3][4] * a[4][1] - a[1][4] * a[3][1] * a[4][2]
			b[3][3] = a[1][1] * a[2][2] * a[4][4] + a[1][2] * a[2][4] * a[4][1] + a[1][4] * a[2][1] * a[4][2] - a[1][1] * a[2][4] * a[4][2] - a[1][2] * a[2][1] * a[4][4] - a[1][4] * a[2][2] * a[4][1]
			b[3][4] = a[1][1] * a[2][4] * a[3][2] + a[1][2] * a[2][1] * a[3][4] + a[1][4] * a[2][2] * a[3][1] - a[1][1] * a[2][2] * a[3][4] - a[1][2] * a[2][4] * a[3][1] - a[1][4] * a[2][1] * a[3][2]

			b[4][1] = a[2][1] * a[3][3] * a[4][2] + a[2][2] * a[3][1] * a[4][3] + a[2][3] * a[3][2] * a[4][1] - a[2][1] * a[3][2] * a[4][3] - a[2][2] * a[3][3] * a[4][1] - a[2][3] * a[3][1] * a[4][2]
			b[4][2] = a[1][1] * a[3][2] * a[4][3] + a[1][2] * a[3][3] * a[4][1] + a[1][3] * a[3][1] * a[4][2] - a[1][1] * a[3][3] * a[4][2] - a[1][2] * a[3][1] * a[4][3] - a[1][3] * a[3][2] * a[4][1]
			b[4][3] = a[1][1] * a[2][3] * a[4][2] + a[1][2] * a[2][1] * a[4][3] + a[1][3] * a[2][2] * a[4][1] - a[1][1] * a[2][2] * a[4][3] - a[1][2] * a[2][3] * a[4][1] - a[1][3] * a[2][1] * a[4][2]
			b[4][4] = a[1][1] * a[2][2] * a[3][3] + a[1][2] * a[2][3] * a[3][1] + a[1][3] * a[2][1] * a[3][2] - a[1][1] * a[2][3] * a[3][2] - a[1][2] * a[2][1] * a[3][3] - a[1][3] * a[2][2] * a[3][1]
			#undef a

			var/matrix4/res = new
			res.dat = b

			return res

		inverse()
			var/matrix4/cofactor = cofactor()
			return cofactor.multiply(determinant() ** -1)

		determinant()
			#define a (dat)

			. = 0
			. += a[1][1] * a[2][2] * a[3][3] * a[4][4]
			. += a[1][1] * a[2][3] * a[3][4] * a[4][2]
			. += a[1][1] * a[2][4] * a[3][2] * a[4][3]

			. += a[1][2] * a[2][1] * a[3][4] * a[4][3]
			. += a[1][2] * a[2][3] * a[3][1] * a[4][4]
			. += a[1][2] * a[2][4] * a[3][3] * a[4][1]

			. += a[1][3] * a[2][1] * a[3][2] * a[4][4]
			. += a[1][3] * a[2][2] * a[3][4] * a[4][1]
			. += a[1][3] * a[2][4] * a[3][1] * a[4][2]

			. += a[1][4] * a[2][1] * a[3][3] * a[4][2]
			. += a[1][4] * a[2][2] * a[3][1] * a[4][3]
			. += a[1][4] * a[2][3] * a[3][2] * a[4][1]

			. -= a[1][1] * a[2][2] * a[3][4] * a[4][3]
			. -= a[1][1] * a[2][3] * a[3][2] * a[4][4]
			. -= a[1][1] * a[2][4] * a[3][3] * a[4][2]

			. -= a[1][2] * a[2][1] * a[3][3] * a[4][4]
			. -= a[1][2] * a[2][3] * a[3][4] * a[4][1]
			. -= a[1][2] * a[2][4] * a[3][1] * a[4][3]

			. -= a[1][3] * a[2][1] * a[3][4] * a[4][2]
			. -= a[1][3] * a[2][2] * a[3][1] * a[4][4]
			. -= a[1][3] * a[2][4] * a[3][2] * a[4][1]

			. -= a[1][4] * a[2][1] * a[3][2] * a[4][3]
			. -= a[1][4] * a[2][2] * a[3][3] * a[4][1]
			. -= a[1][4] * a[2][3] * a[3][1] * a[4][2]

			#undef a


		equals(matrix4/m)
			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					if(dat[r][c] != m.dat[r][c])
						return 0

			return 1

		copy()
			var/matrix4/res = new

			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					res.dat[r][c] = dat[r][c]

			return res

		print()
			world << "\<[type]\>:\ref[src]"
			var/str = ""
			for(var/r = 1 to dat.len)
				for(var/c = 1 to length(dat[1]))
					if(c == 1)
						str += "[dat[r][c]]"
					else
						str += ", [dat[r][c]]"
				world << str
				str = ""
