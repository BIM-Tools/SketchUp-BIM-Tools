#       ObserverManager.rb
#       
#       Copyright (C) 2013 Jan Brouwer <jan@brewsky.nl>
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
  
    # The ObserverManager will keep track of all observers(create, add, remove) and the "observed" objects.
    # is needs 
    module ObserverManager
      extend self
      
      stored = Sketchup.read_default "bim-tools", "on_off"
      if stored.nil?
        Sketchup.write_default "bim-tools", "on_off", "off"
        @status = false
      elsif stored == "off"
        @status = false
      else
        @status = true
      end
      
      # key = observer
      # value = observed_object
      @observerList = Hash.new
      
      # there should always be max 1 entities_observer
      # it must be placed in this variable
      @entities_observer = nil
      
      def self.entities_observer
        return @entities_observer
      end
      
      def self.status
        return @status
      end
      
      # this method will add an observer
      def self.add(observer, observed)
        @observerList[observer] = observed
        if @status == true
          observed.add_observer(observer)
        end
      end
      
      # this method will unload and delete an observer
      # ??? should it delete, or only detach the observer ???
      def self.remove(observer)
        observed = @observerList[observer]
        observed.remove_observer observer
        @observerList.delete(observer)
      end
      
      # this method will load(add to "observed_object") all BIM-Tools observers
      def self.load
        @observerList.each do |observer, observed|
          observed.add_observer observer
        end
        Sketchup.write_default "bim-tools", "on_off", "on"
        @status = true
      end
      
      # this method will unload(remove from "observed_object") all BIM-Tools observers
      def self.unload
        cleanup
        @observerList.each do |observer, observed|
          observed.remove_observer observer
        end
        Sketchup.write_default "bim-tools", "on_off", "off"
        @status = false
      end
      
      # this method toggles between load and unload
      def self.toggle
        if @status == true
          self.unload
        else
          self.load
        end
      end
      
      # this method will clean up the observerlist
      # if "observed_object" does not exist than the record will be deleted from @observerList
      def self.cleanup
        #if Sketchup.active_model.selection[0].is_a? Sketchup::Entity then 'Yes' else 'No' end
        #@observerList.delete_if {|observer, observed| observed.deleted? } # wat als observed_object geen entity is???????????????????????/
        @observerList.delete_if do |observer, observed|
          
          # only check for deleted? if observed is an entity
          if observed.is_a? Sketchup::Entity
            return observed.deleted?
          else
            return false
          end
        end
      end
      
      def self.add_models_observer()
        observer = BtModelsObserver.new
        self.add(observer, Sketchup)
      end
      
      def self.add_selection_observer(btProject)
        observer = BtSelectionObserver.new(btProject)
        selection = btProject.model.selection
        self.add(observer, selection)
      end
      
      def self.add_entities_observer(btProject, active_entities)
        
        # entities observer should only be created when the active collection contains BT-entities
        bt_entities = btProject.library.array_remove_non_bt_entities(btProject, active_entities)
        unless bt_entities.length == 0
          #puts @entities_observer
          
          # check if an entities observer exists, if so, check if attached to the right entities object
          # if not, create and or attach an entities observer
          if @entities_observer.nil?
             #puts "entities observer == nil"
            @entities_observer = BtEntitiesObserver.new(btProject, active_entities)
            self.add(@entities_observer, active_entities)
            # puts "entities observer created"
          elsif active_entities == @observerList[@entities_observer]
             #puts "entities observer == active ent"
            #self.add(@entities_observer, active_entities)
            unless btProject == @entities_observer.project
              @entities_observer.project = btProject
              self.add(@entities_observer, active_entities)
            end
            #@observerList.delete(@entities_observer)
            #@entities_observer = BtEntitiesObserver.new(btProject, active_entities)
          else
            unless btProject == @entities_observer.project
              @entities_observer.project = btProject
            end
            #@observerList.delete(@entities_observer)
            #@entities_observer = BtEntitiesObserver.new(btProject, active_entities)
            self.add(@entities_observer, active_entities)
            # puts "entities observer re-attached"
             #puts "entities observer <> active ent + reattached"
          
          end
        else
          unless @entities_observer.nil?
            self.remove(@entities_observer)
          # else
          #   puts "no entities observer created, no bt_entities present"
          end
        end
      end
      
      # This is created only once in a session
      # This observer creates additional BtProjects when new/additional
      # models are activated and will allways be running
      # ??? could disabling this observer give any trouble ???
      # ??? should any checks be done on re-enabling ???
      class BtModelsObserver < Sketchup::AppObserver
        def onNewModel(model)
          Brewsky::BimTools.new_BtProject
        end
        def onOpenModel(model)
          Brewsky::BimTools.new_BtProject
        end
        
        # on close model, remove btProject?
        
      end # class BtAppObserver
      
      
      # This is created once for every active model
      # This observer keeps the btDialog updated based on the current selection
      class BtSelectionObserver < Sketchup::SelectionObserver
        attr_reader :observed
        def initialize(project)#bt_dialog, h_sections)
          @project = project
          @bimTools = Brewsky::BimTools
          @observed = Sketchup.active_model.active_entities
        end
        def onSelectionBulkChange(selection)
          selection_changed(selection)
        end # onSelectionBulkChange
        def onSelectionCleared(selection)
          selection_changed(selection)
        end # onSelectionCleared
        def selection_changed(selection)
          unless @bimTools.btDialog.nil?
            @bimTools.btDialog.update_sections(selection)
          end
          
          # ??? This should only be fired when the selection in the ACTIVE collection is changed ???
          if Sketchup.active_model.active_entities != @observed
            
            # reset the current active entities
            @observed = Sketchup.active_model.active_entities
          
            # Create / re-attach the entities observer for the new active collection
            ObserverManager.add_entities_observer(@project, @observed)
          end # unless
        end # selection_changed
      end # BtSelectionObserver
      
      # it could be enough to create this observer once and just link/unlink it to entities collections if needed
      # for now it is re-created every time the collection switches
      # This observer auto-updates the geometry
      # on open group/component: create new entitiesobserver for possible nested bim-tools entities
      class BtEntitiesObserver < Sketchup::EntitiesObserver
        attr_accessor :project
        def initialize(project, entities)
          @project = project
          @entities = entities
          @model = Sketchup.active_model
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
            @model = Sketchup.active_model
            @model.start_operation("Update BIM-Tools entities", disable_ui=true) # Start of operation/undo section
            if entity.is_a?(Sketchup::Face)
            
              # check if entity is part of a building element
              if bt_entity = @project.library.source_to_bt_entity(@project, entity)
              
              # this causes way too much overhead because every object is recreated multiple times
              
                # do not refresh geometry when only "hidden"-state is changed
                if bt_entity.source_hidden? == bt_entity.source.hidden?
                  
                  
                  
                  
                  # check if a tool is active that can change geometry
                  # or could the check better be reversed?
                  tools = Sketchup.active_model.tools
									id = tools.active_tool_id
                  if [21031, 21048, 21041, 21065, 21094, 21095, 21096, 21100, 21129, 21236, 21525].include? id
	                  puts "source changed"
										@project.source_changed(bt_entity)
                  end
                  # 21019 = EraseTool ???
                  # 21074 = PaintTool ???
                  # 21013 = PasteTool ???
                  # 21020 = SketchTool ???
                  
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
                  if bt_entity = @project.library.source_to_bt_entity(@project, source)
                    bt_entity.update_geometry
                  end
                end
              end
            end
            @model.commit_operation # End of operation/undo section
            @model.active_view.refresh # Refresh model
          end
        end
      end
      
      # Create the models observer to keep track on any changes in the open models(new, close)
      self.add_models_observer()
      
    end # module ObserverManager
  end # module BimTools
end # module Brewsky

#Brewsky::BimTools::ObserverManager.test
