#       clsBuildingElement.rb
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

module Brewsky
  module BimTools

    # building element basetype class
    class ClsBuildingElement
      
      # add the new element to the project library
      def add_to_lib
        @project.library.add(self)
      end
      
      # check if the building element´s geometry and source still exist
      def deleted?
        if @geometry.deleted? == true
          return true
        elsif @source.deleted? == true
          return true
        else
          return false
        end
      end
      
      # if source object is unrecoverable, self_destruct bt_entity
      def self_destruct
        @deleted = true
        unless @source.deleted?
          source.hidden= false
          
          # remove all bt properties from face
          @source.attribute_dictionaries.delete 'ifc'
        end
        unless @geometry.deleted?
          @geometry.erase!
        end
        
        # remobe bt_entity from library
        @project.library.entities.delete(self)
        
        # check if the entities observer needs to be removed
        active_entities = Sketchup.active_model.active_entities
        observer_manager = Brewsky::BimTools::ObserverManager
        observer_manager.add_entities_observer(@project, active_entities)
        
      end
      
      # hide OR geometry OR source
      def geometry_visibility(visibility=true)
        if visibility == true
          @geometry.hidden=false
          @source.hidden=true
        else
          @geometry.hidden=true
          @source.hidden=false
        end
      end
      def source
        #check_source
        return @source
      end
      def source=(source)
        @source = source
      end
      def geometry
        return @geometry
      end
      
      # returns the volume of the geometry
      def volume?
        if @geometry.deleted?
          set_geometry
        end
        return (@geometry.volume* (25.4 **3)).to_s
      end
      
      # returns the guid of the bt_element
      def guid?
        return @guid
      end
      def possible_types
        return Array["Wall", "Floor", "Roof", "Column", "Window", "Door"]
      end
      def marked_for_deletion?
        return @deleted
      end
      def element_type?
        return @element_type
      end
      def name?
        return @name
      end
      def name=(name)
        @name = name
      end
      def description?
        return @description
      end
      def description=(description)
        @description = description
      end
      # set element type for planar, possible types is a required method for all subclasses of clsBuildingElement
      def element_type=(type)
        if possible_types.include? type
          @element_type = type
          return true
        else
          return false
        end
      end
      
      # checks if the source entity is valid, and if not searches for new source entity
      def check_source
        if @source.deleted?
          @project.source_recovery
        end
      end
        
      # checks if the geometry group is valid, and if not creates new geometry
      def check_geometry
        if @geometry.deleted?
          set_geometry
        end
      end
      
      # if source object = renamed, find the new name
      def find_source
        entities = Sketchup.active_model.entities
        entities.each do |entity|
          guid = entity.get_attribute "ifc", "guid"
          if guid == @guid
            @source = entity
            break
          end
        end
      end
      
      # DEPRECATED because "toggle"tool disables observers
      # this variable is only used for the observer that checks if the source face is changed, hide/unhide is no real change.
      #def source_hidden?
      #  return @source_hidden
      #end  
      
      # DEPRECATED because "toggle"tool disables observers
      # this variable is only used for the observer that checks if the source face is changed, hide/unhide is no real change.
      #def source_hidden=(value)
      #  @source_hidden = value
      #end
    
      def set_guid
        @guid = @project.new_guid
      end
      def find_bt_entity_for_face(source)
        bt_entity = nil
        @project.library.entities.each do |ent|
          if source == ent.source # als het vlak voorkomt in de bt-library
            bt_entity = ent
            break
          end
        end
        bt_entity
        return bt_entity
      end
    end
  end # module BimTools
end # module Brewsky
