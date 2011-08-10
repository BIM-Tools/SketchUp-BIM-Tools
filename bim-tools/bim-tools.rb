#       bim-tools.rb
#       
#       Copyright 2011 Jan Brouwer <jan@brewsky.nl>
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

    # First we pull in the standard API hooks.
    require 'sketchup.rb'

    # Show the Ruby Console at startup so we can
    # see any programming errors we may make.
    Sketchup.send_action "showRubyPanel:"

    #Create webdialog with BIM tools
    def self.bt_window()
    	require 'bim-tools\bt_dialog.rb'
			window = Bt_dialog.new
    end
		
    #fill all ifc settings with default values
    def self.defaults()
      require 'bim-tools\defaults.rb'
      Set_defaults.new
    end
    	
    #start opening observer
    #def self.opening()
      require 'bim-tools\opening.rb'
      puts "test"
      Sketchup.active_model.entities.add_observer(MyEntitiesObserver.new)
    #end
    
    # Add a menu item to launch BIM Tools webdialog.
		UI.menu("PlugIns").add_item("BIM Tools") {
			FreeBuilder::Bim_Tools::defaults
			FreeBuilder::Bim_Tools::bt_window
		}

  end
end
