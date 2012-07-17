#       toolbar.rb
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

class BtToolbar
  def initialize(project)
    @project = project
    bt_toolbar = UI::Toolbar.new "BIM-Tools"

    cmd_bimtools = UI::Command.new("Open BIM-Tools window") {
      # dialog on close not nil but just not visible better? and not re-create but just make visible?
      if @dialog == nil
        require 'bim-tools/ui/bt_dialog.rb'
        @dialog = Bt_dialog.new(@project)
      else
        @dialog.close
        @dialog = nil
      end
    }

    cmd_planar_from_selection = UI::Command.new("Creates building elements from selected faces") {
      selection = Sketchup.active_model.selection
      if selection.length > 0
        require "bim-tools/tools/planar_from_faces.rb"
        
        planar_from_faces = PlanarFromFaces.new(@project, selection)
        Sketchup.active_model.select_tool planar_from_faces
        
        #planar_from_faces(@project, selection)
      end
    }
    
    # switch between source and geometry visibility
    cmd_toggle_geometry = UI::Command.new("Toggle between sources and geometry") {
      @project.toggle_geometry()
    }
    
    # Remove BIM properties from selection
    cmd_clear = UI::Command.new("Remove BIM properties from selection") {
      require "bim-tools/tools/clear_properties.rb"
      selection = Sketchup.active_model.selection
      ClearProperties.new(@project, selection)
    }

    cmd_bimtools.small_icon = "../images/bimtools_small.png"
    cmd_bimtools.large_icon = "../images/bimtools_large.png"
    cmd_bimtools.tooltip = "Open BIM-Tools window"
    cmd_bimtools.status_bar_text = "Open BIM-Tools window"
    # cmd_bimtools.menu_text = "Test"
    bt_toolbar = bt_toolbar.add_item cmd_bimtools

    cmd_planar_from_selection.small_icon = "../images/PlanarsFromFaces_small.png"
    cmd_planar_from_selection.large_icon = "../images/PlanarsFromFaces_large.png"
    cmd_planar_from_selection.tooltip = "Creates building elements from selected faces"
    cmd_planar_from_selection.status_bar_text = "Creates building elements from selected faces"
    bt_toolbar = bt_toolbar.add_item cmd_planar_from_selection
    
    cmd_toggle_geometry.small_icon = "../images/ToggleGeometry_small.png"
    cmd_toggle_geometry.large_icon = "../images/ToggleGeometry_large.png"
    cmd_toggle_geometry.tooltip = "Toggle between sources and geometry"
    cmd_toggle_geometry.status_bar_text = "Toggle between sources and geometry"
    bt_toolbar = bt_toolbar.add_item cmd_toggle_geometry
    
    cmd_clear.small_icon = "../images/clear_small.png"
    cmd_clear.large_icon = "../images/clear_large.png"
    cmd_clear.tooltip = "Remove BIM properties"
    cmd_clear.status_bar_text = "Remove BIM properties from selection"
    bt_toolbar = bt_toolbar.add_item cmd_clear

    bt_toolbar.show
  end
end
