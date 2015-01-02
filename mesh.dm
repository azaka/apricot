mesh
	var
		edge/edge

	proc
		dispose()
			for(var/v in edge.vars)
				edge.vars[v] = null

			edge = null

edge
	var
		vertex/vertex1
		vertex/vertex2
		face/face_left
		face/face_right
		edge/pred_left_edge
		edge/succ_left_edge
		edge/pred_right_edge
		edge/succ_right_edge

face
	var
		edge/edge


