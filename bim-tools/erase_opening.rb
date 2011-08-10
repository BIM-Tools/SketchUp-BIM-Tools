#       erase_opening.rb
#       
#       Copyright 2011 Jan Brouwer <jan@brewsky.nl>
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

def erase_opening(opening, glue_surface)
  @hole_edges = Array.new
  
  glue_surface.entities.each do |entity|
    parent = opening.get_attribute "ifc", "id"
    if entity.get_attribute("ifc", "parent") == parent
      edge_array = entity.edges
      # fill holes
      edge_array.each do |edge|
        edge.find_faces
      end
      edge_array.each do |edge|
        if @hole_edges.include? edge
        else
          @hole_edges << edge
        end
      end
    end
  end
  @hole_edges.each do |edge|
    edge.erase!
  end
end
