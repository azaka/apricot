camera
	var
		vector3/eye
		vector3/gaze
		vector3/up
		ambience = "#111"

	proc
		rotate_y(angle)
			var/vector4/g = new(gaze, 0)

			var/matrix4/rotate_transform = new \
			(cos(angle), 0, sin(angle), 0, \
			0, 1, 0, 0, \
			-1 * sin(angle), 0, cos(angle), 0, \
			0, 0, 0, 1)

			g = rotate_transform.multiply(g)

			gaze.set_x(g.get_x())
			gaze.set_y(g.get_y())
			gaze.set_z(g.get_z())

