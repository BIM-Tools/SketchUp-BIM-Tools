#       clsBtSelection.rb
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

module Brewsky::BimTools

  # Object based on Sketchup.active_model.selection that manages selected BIM-Tools entities.
  # is only active as part of a webdialog???
  
  class ClsBtSelection
    def initialize(project, dialog)
      @project = project
      @dialog = dialog
      @selection = Sketchup.active_model.selection
    end
    
    # returns an array containing all BIM-Tools entities in the selection.
    def btEntities?
      bt_entities = @project.library.array_remove_non_bt_entities(@project, @selection)
    end
    
    # returns a hash containing all properties common to the selected object
    # types, with only values for the properties that are the same in all
    # selected entities, other values will be "..."? or nil?
    def common_properties
    
      # if not all entities are BIM-Tools entities, return nil
      if btEntities?.length != @selection.length
        return nil
      else
        h_common_properties = Hash.new
      
        # make a list of all common properties
        common_keys = nil
        btEntities?.each do |bt_entity|
          a_prop_fixed_keys = bt_entity.properties_fixed.keys
          if common_keys == nil
            common_keys = a_prop_fixed_keys
          else
            common_keys = common_keys & a_prop_fixed_keys # intersect both arrays
          end
        end
        
        if common_keys != nil
          # find which values in common properties are equal for all entities
          common_keys.each do |key|
            prop_value = nil #watch out! properties could also be nil!
            btEntities?.each do |bt_entity|
              if prop_value.nil?
                prop_value = bt_entity.properties_fixed[key]
              elsif bt_entity.properties_fixed[key] != prop_value
                prop_value = "..."
                break
              end
            end
            h_common_properties[key] = prop_value
          end
        end
        return h_common_properties
      end
    end
  
    def common_properties_editable
    
      # if not all entities are BIM-Tools entities, return nil
      if btEntities?.length != @selection.length
        return nil
      else
        h_common_properties = Hash.new
      
        # make a list of all common properties
        common_keys = nil
        btEntities?.each do |bt_entity|
          a_prop_editable_keys = bt_entity.properties_editable.keys
          if common_keys == nil
            common_keys = a_prop_editable_keys
          else
            common_keys = common_keys & a_prop_editable_keys # intersect both arrays
          end
        end
        
        if common_keys != nil
          # find which values in common properties are equal for all entities
          common_keys.each do |key|
            prop_value = true
            first = true
            btEntities?.each do |bt_entity|
              if first == true
                first = false
                prop_value = bt_entity.properties_editable[key]
              elsif bt_entity.properties_editable[key] != prop_value
          
                # if value is "select" form element array, and there are different values, than add ... to front of array
                if prop_value.kind_of?(Array)
                prop_value.insert(0, "...") 
                else
                prop_value = "..."
                end
                break
              end
            end
            h_common_properties[key] = prop_value
          end
        end
        return h_common_properties
      end
    end
  end

end
