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
        require 'bim-tools/lib/ObserverManager.rb'
        
        @aBtProjects = Array.new
        new_BtProject
        
        require 'bim-tools/ui/bt_dialog.rb'
        @btDialog = Bt_dialog.new(self)
        
        # start all UI elements: webdialog (?toolbar?)
        ClsBtUi.new(self)
        
        # Create the models observer to keep track on any changes in the active model(new, close)
        ObserverManager.add_models_observer(self)
       
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
      
        # Create the selection observer to the new model, to keep the dialog up-to-date
        ObserverManager.add_selection_observer(self, btProject)

        #Sketchup.active_model.selection.add_observer(MySelectionObserver.new(btProject, self))
      end
      # is it possible to completely “unload” the plugin during a session?
      # def destructor
    end
    
  end # module BimTools
end # module Brewsky
