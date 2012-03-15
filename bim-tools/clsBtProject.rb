#       clsBtProject.rb
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

# basic project class
# Object "parallel" to sketchup "active_model" object
# optional parameters: id, name, description, ?ownerhistory?
class ClsBtProject

  # attributes accessible from outside class
  # attr_accessor :id, :name, :description
  # when to use self.xxx?

  def initialize(id=nil, name=nil, description=nil)
    @model = Sketchup.active_model
    require 'bim-tools/clsBtLibrary.rb'
    require 'bim-tools/lib/find_ifc_entities.rb'
    @lib = ClsBtLibrary.new # would ClsBtEntities be a better name?
    
    # variable keeps track of visibility source or geometry
    @visible_geometry = true
    @source_tracker = SourceTracker.new(self)
    #set_id(id) # do or do not use "project" in method names?
    #set_name(name)
    #set_description(description)
    
    # When creating a new project, check if there are any IFC entities present in the current SketchUp model
    ClsFindIfcEntities.new(self)
    
    #set observers
    Sketchup.active_model.entities.add_observer(BtEntitiesObserver.new(self))
    
    #testing
    #Sketchup.active_model.set_attribute "ifc", "IfcProject_GlobalId", "632791r834"
    # ownerhistory = model.get_attribute "ifc", "IfcProject_OwnerHistory", nil
    return self
  end
  
  def source_changed(bt_entity)
    @source_tracker.refresh_geometry(bt_entity)
  end
  
  # switch between source and geometry visibility
  def toggle_geometry()
    # start undo section
    model = Sketchup.active_model
    model.start_operation("Toggle source/geometry", disable_ui=true) # Start of operation/undo section
    if @visible_geometry == true
      @visible_geometry = false
    else
      @visible_geometry = true
    end
    
    @lib.entities.each do |entity|
      if entity.deleted? == false
        entity.geometry_visibility(@visible_geometry)
      end
    end
    model.commit_operation # End of operation/undo section
    model.active_view.refresh # Refresh model
    
    # write true or false as attribute
  end
  def visible_geometry?
    return @visible_geometry
  end
  def set_id(id)
  
    # check if active_model already contains BtProject / IFC data and pass these to the project instance.
    @id = @model.get_attribute "ifc", "IfcProject_GlobalId", nil
    
    # if id == allowed guid-string
    #   @id = id
    # else
    #   if @id does not exist
    #     generate new guid
    #     @id = guid
  end
  def set_name(name)
  
    # check if active_model already contains BtProject / IFC data and pass these to the project instance.
    @name = @model.get_attribute "ifc", "IfcProject_Name", nil
    
    # if name == string
    #   @name = name
    # else
    #   get default value for name
    #   @name = default
  end
  def set_description(description)
    
    # check if active_model already contains BtProject / IFC data and pass these to the project instance.
    @description = @model.get_attribute "ifc", "IfcProject_Description", nil
    
    # if description == string
    #   @description = description
    # else
    #   get default value for description
    #   @description = default
  end
  def set_observers
    Sketchup.active_model.entities.add_observer(ProjectObserver.new(self))
  #  Sketchup.active_model.selection.add_observer(SelectionObserver.new)###################################################
  end
  def get_id
    return @id
  end
  def get_name
    return @name
  end
  def get_description
    return @description
  end
  def library
    return @lib
  end

  private

  def ifcExport

    # create new exporter object
  end


  # this object is created to collect changes to objects within a short period and update all the geometry ONCE afterwards.
  # a separate class might not be needed here, it could also be a few extra methods for the project class...
  class SourceTracker
    def initialize(project)
      @project = project
      @delay = nil
      @a_entities = Array.new
    end
    def refresh_geometry(bt_entity)
      if @delay != nil
        UI.stop_timer( @delay )
      end
      @a_entities << bt_entity
      @delay = UI.start_timer( 0.001, false ) {
        UI.stop_timer( @delay )
        #start undo section
        model = Sketchup.active_model
        model.start_operation("Update BIM-Tools elements", disable_ui=true) # Start of operation/undo section
        @a_con_entities = Array.new
        @a_entities.uniq!
        
        # find all connecting elements that also need updated connections
        @a_entities.each do |bt_entity|
          bt_entity.source.edges.each do |edge|
            edge.faces.each do |face|
              if face != bt_entity.source
                con_bt_entity = @project.library.source_to_bt_entity(@project, face)
                @a_con_entities << con_bt_entity
              end
            end
          end
        end

        # add all changed AND connecting elements to the array and remove duplicates
        @a_entities = @a_entities + @a_con_entities
        @a_entities.uniq!
        
        # first reset the boundaries for all objects to make sure all connections can get calculated properly
        @a_entities.each do |bt_entity|
          bt_entity.set_planes
        end
        
        # then reset geometry
        @a_entities.each do |bt_entity|
          bt_entity.update_geometry
        end
        
        model.commit_operation # End of operation/undo section
        model.active_view.refresh # Refresh model
      }
    end
  end
  
  class BtEntitiesObserver < Sketchup::EntitiesObserver
    def initialize(project)
      @project = project
    end
    
    # what to do when component is placed? cut hole if possible.
    def onElementAdded(entities, entity)

      # if cutting-component?
      # if glued?
      # if glued to cuttable object?
      # then cut hole + convert component to btObject
    end
    
    # what to do if element is changed, and check if part of BtEntity.
    def onElementModified(entities, entity)
      if entity.typename == "Face"
      
        # check if entity is part of a building element
        bt_entity = @project.library.source_to_bt_entity(@project, entity)
        
        # this causes way too much overhead because every object is recreated multiple times
        if bt_entity != nil
        
          # do not refresh geometry when only "hidden"-state is changed
          if bt_entity.source_hidden? == bt_entity.source.hidden?
            @project.source_changed(bt_entity)
          else
            bt_entity.source_hidden = bt_entity.source.hidden?
          end
        end
      end
    end
  end
end
