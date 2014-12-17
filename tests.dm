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

			src << "all tests passed"
