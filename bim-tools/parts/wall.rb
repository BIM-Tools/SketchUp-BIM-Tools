#       walls.rb
#       
#       Copyright (C) 2011 Jan Brouwer <jan@brewsky.nl>
#       
#       This program is free software: you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation, either version 3 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program.  If not, see <http://www.gnu.org/licenses/>.


    def walls_from_selection(bt_lib, wall_width, wall_height) # Create new wall objects from selection.

      model = Sketchup.active_model
      entities = model.active_entities
      selection = model.selection

      model.start_operation("Create walls", disable_ui=true) # Start of operation/undo section
	selection.each { |base_edge|
	  if base_edge.is_a? Sketchup::Edge
	    Wall.new(bt_lib, base_edge, wall_width, wall_height)
	  end
	}
      model.commit_operation # End of operation/undo section
      model.active_view.refresh # Refresh model
    end

    class Wall
      attr_accessor :base_edge
      
      def initialize(bt_lib, base_edge, wall_width, wall_height)
	
	@base_edge = base_edge
	edge_start_vertex = base_edge.start
	edge_end_vertex = base_edge.end
	edge_transformation = base_transformation(base_edge)
	
	slice_planes_start = wall_slice_planes(edge_start_vertex, base_edge, edge_transformation)
	slice_planes_end = wall_slice_planes(edge_end_vertex, base_edge, edge_transformation)
	parallel_lines = profile_lines(profile(wall_width))
	
	group = geometry(slice_planes_start, slice_planes_end, parallel_lines, wall_height)
	group.transform! edge_transformation
	
	#create attribute dictionary for group
	group.set_attribute "ifc", "ifc_element", "IfcWallStandardCase"
	group.set_attribute "ifc", "length", base_edge.length
	group.set_attribute "ifc", "width", wall_width
	group.set_attribute "ifc", "height", wall_height
	
	# find a unique id number and attach attribute to wall
	require 'bim-tools/lib/ifcGeneral.rb'
	set_id(group)
	
	#add group to ifc_layer
	 layer = Sketchup.active_model.layers.add "ifcWall"
	 group.layer = layer
	 
	# Create new BtWall object from geometry
	wall_element = BtWall.new(bt_lib, group)
	return wall_element
	 
      end
      def material()# temporary material function
	return "Default material"
      end
      def wall_slice_planes(edge_end_vertex, base_edge, edge_transformation)
	connected_edges = edge_end_vertex.edges
	angle_array = Array.new
	base_vector_origin = base_edge.line[1].transform edge_transformation.inverse
	if connected_edges.length == 1 # If the wall-endpoint touches only one wall, create a straight end
	  vector_min_origin = Geom::Vector3d.new 0,1,0
	  vector_max_origin = Geom::Vector3d.new 0,-1,0
	else
	  if edge_end_vertex != base_edge.start # Check if both edges are not the same
	    base_vector_origin.reverse!
	  end
	  vector_min_origin = base_vector_origin.clone
	  vector_max_origin = base_vector_origin.clone
	  connected_edges.each { |edge_connected|
	    if base_edge != edge_connected
	      connected_vector_origin = edge_connected.line[1].transform edge_transformation.inverse
	      if edge_end_vertex != edge_connected.start
		connected_vector_origin.reverse!
	      end
	      angle = base_vector_origin.angle_between connected_vector_origin
	      crossVector = base_vector_origin.cross connected_vector_origin
	      if crossVector.z < 0
		angle = Math::PI*2 - angle
	      end
	      angle_array << angle
	    end
	  }
	  angle_min = angle_array.min() / 2
	  angle_max = angle_array.max() / 2
	  rotation_point = Geom::Point3d.new 0,0,0
	  rotation_axes = Geom::Vector3d.new 0,0,1
	  rotation_min = Geom::Transformation.rotation rotation_point, rotation_axes, angle_min
	  rotation_max = Geom::Transformation.rotation rotation_point, rotation_axes, angle_max
	  vector_min_origin.transform! rotation_min
	  vector_max_origin.transform! rotation_max
	end
	      
	edge_end_point = edge_end_vertex.position
	edge_end_point_origin = edge_end_point.transform edge_transformation.inverse
	
	slice_line_L = [edge_end_point_origin, vector_min_origin]
	slice_line_R = [edge_end_point_origin, vector_max_origin]
	return [slice_line_L, slice_line_R]
      end
      def profile(wall_width) # define a wall profile, in this case a simple 100mm wide wall, even height is not yet built into this method
	wall_width = wall_width.to_f.to_inch
	half_width = wall_width / 2
	profile_array = []
	profile_array[0] = Geom::Point3d.new 0,0,0
	profile_array[1] = Geom::Point3d.new 0,half_width.mm,0
	profile_array[2] = Geom::Point3d.new 0,-half_width.mm,0
	return profile_array
      end
      def profile_lines(profile)
	profile_vector = Geom::Vector3d.new(1,0,0)
	profile_lines_array = []
	profile.each { |profile_point|
	  profile_lines_array << [profile_point, profile_vector]
	}
	return profile_lines_array
      end
      def base_transformation(base_edge)
	vector_origin = Geom::Vector3d.new 1,0,0 # origin x-axes, position for creating group
	vector_base = base_edge.line[1] # vector for base_edge
	edge_start_point = base_edge.start.position
	rotation_axes = Geom::Vector3d.new 0,0,1
	rotation_angle = vector_origin.angle_between vector_base
	if vector_base.y < 0
	  rotation_angle = -rotation_angle
	end
	transform_move = Geom::Transformation.new edge_start_point
	transform_rotate = Geom::Transformation.rotation edge_start_point, rotation_axes, rotation_angle
	transformation = transform_rotate * transform_move
	return transformation
      end
      def geometry(slice_planes_start, slice_planes_end, parallel_lines, wall_height)
	
	model = Sketchup.active_model
	entities = model.active_entities
	selection = model.selection
	    
	points_array = []
	points_array << Geom.intersect_line_line(parallel_lines[1], slice_planes_start[0])
	points_array << Geom.intersect_line_line(parallel_lines[1], slice_planes_end[1])
	points_array << Geom.intersect_line_line(parallel_lines[0], slice_planes_end[1])
	points_array << Geom.intersect_line_line(parallel_lines[2], slice_planes_end[0])
	points_array << Geom.intersect_line_line(parallel_lines[2], slice_planes_start[1])
	points_array << Geom.intersect_line_line(parallel_lines[0], slice_planes_start[1])

	group = entities.add_group # Add the group to the entities in the model
	group_entities = group.entities # Get the entities within the group
	face = group_entities.add_face points_array # Add a face to the group based on the calculated points
	
	height = wall_height.to_f.mm
	face.pushpull -height, true
	
	face.set_attribute "ifc", "ifc_construct", "IfcArea"
	face.reverse!
	
	return group
      end
    end
