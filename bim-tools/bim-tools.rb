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

module FreeBuilder  # <-- Main project namespace
  module Bim_Tools  # <-- BIM project namespace

    require 'sketchup.rb' # needed here?
    require 'bim-tools\ObjectLibrary.rb'
    require 'bim-tools\parts\opening.rb'

    # Show the Ruby Console at startup
    # Sketchup.send_action "showRubyPanel:"
     
    # Create the bim-tools objects library, keeps track of all bim-tools objects
    # Should this be a global???
    @lib = ObjectLibrary.new

    # Attach App observer --> To do if open existing model, in current session
    class MyAppObserver < Sketchup::AppObserver
      def onOpenModel(model)
        require 'bim-tools\ObjectLibrary.rb'
        @lib = ObjectLibrary.new 
        
        #start opening observer
        Sketchup.active_model.entities.add_observer(MyEntitiesObserver.new(@lib))
        
      end
    end
    # Attach the observer
    Sketchup.add_observer(MyAppObserver.new)

    lib = @lib

    #Create webdialog with BIM tools
    def self.bt_window(lib)
      require 'bim-tools\bt_dialog.rb'
      window = Bt_dialog.new(lib)
    end
		
    #fill all ifc settings with default values
    def self.defaults()
      require 'bim-tools\defaults.rb'
      Set_defaults.new
    end
    	
    #start opening observer
    Sketchup.active_model.entities.add_observer(MyEntitiesObserver.new(lib))
    
    # Add a menu item to launch BIM Tools webdialog.
    UI.menu("PlugIns").add_item("BIM Tools") {
      FreeBuilder::Bim_Tools::defaults
      FreeBuilder::Bim_Tools::bt_window(lib)
    }

    # Auto launch bim-tools
    # FreeBuilder::Bim_Tools::defaults
    # FreeBuilder::Bim_Tools::bt_window(lib)

  end
end
