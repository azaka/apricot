matrix4
	var
		list/dat[4][4]
	New()
		world << "[args.len] arguments received"
		if(args.len < 4 * 4)
			return

		var/i = 0
		for(var/r = 1 to 4)
			for(var/c = 1 to 4)
				dat[r][c] = args[++i]

	proc
		multiply(matrix4/m)
			if(!istype(m))
				return

			var/matrix4/res = new
			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					res.dat[r][c] = 0
					for(var/i = 1 to 4)
						res.dat[r][c] += dat[r][i] * m.dat[i][c]

			return res

		print()
			world << "\<[type]\>:\ref[src]"
			var/str = ""
			for(var/r = 1 to 4)
				for(var/c = 1 to 4)
					if(c == 1)
						str += "[dat[r][c]]"
					else
						str += ", [dat[r][c]]"
				world << str
				str = ""
