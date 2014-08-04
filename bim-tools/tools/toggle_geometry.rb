#       toggle_geometry.rb
#       
#       Copyright (C) 2014 Jan Brouwer <jan@brewsky.nl>
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

    # Function that switches the visibility(hidden-status) between source faces and geometry.
    #   parameters: current bim-tools project
    
    class ToggleGeometry
      def initialize(project)
        @project = project
        @model = Sketchup.active_model
			end
      
      def activate
				
        # start undo section
        @model.start_operation("Toggle source/geometry", disable_ui=true)
        
        # toggle boolean value from true to false and vice versa
        @project.visible_geometry ^= true
        
        # store the value in the model
        @model.set_attribute "bim-tools", "visible_geometry", @project.visible_geometry        
        
        # switch visibility for all bt-entities
        @project.library.entities.each do |entity|
          unless entity.deleted?
            entity.geometry_visibility(@project.visible_geometry)
          end
        end
        @model.commit_operation # End of operation/undo section
        @model.active_view.refresh # Refresh model
        @model.select_tool(nil)
      end
    end # class ToggleGeometry
  end # module BimTools
end # module Brewsky
