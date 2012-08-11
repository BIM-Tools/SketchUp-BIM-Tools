#       bim-tools_loader.rb
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

MAC = ( Object::RUBY_PLATFORM =~ /(darwin)/i ? true : false )
OSX = MAC unless defined?(OSX)
WIN = ( not MAC ) unless defined?(WIN)
PC = WIN unless defined?(PC)

# Create a basic bim-tools object 
require 'bim-tools/clsBimTools.rb'
ClsBimTools.new

# This observer creates a new bim-tools instance for every new model.
class BtAppObserver < Sketchup::AppObserver
  def onNewModel(model)
    ClsBimTools.new

    # Here is where one might attach other observers to the new model.
    # model.selection.add_observer(MySelectionObserver.new)
  end
  def onOpenModel(model)
    ClsBimTools.new
  end
end

# Attach the observer
Sketchup.add_observer(BtAppObserver.new)
