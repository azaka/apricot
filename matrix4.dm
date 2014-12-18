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

		transpose()
			var/matrix4/res = new

			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					res.dat[r][c] = dat[c][r]

			return res

		equals(matrix4/m)
			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					if(dat[r][c] != m.dat[r][c])
						return 0

			return 1

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
