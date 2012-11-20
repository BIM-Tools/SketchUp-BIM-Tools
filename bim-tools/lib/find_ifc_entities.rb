#       find_ifc_entities.rb
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

    # Function that searches the complete model for objects containing ifc attributes and adds these to the BIM-Tools library.
    #   parameters: project
    #   returns: -
    
    #also check project library for bim-tools entities without geometry AND source, and purge those?
    
    class ClsFindIfcEntities
      def initialize(project)
        @model = Sketchup.active_model
        @entities = @model.entities
        @project = project
        @lib = @project.library
        @h_guid_list = Hash.new
        
        # check every entity for attribute_dictionary "ifc"
        find_ifc_loop(@entities)
        add_planars
      end
    
      # recursive loop that fires check_ifc for every element and subelement
      def find_ifc_loop(entities)
        entities.each do |ent|
          if ent.is_a?(Sketchup::Group)
            check_ifc(ent)
            find_ifc_loop(ent.entities)
          elsif ent.is_a?(Sketchup::ComponentInstance)
            check_ifc(ent)
            find_ifc_loop(ent.definition.entities)
          else
            check_ifc(ent)
          end
        end
      end
    
      def check_ifc(ent)
        if ent.get_attribute "ifc", "guid"
          guid = ent.get_attribute "ifc", "guid"
          # possible other method, first collect into array, and THAN filter on type...
          #if @h_guid_list[guid]
          #  @h_guid_list[guid] << ent
          #else
          #  @h_guid_list[guid] = Array.new
          #  @h_guid_list[guid] << ent
          #end
          if ent.is_a?(Sketchup::Group)
            if @lib.geometry_to_bt_entity(@project, ent).nil?
              ### add_bt_entity(ent)
              if @h_guid_list[guid]
                @h_guid_list[guid][1] = ent
              else
                @h_guid_list[guid] = Array.new
                @h_guid_list[guid][1] = ent
              end
            end
          else
            if @lib.source_to_bt_entity(@project, ent).nil?
              ### add_bt_entity(ent)
              if @h_guid_list[guid]
                @h_guid_list[guid][0] = ent
              else
                @h_guid_list[guid] = Array.new
                @h_guid_list[guid][0] = ent
              end
            end
          end
        end
      end
    
      def add_planars
        @h_guid_list.each do |guid|
        
          # if no lost geometry, check if bt-entity exists with deleted source
          if guid[1][1].nil?
            unless guid[1][0].nil?
              find_guid = [0] #?????????????????????????
              find_bt_entity = nil
              @lib.entities.each do |bt_entity|
                if bt_entity.guid? == find_guid
                  find_bt_entity = bt_entity
                end
              end
              # if source deleted, add this face as new source
              # ? what if multiple faces with this guid exist??? 
              unless find_bt_entity.nil?
                if find_bt_entity.source.deleted?
                  find_bt_entity.source= guid[0]
                end
              end
            end
          else
            unless guid[1][0].nil? || guid[1][1].nil?
              require "bim-tools/lib/clsPlanarElement.rb"
              width = guid[1][1].get_attribute "ifc", "width"
              width = width.to_l#.to_mm
              offset = guid[1][1].get_attribute "ifc", "offset"
              offset = offset.to_l#.to_mm
              planar = ClsPlanarElement.new(@project, guid[1][0], width, offset, guid[0])
              planar.geometry=(guid[1][1])
              #planar.width= width.to_l.to_mm
              #planar.offset= offset.to_l.to_mm
              planar.name= guid[1][1].get_attribute "ifc", "name"
              planar.description= guid[1][1].get_attribute "ifc", "description"
              planar.element_type= guid[1][1].get_attribute "ifc", "type"
              output = planar.get_openings
              output[1].erase!
            end
          end
        end
      end
    
      def add_bt_entities(ent)
        if ent.get_attribute "ifc", "type"
          type = ent.get_attribute "ifc", "type"
          if type == "Wall" || type == "Floor" || type == "Roof"
    
            # this still works only for elements originally created with bim-tools
            require "bim-tools/lib/clsPlanarElement.rb"
            ### ClsPlanarElement.new(@project, source)
            
          end
        end
      end
    end
  end # module BimTools
end # module Brewsky
