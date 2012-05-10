#       walls_from_edges.rb
#       
#       Copyright (C) 2012 Jan Brouwer <jan@brewsky.nl>
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

class WallsFromEdges
  def initialize(project, a_edges, h_properties)
    require "bim-tools/tools/planar_from_faces.rb"
    @model = Sketchup.active_model
    @entities = @model.active_entities
    @project = project
    @height = h_properties["height"]
    
    # start undo section
    @model.start_operation("Create walls from edges", disable_ui=true) # Start of operation/undo section
    
    a_faces = create_faces(a_edges)

    planar_from_faces = PlanarFromFaces.new(@project, a_faces)
    @model.select_tool planar_from_faces
    
    @model.commit_operation # End of operation/undo section
    @model.active_view.refresh # Refresh model
    
  end
  def create_faces(a_edges)
    a_faces = Array.new
    a_edges.each do |edge|
      bottom_start = edge.start.position
      bottom_end = edge.end.position
      top_start = Geom::Point3d.new(bottom_start.x, bottom_start.y, bottom_start.z + @height)
      top_end = Geom::Point3d.new(bottom_end.x, bottom_end.y, bottom_end.z + @height)
      begin
        a_faces << @entities.add_face(bottom_start, bottom_end, top_end, top_start)
      rescue
        puts "unable to create face"
      end
    end
    return a_faces
  end
end
