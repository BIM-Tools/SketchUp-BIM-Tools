#       planar_from_faces.rb
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

  # Function that takes an array of SketchUp elements as input, and creates planar objects from the faces in the array.
  #   parameters: array of SketchUp elements
  #   returns: array of planar objects
  
  #module Bt_create
  class PlanarFromFaces
    def initialize(project, a_sources, h_properties=nil)
      @project = project
      @model = Sketchup.active_model
      @a_sources = a_sources
      if h_properties.nil?
        @h_properties = Hash.new
      else
        @h_properties = h_properties
      end
      
      # set width value
      if @h_properties["width"]
        @width = @h_properties["width"].mm
      else
        @width = nil
      end   
       
      # set offset value
      if @h_properties["offset"]
        @offset = @h_properties["offset"].mm
      else
        @offset = nil
      end
      
      @a_planars = Array.new
    end
    
    def activate
      return planar_from_faces(@project, @a_sources)
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
        if source.is_a?(Sketchup::Face)
          # check if a BIM-Tools entity already exists for the source face
          if @project.library.source_to_bt_entity(@project, source).nil?
            @a_planars << ClsPlanarElement.new(@project, source, @width, @offset)
          end
        end
      end
      
      # clear the current selection to replace the selected source faces with geometry groups
      @model.selection.clear
  
      # second; create geometry for the created objects, to make sure all connections are known.
      @project.bt_entities_set_geometry(@a_planars)
      @a_planars.each do |planar|
  
        # add the geometry group to the selection
        @model.selection.add planar.geometry
      end
      @model.commit_operation # End of operation/undo section
      @model.active_view.refresh
      
      # activate select tool
      Sketchup.send_action(21022)
      return @a_planars
    end
  end

end
