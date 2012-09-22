#       bim-tools.rb
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

module Brewsky::BimTools
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
      
      ClsBtUi.new(self) # start all UI elements: webdialog (?toolbar?)
      
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
   # def set_btDialog(btDialog)

    #end
    #def add_BtProject(btProject)
    #  @aBtProjects << btProject
    #end
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
  end
  class MySelectionObserver < Sketchup::SelectionObserver
      def initialize(project, bimTools)#bt_dialog, h_sections)
        @project = project
        @bimTools = bimTools
        # UI.messagebox("@project: " + @project.to_s)
        #@bt_dialog = bimTools.btDialog
        # UI.messagebox("@bt_dialog: " + @bt_dialog.to_s)
        #@entityInfo = entityInfo
        #@wallsfromedges = wallsfromedges
        #@h_sections = bimTools.btDialog.h_sections
      end
      def onSelectionBulkChange(selection)
      
        # open menu entity_info als de selectie wijzigt
        unless @bimTools.btDialog.nil?
          @bimTools.btDialog.update_sections(selection)
        end
      end
      def onSelectionCleared(selection)
        unless @bimTools.btDialog.nil?
          @bimTools.btDialog.update_sections(selection)
        end
      end
  end

end
