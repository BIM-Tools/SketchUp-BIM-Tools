#       clsWallsFromEdges.rb
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

  require 'bim-tools/ui/clsDialogSection.rb'
  
  class ClsWallsFromEdges < ClsDialogSection
    def initialize(dialog, id)
      @dialog = dialog
      @id = id.to_s
      @project = dialog.project
      @status = true
      @name = "WallsFromEdges"
      @title = "Create walls from edges"
      @buttontext = "Create walls from edges"
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
          require "bim-tools/tools/walls_from_edges.rb"
  
          #split string into separate values
          a_form_data = split_string(params)
          
          # validate data from html form
          h_Properties = extract_data(a_form_data)
  
  
          a_edges = Array.new
          selection.each do |entity|
            if entity.is_a?(Sketchup::Edge)
              a_edges << entity
            end
          end
          bt_entities = WallsFromEdges.new(@project, a_edges, h_Properties)
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
        if entity.is_a?(Sketchup::Edge)
          edges = true
          break
        end
      end
      if edges == false
        @status = false
        return "
  <h2>No edges selected</h2>
        "
      else
        @status = true
        return "
  <form id='" + @name + "' name='" + @name + "' action='skp:" + @name + "@true'>
  " + html_properties_editable + html_properties_fixed + "
  <input type='submit' name='submit' id='submit' value='" + @buttontext + "' />
  </form>
        "
      end
    end
  
    def html_properties_editable
      sel = @dialog.selection
      html = "
            <label for='height'>Height:</label>
            <input name='height' type='text' id='height' value='2400' />
            <label for='width'>Width:</label>
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

end
