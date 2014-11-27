vector4

	var
		list/dat[4][1]

	New()
		if(args.len < 1)
			return

		var/i = 0
		for(var/r = 1 to 4)
			dat[r][1] = args[++i]

	proc
		get_x()
			return dat[1][1]

		get_y()
			return dat[2][1]

		get_z()
			return dat[3][1]

		multiply(x)
			var/vector4/res = new
			for(var/i = 1 to 3)
				res.dat[i][1] = dat[i][1] * x
			res.dat[4][1] = 1
			return res

		homogenize()
			if(dat[4][1] == 0)
				world << "cannot homogenize vector"
				print()
				usr.client.is_moving = 0
				//CRASH("cannot homogenize vector")
				return

			for(var/r = 1 to 4)
				dat[r][1] /= dat[4][1]

		print(ignore_h = 0)
			world << "\<[type]\>:\ref[src]"
			var/str = ""
			for(var/r = 1 to dat.len - ignore_h)
				for(var/c = 1 to length(dat[1]))
					if(c == 1)
						str += "[dat[r][c]]"
					else
						str += ", [dat[r][c]]"
				world << str
				str = ""