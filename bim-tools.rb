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

# Create an entry in the Extension list that loads a script called
# bim-tools.rb.
require 'sketchup.rb'
require 'extensions.rb'

bimtools = SketchupExtension.new "bim-tools", "bim-tools/bim-tools.rb"
bimtools.version = '0.9.2'
bimtools.description = "Tools to create walls from edges and export these to IFC."
Sketchup.register_extension bimtools, true
