#       ifcExport.rb - Library of methods that generate parts of IFC code from SketchUp bim-tools elements
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

class IfcExportLibrary
	def initialize()
    
  end

  #116 = IFCCARTESIANPOINT((7.500E-1, 3.000E-1));

  def IfcCartesianpoint(m_aSuPoint)#function that takes a sketchup ?vertex? and returns an ifc cartesianpoint
    
  end
  def IfcPolyline(m_aSuPoints)#function that takes a sketchup ?face? and returns an ifc polyline
    require 'bim-tools\ifc\cartesianpoint.rb'
    m_aSuPoints.each |point|
      IfcCartesianpoint.new.export(point)
    end
  end
end #class IfcExportLibrary
