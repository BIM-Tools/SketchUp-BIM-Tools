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

# roadmap:
# export to IFC

# Changelog:
# 120319 recover lost BIM-Tools source faces
# 120314 save BIM-data
# 120312 create holes in planar elements
# 120312 prevent duplicate BIM-Tools entities from source faces
# 120311 show BIM-data for source faces
# 120311 added user input for element thickness using VCB
# 120311 tested webdialog on IE8, works fine, shows min/max-image, but content width is a bit off...
# webdialog show_modal for mac

# Create an entry in the Extension list that loads a script called
# bim-tools.rb.
require 'sketchup.rb'
require 'extensions.rb'

bimtools = SketchupExtension.new "bim-tools", "bim-tools/bim-tools_loader.rb"
bimtools.version = '0.10.0'
bimtools.description = "Tools to create building parts and export these to IFC."
Sketchup.register_extension bimtools, true
