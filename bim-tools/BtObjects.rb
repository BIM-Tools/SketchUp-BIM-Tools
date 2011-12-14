#       BtObjects.rb - Classes that discribe building parts.
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

class BuildingElement
  @id # unique id, Guid?
  @geometry
  @type
  @name # OPTIONAL?
  @description # OPTIONAL?
  @insertion_point # vector
  @transformation # @placement_vector # editable(rotation) for changing standing wall into flat floor?
  @material # part of more specific classes?
  
  attr_accessor :id
  attr_accessor :type
  attr_accessor :geometry
  attr_accessor :transformation
  attr_accessor :material
  
  def base_init(bt_lib, geometry=nil)
    require 'bim-tools/lib/ifcGeneral.rb'
    @id = guid
    @type = type(geometry)
    @geometry = geometry
    @material = geometry.material
    @transformation = geometry.transformation
    @bt_lib = bt_lib
    
    #set_attributes
    
    # TODO: if no geometry present, the user might be presented with a form to fill in the appropriate data? or a selection tool?
    #if geometry == nil

    # add building_element to bim-tools ObjectLibrary
    bt_lib.add(self)
  end
  
  # figures out the ifc/bt type of the current object
  def type(geometry)
    type_attr = geometry.get_attribute "ifc", "ifc_element"
    # TODO: if no type defined, the most likely type must be guessed depending on the shape and use of the geometry.
    return type_attr
  end
  #def set_attributes  
  #end
  
  def ifc_set_id(id)
    @id = id
  end
  
  def ifc_get_id()
    if @id != nil
      return @id
    else
      return false
    end
  end
  
end

class Profile # Sketchup component with faces in x/y-plane, faces will be extruded along LinearElement
  @profile_faces # array of SubProfile objects
  class SubProfile
    @face # Sketchup face
    @material # Sketchup face material
  end
end

class PlanarElement < BuildingElement
  @plane # Sketchup-plane: array of 2 vectors defining a plane
  @boundary # array with a closed loop of multiple LinearElement objects, or a set of rules?
  #@boundary_joints # PointElement, part that solves the connection between 2 boundary parts
  @width # if not available, boundingbox width???
  @length # OPTIONAL, if not available, boundingbox length???
  @height # OPTIONAL, if not available, boundingbox height???
  #attr_accessor :width
  #attr_accessor :length
  #attr_accessor :height
  def get_dimension(dim_type, dim)
    if dim != nil
      dim = dim
    else
      dim = @geometry.get_attribute "ifc", dim_type, 0
    end
    return dim
  end
  def width
    get_dimension("width", @width)
  end
  def length
    get_dimension("length", @length)
  end
  def height
    get_dimension("height", @height)
  end
end

class LinearElement < BuildingElement
  @profile
end

class PointElement < BuildingElement # object placed "on" a vertex connecting two linear elements(edges)

end

class BtWall < PlanarElement
  def initialize(bt_lib, geometry=nil)
    base_init(bt_lib, geometry)
  end
end

class Floor < PlanarElement

end

class Column < LinearElement

end

class BtOpening < BuildingElement
  def initialize(bt_lib, geometry=nil)
    @geometry = geometry
    @voids_element = nil
    base_init(bt_lib, @geometry)
    set_attributes
  end
  def set_attributes
    # Add IFC attributes
    @geometry.set_attribute "ifc", "ifc_element", "IfcWindow"
  end
  def voids_element #returns the building_element this opening is glued to, if not glued to building_element returns false
	  if @voids_element != nil
      return @voids_element
    else
      if @geometry.glued_to != nil
        @bt_lib.list.each do |building_element|
          if @geometry.glued_to == building_element.geometry
            return building_element
          end
        end
      else
        return false
      end
    end
  end
end
