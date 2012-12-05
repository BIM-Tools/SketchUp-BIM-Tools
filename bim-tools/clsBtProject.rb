#       clsBtProject.rb
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

    # basic project class
    # Object "parallel" to sketchup "active_model" object
    # optional parameters: id, name, description, ?ownerhistory?
    class ClsBtProject
    
      # attributes accessible from outside class
      # attr_accessor :id, :name, :description
      # when to use self.xxx?
      attr_reader :model, :guid, :name, :description, :site_guid, :site_name, :site_description, :building_guid, :building_name, :building_description, :author, :organisation_name, :organisation_description
      
      def initialize(id=nil, name=nil, description=nil)
        require 'bim-tools/lib/clsDefaultValues.rb'
        require 'bim-tools/clsBtLibrary.rb'
        require 'bim-tools/lib/find_ifc_entities.rb'
        @model = Sketchup.active_model
        @project = self
        @guid = id
        @site_guid = nil
        @building_guid = nil
        
        # load default values
        @default = ClsDefaultValues.new
        
        # set guid
        set_guid(@guid)
        set_site_guid
        set_building_guid
        
        # basic project properties
        set_name #@name = @default.get("project_name")
        set_description #@description = @default.get("project_description")
        set_site_name #@site_name = @default.get("site_name")
        set_site_description #@site_description = site_description= #@site_description = @default.get("site_description")
        set_building_name #@building_name = @default.get("building_name")
        set_building_description #@building_description = @default.get("building_description")
        set_author #@author = @default.get("author")
        set_organisation_name #@organisation_name = @default.get("organisation_name")
        set_organisation_description #@organisation_description = @default.get("organisation_description")
        
        
        # set initial value for toggle button
        toggle_value = @model.get_attribute "bim-tools", "visible_geometry"
        
        if toggle_value.nil?
          # variable keeps track of visibility source or geometry
          @visible_geometry = true
          @model.set_attribute "bim-tools", "visible_geometry", "true"
        elsif toggle_value == "false"
          @visible_geometry = false
        else
          @visible_geometry = true
        end
        
        @lib = ClsBtLibrary.new # would ClsBtEntities be a better name?
        
        @source_tracker = SourceTracker.new(self)
        #id=#("id") # do or do not use "project" in method names?
        name=#("name")
        description=#("description")
        
        # When creating a new project, check if there are any IFC entities present in the current SketchUp model
        ClsFindIfcEntities.new(self)
      
        # Create the entities observer for the new project, to auto-update the geometry
        @active_entities = Sketchup.active_model.active_entities
        ObserverManager.add_entities_observer(@project, @active_entities)
        
        return self
      end
      
      def source_changed(bt_entity)
        @source_tracker.refresh_geometry(bt_entity)
      end
      
      # updates geometry for input bt_entities + connecting bt_entities
      def bt_entities_set_geometry(a_bt_entities)
        to_update = Array.new
        
        # find all connecting bt_entities and add to array
        a_bt_entities.each do |bt_entity|
          face = bt_entity.source
          unless face.deleted?
            face.edges.each do |edge|
              edge.faces.each do |face|
                bt_entity = @lib.source_to_bt_entity(@project, face)
                unless bt_entity.nil?
                  to_update << bt_entity
                end
              end
            end
          end
        end
        
        # remove all duplicates from array
        to_update.uniq!
        
        # update geometry
        to_update.each do |bt_entity|
          bt_entity.update_geometry
        end
      end
      
      # switch between source and geometry visibility
      def toggle_geometry()
        # start undo section
        @model.start_operation("Toggle source/geometry", disable_ui=true) # Start of operation/undo section
        if @visible_geometry == true
          @visible_geometry = false
          @model.set_attribute "bim-tools", "visible_geometry", "false"
        else
          @visible_geometry = true
          @model.set_attribute "bim-tools", "visible_geometry", "true"
        end
        
        @lib.entities.each do |entity|
          unless entity.deleted?
            entity.geometry_visibility(@visible_geometry)
          end
        end
        @model.commit_operation # End of operation/undo section
        @model.active_view.refresh # Refresh model
        
        # write true or false as attribute
      end
      def visible_geometry?
        return @visible_geometry
      end
      def set_guid(guid)
        if guid.nil?
        
          # check if active_model already contains BtProject / IFC data and pass these to the project instance.
          if @guid.nil?
            @guid = @model.get_attribute "ifc", "IfcProject_GlobalId", nil
          end
        
          # if id still empty, generate new id
          if @guid.nil?
            @guid = new_guid
            @model.set_attribute "ifc", "IfcProject_GlobalId", @guid
          end
        else
        
          # if id == allowed guid-string
          @guid = guid
        end
      end
      def set_site_guid()
        # check if active_model already contains BtProject / IFC data and pass these to the project instance.
        if @site_guid.nil?
          @site_guid = @model.get_attribute "ifc", "IfcSite_GlobalId", nil
        end
      
        # if id still empty, generate new id
        if @site_guid.nil?
          @site_guid = new_guid
          @model.set_attribute "ifc", "IfcSite_GlobalId", @site_guid
        end
      end
      def set_building_guid()
        # check if active_model already contains BtProject / IFC data and pass these to the project instance.
        if @building_guid.nil?
          @building_guid = @model.get_attribute "ifc", "IfcBuilding_GlobalId", nil
        end
      
        # if id still empty, generate new id
        if @building_guid.nil?
          @building_guid = new_guid
          @model.set_attribute "ifc", "IfcBuilding_GlobalId", @building_guid
        end
      end
      
      # returns a new guid
      # shouldn't this function be in some sort of basic library?
      def new_guid
        guid = '';22.times{|i|guid<<'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_$'[rand(64)]}
        return guid
      end
  #    def name=(name=nil)
  #    
  #      # check if active_model already contains BtProject / IFC data and pass these to the project instance.
  #      if name.nil?
  #        @name = @model.get_attribute "ifc", "IfcProject_Name", nil
  #      else
  #        @name = name
  #        @model.set_attribute "ifc", "IfcProject_Name", @name
  #      end
  #    end
  #    def description=(description=nil)
  #      
  #      # check if active_model already contains BtProject / IFC data and pass these to the project instance.
  #      if description.nil?
  #        @description = @model.get_attribute "ifc", "IfcProject_Description", nil
  #      else
  #        @description = description
  #        @model.set_attribute "ifc", "IfcProject_Description", @description
  #      end
  #    end
      
      # this method is used to update / set the value of several project-data-fields(such as name and description)
      def set_project_data(new_value, old_value, ifc_name, default_name)
        # new_value = (optional) new name
        # old_value = current name
        # ifc_name = name of the IFC value field in the project´s ifc attributes
        # default_name = name of the default value field in the config file
        # output_value = new value after checks have been completed
        if new_value.nil?
          if old_value.nil?
            output_value = @model.get_attribute "ifc", ifc_name, nil
            if output_value.nil?
              output_value = @default.get(default_name)
              if output_value.nil?
                @model.set_attribute "ifc", ifc_name, ""
              else
                @model.set_attribute "ifc", ifc_name, output_value
              end
            else
              @model.set_attribute "ifc", ifc_name, output_value
            end
          else
            @model.set_attribute "ifc", ifc_name, output_value
          end
        else
          output_value = new_value
          @model.set_attribute "ifc", ifc_name, output_value
        end
        return output_value
      end
      
      def set_name(name=nil)
        @name = set_project_data(name, @name, "IfcName", "project_name")
      end
      def set_description(description=nil)
        @description = set_project_data(description, @description, "IfcDescription", "project_description")
      end
      def set_site_name(site_name=nil)
        @site_name = set_project_data(site_name, @site_name, "IfcSite_Name", "site_name")
      end
      def set_site_description(site_description=nil)
        @site_description = set_project_data(site_description, @site_description, "IfcSite_Description", "site_description")
      end
      def set_building_name(building_name=nil)
        @building_name = set_project_data(building_name, @building_name, "IfcBuilding_Name", "building_name")
      end
      def set_building_description(building_description=nil)
        @building_description = set_project_data(building_description, @building_description, "IfcBuilding_Description", "building_description")
      end
      def set_author(author=nil)
        @author = set_project_data(author, @author, "IfcAuthor", "author")
      end
      def set_organisation_name(organisation_name=nil)
        @organisation_name = set_project_data(organisation_name, @organisation_name, "IfcOrganisation_Name", "organisation_name")
      end
      def set_organisation_description(organisation_description=nil)
        @organisation_description = set_project_data(organisation_description, @organisation_description, "IfcOrganisation_Description", "organisation_description")
      end
      def set_observers

        # this is only for the "root" entities object! not for group/component entities!!!!!!!!!!!!!!
        # is this observer needed??????
        project_observer = ProjectObserver.new(self)
        entities = Sketchup.active_model.entities
        ObserverManager.add(project_observer, entities)
       
      #  Sketchup.active_model.entities.add_observer(ProjectObserver.new(self))
      #  Sketchup.active_model.selection.add_observer(SelectionObserver.new)###################################################
      end
      
      def library
        return @lib
      end
      
      def source_recovery
        @model = Sketchup.active_model
        @entities = @model.entities
        h_guid = Hash.new
        #a_faces = Array.new
        #a_faces = get_all_faces(@entities, Array.new)
        a_faces = get_active_faces
        a_faces.each do |face|
          if face.get_attribute "ifc", "guid"
            bt_entity = @lib.source_to_bt_entity(self, face)
            if bt_entity.nil?
              guid = face.get_attribute "ifc", "guid"
              if h_guid.has_key?(guid)
                h_guid[guid] << face
              else
                h_guid[guid] = Array.new
                h_guid[guid] << face
              end
            end
          end
        end
        #h_guid.each {|key, value| puts "#{key} is #{value}" }
        h_guid.each do |guid, a_faces|
          bt_entity = nil
          # find bt_entity with guid == guid
          @lib.entities.each do |entity|
            if entity.guid? == guid
              bt_entity = entity
            end
          end
          if bt_entity.nil?
            a_faces.each do |face|
              require "bim-tools/lib/clsPlanarElement.rb"
              planar = ClsPlanarElement.new(self, face)
              planar.set_geometry
            end
          else
            a_faces.each do |face|
              if bt_entity.source.deleted?
                bt_entity.source= face #maybee find the best face?
                bt_entity.update_geometry
              else
                #@lib.duplicate_bt_entity(bt_entity, face)
                #require "bim-tools/lib/clsPlanarElement.rb"
                #planar = ClsPlanarElement.new(self, face)
                #planar.set_geometry
                props = bt_entity.properties_editable
          #props.each {|key, value| puts "#{key} is #{value}" }
                require "bim-tools/lib/clsPlanarElement.rb"
                planar = ClsPlanarElement.new(self, face)
                planar.set_properties(props)
                planar.set_geometry
                #@lib.entities do |ent|
                #  puts ent.width
                #end
              end
            end
          end
        end
      end  
      
      # recursive loop that returns an array of all faces in active_model
      def get_all_faces(entities, a_faces)
        entities.each do |ent|
          if ent.is_a?(Sketchup::Group)
            a_faces = a_faces + get_all_faces(ent.entities, a_faces)
          elsif ent.is_a?(Sketchup::ComponentInstance)
            a_faces = a_faces + get_all_faces(ent.definition.entities, a_faces)
          else
            if ent.is_a?(Sketchup::Face)
              a_faces << ent
            end
          end
        end
        return a_faces
      end
      
      # NOT recursive version, only searches in active collection!
      def get_active_faces()
        @model = Sketchup.active_model
        entities = @model.active_entities
        a_faces = Array.new
        entities.each do |ent|
          if ent.is_a?(Sketchup::Face)
            a_faces << ent
          end
        end
        return a_faces
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
            
              # ? if deleted, find lost objects ???
              if bt_entity.deleted?
                #scan total project for "lost" bim elements
                @project.source_recovery
                #ClsFindIfcEntities.new(@project)
              else
                bt_entity.source.edges.each do |edge|
                
                  # ? if deleted, find lost objects ???
                  if edge.deleted?
                    #scan total project for "lost" bim elements
                  source_recovery
                  #  ClsFindIfcEntities.new(@project)
                  else
                    edge.faces.each do |face|
                      if face != bt_entity.source
                        con_bt_entity = @project.library.source_to_bt_entity(@project, face)
                        if con_bt_entity.nil?
                          
                          #scan total project for "lost" bim elements
                          ClsFindIfcEntities.new(@project)
                          
                          #after scanning, re-try adding the object
                          con_bt_entity = @project.library.source_to_bt_entity(@project, face)
                          unless con_bt_entity.nil?
                            @a_con_entities << con_bt_entity
                          end
                        else
                          @a_con_entities << con_bt_entity
                        end
                      end
                    end
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
    end
  end # module BimTools
end # module Brewsky
