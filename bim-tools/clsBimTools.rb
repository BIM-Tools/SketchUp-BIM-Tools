#       bim-tools.rb
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
    # BimTools initialisation class
    class ClsBimTools
      attr_reader :aBtProjects, :btDialog

      def initialize
        require 'bim-tools/clsBtProject.rb'
        require 'bim-tools/ui/clsBtUi.rb'
        
        @aBtProjects = Array.new
        new_BtProject
        
        require 'bim-tools/ui/bt_dialog.rb'
        @btDialog = Bt_dialog.new(self)
        
        # start all UI elements: webdialog (?toolbar?)
        ClsBtUi.new(self)
        
       # Attach the observer
       Sketchup.add_observer(BtAppObserver.new(self))
       
      end
      def active_BtProject
        @aBtProjects.each do |btProject|
          if btProject.model == Sketchup.active_model
            return btProject
          end
        end
      end
      def new_BtProject
        btProject = ClsBtProject.new
        @aBtProjects << btProject
      
        # Attach selection observer to the new model.
        Sketchup.active_model.selection.add_observer(MySelectionObserver.new(btProject, self))
      end
      # is it possible to completely “unload” the plugin during a session?
      # def destructor
    end
    
    # This observer creates additional BtProjects when new/additional models are activated
    class BtAppObserver < Sketchup::AppObserver
      def initialize(bimTools)
        @bimTools = bimTools
      end
      def onNewModel(model)
        @bimTools.new_BtProject
      end
      def onOpenModel(model)
        @bimTools.new_BtProject
      end
      
      # on close model, remove btProject?
    end
    
    # This observer keeps the btDialog updated based on the current selection
    class MySelectionObserver < Sketchup::SelectionObserver
      def initialize(project, bimTools)#bt_dialog, h_sections)
        @project = project
        @bimTools = bimTools
        @active_entities = Sketchup.active_model.active_entities
      end
      def onSelectionBulkChange(selection)
        selection_changed(selection)
      end
      def onSelectionCleared(selection)
        selection_changed(selection)
      end
      def selection_changed(selection)
        unless @bimTools.btDialog.nil?
          @bimTools.btDialog.update_sections(selection)
        end
        update_active_entities
      end
      def update_active_entities
        unless Sketchup.active_model.active_entities == @active_entities
          @active_entities = Sketchup.active_model.active_entities
          @active_entities.add_observer(BtEntitiesObserver.new(@project))
        end
      end
    end

    # on open group/component: create new entitiesobserver for possible nested bim-tools entities
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
        unless entity.deleted?
          if entity.is_a?(Sketchup::Face)
          
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
            else
              guid = entity.get_attribute "ifc", "guid"
              unless guid.nil?
                puts "Search for missing faces"
                # only start this when faces are deleted?
                @project.source_recovery
              end
            end
          elsif entity.is_a?(Sketchup::ComponentInstance)
            unless entity.glued_to.nil?
              source = entity.glued_to
              
              # run only if added entity cuts_opening
              if entity.definition.behavior.cuts_opening?
              
                # check if entity is part of a building element
                bt_entity = @project.library.source_to_bt_entity(@project, source)
                
                # if it is a bt-entity, redraw geometry
                unless bt_entity.nil?
                  bt_entity.update_geometry
                end
              end
            end
          end
        end
      end
    end
  end # module BimTools
end # module Brewsky
