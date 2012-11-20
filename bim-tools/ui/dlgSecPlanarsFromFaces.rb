#       dlgSecPLanarsFromFaces.rb
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
    require 'bim-tools/ui/clsDialogSection.rb'

    class ClsDlgSecPlanarsFromFaces < ClsDialogSection
      def initialize(dialog, id)
        @dialog = dialog
        @id = id.to_s
        #@project = dialog.project
        @status = true
        @name = "PlanarsFromFaces"
        @title = "Create thick faces"
        @buttontext = "Create thick faces"
        @width = "-"
        @offset = "-"
        @volume = "-"
        @guid = "-"
        @html_content = html_content
        callback
      end
    
      #action to be started on webdialog form submit
      def callback
        @dialog.webdialog.add_action_callback(@name) {|dialog, params|
          width = 300
          height = 2400
          offset = 150
          selection = Sketchup.active_model.selection
          if selection.length > 0
            require "bim-tools/tools/planar_from_faces.rb"
    
            #split string into separate values
            a_form_data = split_string(params)
            
            # validate data from html form
            h_Properties = extract_data(a_form_data)
            #h_Properties = nil
    
            #a_sources = Array.new
            #selection.each do |entity|
            #  if entity.typename == "Face"
            #    a_sources << entity
            #  end
            #end
            
            
            planar_from_faces = PlanarFromFaces.new(@dialog.project, selection, h_Properties)
            
            #hmmmm, should one tool need to activate an other????
            bt_entities = planar_from_faces.activate
            
            #Sketchup.active_model.select_tool planar_from_faces
            
            #        planar = ClsPlanarElement.new(@project, source)
            #walls_from_edges = WallsFromEdges.new(@project, a_sources)#, h_Properties)
          end
          self.update(bt_entities)
        }
      end
      
      # update webdialog based on selected entities
      def update(entities)
        @html_content = html_content
        refresh_dialog
      end
      
      def html_content
        edges = false
        Sketchup.active_model.selection.each do |entity|
          if entity.is_a?(Sketchup::Face)
            edges = true
            break
          end
        end
        if edges == false
          @status = false
          return "
    <h2>No faces selected</h2>
          "
        else
          @status = true
          return "
    <form id='" + @title + "' name='" + @name + "' action='skp:" + @name + "@true'>
    " + html_properties_editable + html_properties_fixed + "
    <input type='submit' name='submit' id='submit' value='" + @buttontext + "' />
    </form>
          "
        end
      end
    
      def html_properties_editable
        sel = @dialog.selection
        html = "
              <label for='width'>Thickness:</label>
              <input name='width' type='text' id='width' value='300' />
              <label for='offset'>Offset:</label>
              <input name='offset' type='text' id='offset' value='150' />
              "
        return html
      end
    
      def html_properties_fixed
        sel = @dialog.selection
        html = ""
        return html
      end
    end
  end # module BimTools
end # module Brewsky
