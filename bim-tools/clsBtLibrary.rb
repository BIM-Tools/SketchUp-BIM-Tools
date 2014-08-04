#       clsBtLibrary.rb
#       
#       Copyright (C) 2013 Jan Brouwer <jan@brewsky.nl>
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

module Brewsky
  module BimTools
  
    # collection of all building elements in the project
    # Object "parallel" to sketchup "entities" object # klopt dit? of is dit het array?
    # Hoort deze klasse geen onderdeel van clsBtProject te zijn?
    class ClsBtLibrary
      def initialize
        setBtLibrary
        fill
        return self
      end

      # add bt-element to library
      def add(entity)
        # should this function check if the element is a valid bt-element? yes!
        @lib << entity
      end

      # returns an array containing all bt-entities
      def entities
        return @lib
      end

      # return the bt_entity for the geometry(group)
      # use this function to check if a group entity is "part" of a bt_entity
      # returns a bt_entity or nil
      def geometry_to_bt_entity(project, geometry)
        bt_entity = nil
        project.library.entities.each do |ent|
          if geometry == ent.geometry # als de geometry voorkomt in de bt-library
            bt_entity = ent
            break
          end
        end
        return bt_entity
      end

      # return the bt_entity for the source(face/edge)
      # use this function to check if a face/edge entity is "part" of a bt_entity
      # returns a bt_entity or nil
      def source_to_bt_entity(project, source)
        bt_entity = false
        project.library.entities.each do |ent|
          if source == ent.source # als de source voorkomt in de bt-library
            bt_entity = ent
            break
          end
        end
        return bt_entity
      end

      # return a new array that only contains the bt_entities from the "geometry"(group) objects in the input array
      def geometry_array_remove_non_bt_entities(project, entities)
        bt_entities = Array.new
        entities.each do |entity|
        
          # test if the source object is part of a bt_entity
          bt_entity = geometry_to_bt_entity(project, entity)
          if bt_entity != nil
            bt_entities << bt_entity
          end
        end
        return bt_entities # return a new array that only contains bt_entities
      end

      # return a new array that only contains the bt_entities from the "source"(face/edge) objects in the input array
      def source_array_remove_non_bt_entities(project, entities)
        bt_entities = Array.new
        entities.each do |entity|
        
          # test if the source object is part of a bt_entity
          if bt_entity = source_to_bt_entity(project, entity)
            bt_entities << bt_entity
          end
        end
        return bt_entities
      end
      
      # return a new array that only contains the bt_entities from the objects in the input array
      def array_remove_non_bt_entities(project, entities)
        bt_entities_geometry = geometry_array_remove_non_bt_entities(project, entities)
        bt_entities_source = source_array_remove_non_bt_entities(project, entities)
        bt_entities = bt_entities_geometry + bt_entities_source
        bt_entities.uniq!
        return bt_entities
      end
      
      #create a clone of a bt_entity based on a new source face
      def duplicate_bt_entity(bt_entity, source)
        clone = bt_entity.clone
        clone.set_guid
        clone.source= source
        clone.set_geometry
        return clone
      end

      private
      def setBtLibrary
        @lib = Array.new
      end

      def fill

        # find all sketchup objects that can be converted to building elements
        # and add them to @lib.
      end
    end
  end # module BimTools
end # module Brewsky
