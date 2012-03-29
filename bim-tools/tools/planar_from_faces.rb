#       planar_from_faces.rb
#       
#       Copyright (C) 2011 Jan Brouwer <jan@brewsky.nl>
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

# Function that takes an array of SketchUp elements as input, and creates planar objects from the faces in the array.
#   parameters: array of SketchUp elements
#   returns: array of planar objects

#module Bt_create
class PlanarFromFaces
  def initialize(project, a_sources)
    @project = project
    @model = Sketchup.active_model
    @a_sources = a_sources
    @a_planars = Array.new
  end
  
  def activate
    Sketchup.vcb_label = "Thickness"
    planar_from_faces(@project, @a_sources)
  end

  def planar_from_faces(project, a_sources)
  
    # require planar class
    require "bim-tools/lib/clsPlanarElement.rb"
  
    # start undo section
    @model.start_operation("Create planars", disable_ui=true) # Start of operation/undo section
  
    @project = project
    
    # first; create objects 
    a_sources.each do |source|

      # create planar object if source is a SketchUp face
      if source.typename == "Face"
        # check if a BIM-Tools entity already exists for the source face
        if @project.library.source_to_bt_entity(@project, source).nil?
          @a_planars << ClsPlanarElement.new(@project, source)
        end
      end
    end
    
    # clear the current selection to replace the selected source faces with geometry groups
    @model.selection.clear

    # second; create geometry for the created objects, to make sure all connections are known.
    @project.bt_entities_set_geometry(@a_planars)
    @a_planars.each do |planar|
    #  planar.set_geometry #planar class still missing this function!
    #  
      # add the geometry group to the selection
      @model.selection.add planar.geometry
    end
    
    
    @model.commit_operation # End of operation/undo section
    @model.active_view.refresh # Refresh model
    
    return @a_planars
  end
  
  # For this tool, allow vcb text entry while the tool is active.
  def enableVCB?
    return true
  end
  
  def onUserText(text, view)
    require 'bim-tools/tools/bt_entities_update.rb'
    begin
      width = text.to_l.to_mm
    rescue
      # Error parsing the text
      UI.beep
      # puts "Cannot convert #{text} to a Length"
      width = nil
      Sketchup::set_status_text "", SB_VCB_VALUE
    end
    return if !width
  
    @a_planars.each do |planar|
    
      # set the object's width to the user input for "thickness"
      planar.width= width
      
      # set the object's offset to half the width(based on a centered alignment)
      planar.offset= width/2
      
      # update the BIM-Tools elements based on the user input
      h_Properties = Hash.new
      h_Properties["width"] = planar.width.to_mm
      h_Properties["offset"] = planar.offset.to_mm
      bt_entities_update(@project, @a_planars, h_Properties)
    end
  end
  
  # on mouse click, cancel current tool and imitate select-tool.
  def onLButtonDown(flags, x, y, view)
    @model.select_tool nil
    view = @model.active_view
    ph = view.pick_helper
    ph.do_pick x,y
    @model.selection.clear
    @model.selection.add ph.all_picked
  end
  def onMButtonDown(flags, x, y, view)
    @model.select_tool nil
  end
  def onRButtonDown(flags, x, y, view)
    @model.select_tool nil
  end
end
