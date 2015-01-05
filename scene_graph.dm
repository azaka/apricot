scene_graph
	var
		list/nodes
		matrix_stack/stack

	New()
		nodes = list()
		stack = new

	proc
		traverse(scene_node/node)
			stack.push(node.transform)

			var/list/transform_vertices = list()
			for(var/vertex/v in node.vertices)
				var/matrix4/model_transform = stack.get_model_transform()
				var/matrix4/normal_transform = stack.get_normal_transform()
				var/vector4/position = model_transform.multiply(v.position)
				var/vector3/normal = new(normal_transform.multiply(v.normal))

				var/vertex/tv = v.copy()
				tv.position = position
				tv.normal = normal
				transform_vertices += tv

			var/mob/m = usr
			m.client.project_vertices(transform_vertices, 1, 1)

			traverse(node.left)

			traverse(node.right)

			stack.pop()


scene_node
	var
		matrix4/transform
		list/vertices
		scene_node/left
		scene_node/right

matrix_stack
	var
		list/matrices = list()

	proc
		push(matrix4/m)
			matrices += m

		pop()
			var/matrix4/m = matrices[matrices.len]

			matrices -= m

		get_model_transform()
			var/matrix4/model_transform = new
			model_transform.make_identity()

			for(var/i = matrices.len; i > 0; i--)
				var/matrix4/m = matrices[i]

				model_transform = m.multiply(model_transform)

			return model_transform

		get_normal_transform()
			var/matrix4/normal_transform = get_model_transform()
			normal_transform = normal_transform.inverse()
			normal_transform = normal_transform.transpose()

			return normal_transform
