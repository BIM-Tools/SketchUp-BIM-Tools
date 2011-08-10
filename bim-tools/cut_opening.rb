#       cut_opening.rb
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

class CutOpening
	def initialize(entity, glue_surface)
    # if entity.typename == "ComponentInstance"
    @entity = entity
    definition = entity.definition
    entities = glue_surface.entities
    trans_opening = entity.transformation
    trans_wall = glue_surface.transformation
    @transformation =  trans_wall.invert! * trans_opening
    opening = entities.add_group
    @opening_entities = opening.entities
    definition_entities = definition.entities
    definition_entities.each do |def_ent|
      if def_ent.typename == "Edge"
        @checked_edges = Array.new
        #recursively itterate through edges to check if every edge connects to 2 others
        def test_edge(edge)
          #check if edge has been checked before
          if @checked_edges.include? edge
          else
            if edge.start.position.z == 0
              if edge.end.position.z == 0
                #mark edge as "checked"
                @checked_edges << edge
                edge.start.edges.each do |con_edge|
                  if con_edge != edge
                    test_edge(con_edge)
                  end
                end
                edge.end.edges.each do |con_edge|
                  if con_edge != edge
                    test_edge(con_edge)
                  end
                end
                verticies = edge.vertices
                start_edges = verticies[0]
                end_edges = verticies[1]
                start_edges = start_edges.edges
                end_edges = end_edges.edges
                if start_edges.length == 1
                elsif end_edges.length == 1#does not allways work, more levels of recusion needed...
                else
                  start_point = edge.start.position.transform @transformation
                  end_point = edge.end.position.transform @transformation
                  @opening_entities.add_edges start_point, end_point
                end
              end
            end
          end # if checked edge
        end #test_edge
        test_edge(def_ent)
      end
    end
    #create all possible cut faces
    opening.entities.each do |entity|
      if entity.typename == "Edge"
        entity.find_faces
      end
    end
    
    
    #erase all internal edges, recursively because one deleted edge affects another
    def erase_internal(entities)
      entities.each do |entity|
        if entity.typename == "Edge"
          if entity.deleted? == false
            if entity.faces.length != 1
              entity.erase!
              erase_internal(entities)
            end
          end
        end
      end
    end
    erase_internal(opening.entities)
    
    #list all faces for extrusion/identification
    faces = Array.new
    opening.entities.each do |entity|
      if entity.typename == "Face"
        faces << entity
      end
    end
    width = glue_surface.get_attribute "ifc", "width"
    #extrusion direction depends on drawing direction of edges, sometimes extrusion in wrong direction
    extrusion = -width.to_f.mm
    faces.each do |face|
      face.pushpull extrusion, true
    end
    caps_set = Set.new
    @hole_faces = Array.new
    #determine the top and bottom faces
    plane = faces[0].plane
    opening.entities.each do |entity|
      if entity.typename == "Face"
        if Geom.intersect_plane_plane(entity.plane, plane) == nil
          caps_set.insert entity
        else
          entity.reverse!
          id = @entity.get_attribute "ifc", "id"
          entity.set_attribute "ifc", "parent", id
        end
      end
    end
    opening.explode
    caps_set.each do |entity|
      entity.erase!
    end
  end
end
