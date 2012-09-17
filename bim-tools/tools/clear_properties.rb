#       clear_properties.rb
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

  # Function that takes an array of SketchUp elements as input, deletes all BIM properties for these elements,
  # and makes the source geometry visible and selected.
  #   parameters: array of SketchUp elements
  #   returns: array of SketchUp faces
  
  #module Bt_create
  class ClearProperties
    def initialize(project, entities)
      @project = project
      @model = Sketchup.active_model
      
      entities.each do |entity|
        bt_entity = nil
        if entity.is_a?(Sketchup::Group)
          bt_entity = @project.library.geometry_to_bt_entity(@project, entity)
        elsif entity.is_a?(Sketchup::Face)
          bt_entity = @project.library.source_to_bt_entity(@project, entity)
        end
        
        unless bt_entity.nil?
          bt_entity.self_destruct
          #geometry = bt_entity.geometry
          #source = bt_entity.source
          #source.attribute_dictionaries.delete 'ifc'
          #geometry.attribute_dictionaries.delete 'ifc'
          #source.hidden= false    
          #bt_entity.geometry= nil
          
          #@project.library.delete(bt_entity)
          #geometry.erase!
          
          
          # update connecting entities
          
        end
      end
      
    end
  end

end
