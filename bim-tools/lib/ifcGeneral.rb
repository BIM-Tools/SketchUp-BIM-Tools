#       ifcImport.rb - Library of methods that generate SketchUp bim-tools elements from parts of IFC code.
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


class IfcGeneralLibrary
	def initialize()
    
  end



end #class IfcImportLibrary

def guid()#function returns a new IFC object ID - function has to be updated to use official Globally Unique Identifier - http://buildingsmart-tech.org/implementation/get-started/ifc-guid
  length=22
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  string = ''
  length.times { string << chars[rand(chars.size)] }
  return string
end
def set_id(group)
  group.set_attribute "ifc", "id", guid()
end
