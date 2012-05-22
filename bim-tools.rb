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

# roadmap 0.11:
# export to IFC

# roadmap 0.12:
# columns

# Changelog:
# 120522 fixed planar geometry origin
# 120522 fixed bug in delete properties, attribute library also gets deleted
# 120517 added option to change planar length and height
# 120515 re-implemented walls from edges function
# 120509 added materials to planars
# 120504 added remove BIM properties button
# 120503 added layer so element connections can be hidden
# 120428 added cutting components
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
bimtools.version = '0.10.6'
bimtools.description = "Tools to create building parts and export these to IFC."
Sketchup.register_extension bimtools, true
