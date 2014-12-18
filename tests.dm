client
	verb
		perform_tests()
			var/vector3/v1 = new(1, 1, 1)
			var/vector3/v2 = new(1, 2, 2)
			var/vector3/v3 = v2.copy()

			ASSERT(!v1.equals(v2))
			ASSERT(v2.equals(v3))

			var/vector3/v4 = new(1, 2, 2)
			ASSERT(v4.equals(v2))

			var/matrix4/m1 = new \
			(0, 4, 0, 8,
			3, 0, 5, 0,
			2, 1, 0, 2,
			0, 0, 4, 0)

			var/matrix4/m2 = new \
			(0, 3, 2, 0,
			4, 0, 1, 0,
			0, 5, 0, 4,
			8, 0, 2, 0)

			ASSERT(m1.equals(m2.transpose()))

			src << "all tests passed"
