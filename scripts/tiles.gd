@tool
extends Node3D

func bake_all_scales():
	for child in get_children():
		_bake_scale(child)

func _bake_scale(node: Node3D):
	for ch in node.get_children():
		if ch is MeshInstance3D:
			var s = node.scale  # lấy scale của node cha
			var mdt = MeshDataTool.new()
			var arr_mesh = ArrayMesh.new()
			arr_mesh.add_surface_from_arrays(
				Mesh.PRIMITIVE_TRIANGLES,
				ch.mesh.surface_get_arrays(0)
			)
			mdt.create_from_surface(arr_mesh, 0)
			for i in range(mdt.get_vertex_count()):
				mdt.set_vertex(i, mdt.get_vertex(i) * s)
			arr_mesh = ArrayMesh.new()
			mdt.commit_to_surface(arr_mesh)
			ch.mesh = arr_mesh
			node.scale = Vector3(1, 1, 1)  # reset về 1
