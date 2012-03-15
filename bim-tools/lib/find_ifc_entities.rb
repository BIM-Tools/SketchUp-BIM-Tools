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

# Function that searches the complete model for objects containing ifc attributes and adds these to the BIM-Tools library.
#   parameters: project
#   returns: -

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
      if ent.typename=="Group"
        check_ifc(ent)
        find_ifc_loop(ent.entities)
      elsif ent.typename=="ComponentInstance"
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
      if ent.typename == "Group"
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
      unless guid[0].nil? && guid[1].nil?
        require "bim-tools/lib/clsPlanarElement.rb"
        planar = ClsPlanarElement.new(@project, guid[1][0])
        planar.geometry=(guid[1][1])
        width = guid[1][1].get_attribute "ifc", "width"
        planar.width= width.to_l.to_mm
        offset = guid[1][1].get_attribute "ifc", "offset"
        planar.offset= offset.to_l.to_mm
        planar.name= guid[1][1].get_attribute "ifc", "name"
        planar.description= guid[1][1].get_attribute "ifc", "description"
        planar.element_type= guid[1][1].get_attribute "ifc", "type"
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
