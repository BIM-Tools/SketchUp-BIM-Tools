#       clsBtUi.rb
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

  # Class BIM-Tools UI: manages UI elements
  class ClsBtUi
    def initialize(bimTools)
      
      # create BIM-Tools toolbar
      require "bim-tools/ui/toolbar.rb"
      BtToolbar.new(bimTools)
    end
  end
  
end
