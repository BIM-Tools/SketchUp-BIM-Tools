#       ObjectLibrary.rb - Library object keeps track of all bim-tools objects.
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

class ObjectLibrary
  @obj_list
  attr_accessor :obj_list
  
  def initialize()
    @obj_list = Array.new
    fill
  end
  def add(object)
    @obj_list << object
  end
  def list
    return @obj_list
  end
  # update bim-tools object list
  def reload
    # check if all objects in list still exist, if not: remove from list
  end
  def fill
    # find all bim-tools objects in active model and add to list
    # every bim-tools object needs the folowing properties:
    # - geometry(sketchup-object: group, edge)
    # - bim-tools-type(wall/floor OR planar/linear)
    # - guid(defined inside class on object creation)
    require 'bim-tools/BtObjects.rb'
    
    entities = Sketchup.active_model.entities
    entities.each do |entity|
      if entity.attribute_dictionary "ifc"
        ifc_type = entity.get_attribute "ifc", "ifc_element"
        #type = entity.get_attribute "ifc", "ifc_element" # needs to be part of BuildingElement class init
        if ifc_type == "IfcWallStandardCase"
          building_element = BtWall.new(self, entity)
        elsif ifc_type == "IfcWindow"
          building_element = BtOpening.new(self, entity)
          # add observer to opening, to monitor any transformations
          require 'bim-tools/opening_observer.rb'
          entity.add_observer(OpeningObserver.new)
        else
          building_element = BuildingElement.new(self, entity)
        end
        #self.add(building_element)
        #building_element.geometry = entity # needs to be part of BuildingElement class init
        #building_element.type = type # needs to be part of BuildingElement class init
      end
    end
  end
end
