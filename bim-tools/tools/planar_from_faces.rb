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

# require planar class
require "bim-tools/lib/clsPlanarElement.rb"

  def planar_from_faces(project, a_sources)
    # start undo section
    model = Sketchup.active_model
    model.start_operation("Create planars", disable_ui=true) # Start of operation/undo section
  
    @project = project
    a_planars = Array.new
    
    # first; create objects 
    a_sources.each do |source|

      #create planar object if source is a SketchUp face
      if source.typename == "Face"
        a_planars << ClsPlanarElement.new(@project, source)
      end
    end

    # second; create geometry for the created objects, to make sure all connections are known.
    a_planars.each do |planar|
      planar.set_geometry #planar class still missing this function!
    end
    
    model.commit_operation # End of operation/undo section
    model.active_view.refresh # Refresh model
    
    return a_planars
  end
#end
