#       clsIfcBuilding.rb
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

# classes for defining IFC building elements

#20 = IFCGEOMETRICREPRESENTATIONCONTEXT($, 'Model', 3, 1.000E-5, #21, $);
#21 = IFCAXIS2PLACEMENT3D(#22, $, $);
#22 = IFCCARTESIANPOINT((0., 0., 0.));
class IfcGeometricRepresentationContext < IfcBase
  # Attribute	                      Type	                      Defined By
  # ContextIdentifier	              IfcLabel (STRING)	          IfcRepresentationContext
  # ContextType	                    IfcLabel (STRING)	          IfcRepresentationContext
  # CoordinateSpaceDimension	      IfcDimensionCount (INTEGER)	IfcGeometricRepresentationContext
  # Precision	                      REAL	                      IfcGeometricRepresentationContext
  # WorldCoordinateSystem	          IfcAxis2Placement (SELECT)	IfcGeometricRepresentationContext
  # TrueNorth	                      IfcDirection (ENTITY)	      IfcGeometricRepresentationContext
  def initialize(ifc_exporter)
    @project = ifc_exporter.project
    @ifc_exporter = ifc_exporter
    @entityType = "IFCGEOMETRICREPRESENTATIONCONTEXT"
    @ifc_exporter.add(self)
    
    transformation = Geom::Transformation.new
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << "$"
    @a_Attributes << "'Model'"
    @a_Attributes << "3"
    @a_Attributes << "1.000E-5"
    @a_Attributes << IfcAxis2Placement3D.new(@ifc_exporter, transformation).record_nr
    @a_Attributes << "$"
  end
end
    
# this could be the most basic element that has sub-elements in the bim-tools project library
class IfcProduct < IfcObject
  attr_accessor :objectPlacement, :representation
  def set_objectPlacement(bt_entity)
    return IfcLocalPlacement.new(@ifc_exporter, bt_entity)
  end
  def set_representation(entity)
    @representation = entity.source
  end
end

class IfcElement < IfcProduct
  attr_accessor :tag
  def set_tag(entity)
    @tag = "$"
  end
end

class IfcBuildingElement < IfcElement
end

class IfcPlate < IfcBuildingElement
  def initialize(project, ifc_exporter, planar)
    @project = project
    @ifc_exporter = ifc_exporter
    @planar = planar
    @entityType = "IFCPLATE"
    @ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << set_globalId(planar)
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr #set_ownerHistory()
    @a_Attributes << set_name(planar) #optional
    @a_Attributes << set_description(planar) #optional
    @a_Attributes << set_objectType("Planar") #optional
    @a_Attributes << set_objectPlacement(planar).record_nr #optional
    
    # Ifcplate has 2 or more representations, 
    # SweptSolid Representation(1)
    # Clipping Representation
    # MappedRepresentation(2)
    aRepresentations = Array.new
    aSweptSolid = Array.new
    #83 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#84));
    loop = @planar.source.outer_loop
    aSweptSolid << IfcExtrudedAreaSolid.new(@ifc_exporter, @planar, loop).record_nr
    aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Body'", "'SweptSolid'", aSweptSolid).record_nr # SweptSolid Representation
    #a_representations << IfcShapeRepresentation.new(@ifc_exporter, 'Body', 'MappedRepresentation', aRepresentations).record_nr # Mapped Representation
    representations = IfcProductDefinitionShape.new(@ifc_exporter, @planar, aRepresentations)
    
    @a_Attributes << representations.record_nr #optional
    @a_Attributes << set_tag(planar) #optional
    
    # define openings
    openings
    
    #add self to the list of entities contained in the site
    @ifc_exporter.add_to_site(self)
  end
  def openings
  
    # get all opening-loops from planar
    aOpenings = @planar.get_openings
    aOpenings[0].each do |opening|
      IfcOpeningElement.new(@ifc_exporter, @planar, self, opening)
    end
    # delete temporary group
    aOpenings[1].erase!
  end
end

#copy from ifcplate, needs cleaning up
class IfcWall < IfcBuildingElement
  def initialize(project, ifc_exporter, planar)
    @project = project
    @ifc_exporter = ifc_exporter
    @planar = planar
    @entityType = "IFCWALL"
    @ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << set_globalId(planar)
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr #set_ownerHistory()
    @a_Attributes << set_name(planar) #optional
    @a_Attributes << set_description(planar) #optional
    @a_Attributes << set_objectType("Planar") #optional
    @a_Attributes << set_objectPlacement(planar).record_nr #optional
    
    # Ifcplate has 2 or more representations, 
    # SweptSolid Representation(1)
    # Clipping Representation
    # MappedRepresentation(2)
    aRepresentations = Array.new
    aSweptSolid = Array.new
    #83 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#84));
    loop = @planar.source.outer_loop
    aSweptSolid << IfcExtrudedAreaSolid.new(@ifc_exporter, @planar, loop).record_nr
    aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Body'", "'SweptSolid'", aSweptSolid).record_nr # SweptSolid Representation
    #a_representations << IfcShapeRepresentation.new(@ifc_exporter, 'Body', 'MappedRepresentation', aRepresentations).record_nr # Mapped Representation
    representations = IfcProductDefinitionShape.new(@ifc_exporter, @planar, aRepresentations)
    
    @a_Attributes << representations.record_nr #optional
    @a_Attributes << set_tag(planar) #optional
    
    # define openings
    openings
    
    #add self to the list of entities contained in the site
    @ifc_exporter.add_to_site(self)
  end
  def openings
  
    # get all opening-loops from planar
    aOpenings = @planar.get_openings
    aOpenings[0].each do |opening|
      IfcOpeningElement.new(@ifc_exporter, @planar, self, opening)
    end
    # delete temporary group
    aOpenings[1].erase!
  end
end


# IFCSITE('" + site_id + "', " + id_s(2) + ", '" + site_name + "', '" + site_description + "', $, " + id_s(24) + ", $, $, .ELEMENT., (" + lat[0] + ", " + lat[1] + ", " + lat[2] + "), (" + long[0] + ", " + long[1] + ", " + long[2] + "), $, $, $);"

#24 = IFCSITE('2ZjPp2Z9P6D8e7u9GDoxr4', #2, 'Default Site', 'Description of Default Site', $, #25, $, $, .ELEMENT., (24, 28, 0), (54, 25, 0), 10., $, $);
#25 = IFCLOCALPLACEMENT($, #26);
#26 = IFCAXIS2PLACEMENT3D(#27, #28, #29);
#27 = IFCCARTESIANPOINT((0.E-1, 0.E-1, 0.E-1));
#28 = IFCDIRECTION((0.E-1, 0.E-1, 1.));
#29 = IFCDIRECTION((1., 0.E-1, 0.E-1));

#43 = IFCRELAGGREGATES('1f_92NYQD0lBChEeKfihEz', #2, 'BuildingContainer', 'BuildingContainer for BuildigStories', #30, (#37));
#44 = IFCRELAGGREGATES('03QlbDcwz3wAQb2KBzxujQ', #2, 'SiteContainer', 'SiteContainer For Buildings', #24, (#30));
#45 = IFCRELAGGREGATES('07oQHvxvvFswj91PBXi3Mo', #2, 'ProjectContainer', 'ProjectContainer for Sites', #1, (#24));
#46 = IFCRELCONTAINEDINSPATIALSTRUCTURE('2Or2FBptr1gPkbt_$syMeu', #2, 'Default Building', 'Contents of Building Storey', (#47, #170), #37);
class IfcSite < IfcProduct
# Attribute	      Type	                                    Defined By
# GlobalId	      IfcGloballyUniqueId (STRING)	            IfcRoot
# OwnerHistory	  IfcOwnerHistory (ENTITY)	                IfcRoot
# Name	          IfcLabel (STRING)	                        IfcRoot                     OPTIONAL
# Description	    IfcText (STRING)	                        IfcRoot                     OPTIONAL
# ObjectType	    IfcLabel (STRING)	                        IfcObject                   OPTIONAL
# ObjectPlacement	IfcObjectPlacement (ENTITY)	              IfcProduct                  OPTIONAL
# Representation	IfcProductRepresentation (ENTITY)	        IfcProduct                  OPTIONAL
# LongName	      IfcLabel (STRING)	                        IfcSpatialStructureElement  OPTIONAL
# CompositionType	IfcElementCompositionEnum (ENUM)	        IfcSpatialStructureElement
# RefLatitude	    IfcCompoundPlaneAngleMeasure (AGGREGATE)	IfcSite                     OPTIONAL
# RefLongitude	  IfcCompoundPlaneAngleMeasure (AGGREGATE)	IfcSite                     OPTIONAL
# RefElevation	  IfcLengthMeasure (REAL)	                  IfcSite                     OPTIONAL
# LandTitleNumber	IfcLabel (STRING)	                        IfcSite                     OPTIONAL
# SiteAddress	    IfcPostalAddress (ENTITY)	                IfcSite                     OPTIONAL
  def initialize(ifc_exporter)
    @project = ifc_exporter.project
    @ifc_exporter = ifc_exporter
    @entityType = "IFCSITE"
    #@ifcOwnerHistory = @ifc_exporter.set_IfcOwnerHistory
    
    # placement of the site is on the origin, it does not have geometry yet
    site_placement = nil
    
    # set project location
    set_latlong
    
    @ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << "'" + @project.site_guid + "'"
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr #set_ownerHistory()
    @a_Attributes << set_name
    @a_Attributes << set_description
    @a_Attributes << "$"
    @a_Attributes << set_objectPlacement(site_placement).record_nr
    @a_Attributes << "$"
    @a_Attributes << "$"
    @a_Attributes << ".ELEMENT."
    @a_Attributes << latitude
    @a_Attributes << longtitude
    @a_Attributes << elevation
    @a_Attributes << "$"
    @a_Attributes << "$"
    
  end
  def set_name
    if @project.site_name.nil?
      return "$"
    else
      return "'" + @project.site_name + "'"
    end
  end
  def set_description
    if @project.site_description.nil?
      return "$"
    else
      return "'" + @project.site_description + "'"
    end
  end
  
  # get project location
  def set_latlong
    local_coordinates = [0,0,0]
		local_point = Geom::Point3d.new(local_coordinates)
		ll = Sketchup.active_model.point_to_latlong(local_point)
    @latlong = ll
  end
  def latitude
		lat = sprintf("%.4f", @latlong[0])
		lat = lat.split('.')
		latpart = lat[1].split(//)
		lat = [lat[0], latpart[0] + latpart[1], latpart[2] + latpart[3]]
    return @ifc_exporter.ifcList(lat)
  end
  def longtitude
		long = sprintf("%.4f", @latlong[1])
		long = long.split('.')
		longpart = long[1].split(//)
		long = [long[0], longpart[0] + longpart[1], longpart[2] + longpart[3]]
    return @ifc_exporter.ifcList(long)
  end
  def elevation
    return @ifc_exporter.ifcLengthMeasure(@latlong[2])
  end
end

#copy from ifcplate, needs cleaning up
class IfcSlab < IfcBuildingElement
# Attribute	      Type	                            Defined By
# GlobalId	      IfcGloballyUniqueId (STRING)	    IfcRoot
# OwnerHistory	  IfcOwnerHistory (ENTITY)	        IfcRoot
# Name	          IfcLabel (STRING)	                IfcRoot
# Description	    IfcText (STRING)	                IfcRoot
# ObjectType	    IfcLabel (STRING)	                IfcObject
# ObjectPlacement	IfcObjectPlacement (ENTITY)	      IfcProduct
# Representation	IfcProductRepresentation (ENTITY)	IfcProduct
# Tag	            IfcIdentifier (STRING)	          IfcElement
# PredefinedType	IfcSlabTypeEnum (ENUM)	          IfcSlab
  def initialize(project, ifc_exporter, planar)
    @project = project
    @ifc_exporter = ifc_exporter
    @planar = planar
    @entityType = "IFCSLAB"
    @ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << set_globalId(planar)
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr #set_ownerHistory()
    @a_Attributes << set_name(planar) #optional
    @a_Attributes << set_description(planar) #optional
    @a_Attributes << set_objectType("Planar") #optional
    @a_Attributes << set_objectPlacement(planar).record_nr #optional
    
    # Ifcplate has 2 or more representations, 
    # SweptSolid Representation(1)
    # Clipping Representation
    # MappedRepresentation(2)
    aRepresentations = Array.new
    aSweptSolid = Array.new
    #83 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#84));
    loop = @planar.source.outer_loop
    aSweptSolid << IfcExtrudedAreaSolid.new(@ifc_exporter, @planar, loop).record_nr
    aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Body'", "'SweptSolid'", aSweptSolid).record_nr # SweptSolid Representation
    #a_representations << IfcShapeRepresentation.new(@ifc_exporter, 'Body', 'MappedRepresentation', aRepresentations).record_nr # Mapped Representation
    representations = IfcProductDefinitionShape.new(@ifc_exporter, @planar, aRepresentations)
    
    @a_Attributes << representations.record_nr #optional
    @a_Attributes << set_tag(planar) #optional
    @a_Attributes << ifcSlabTypeEnum(planar) #optional
    
    # define openings
    openings
    
    #add self to the list of entities contained in the site
    @ifc_exporter.add_to_site(self)
  end
  def openings
  
    # get all opening-loops from planar
    aOpenings = @planar.get_openings
    aOpenings[0].each do |opening|
      IfcOpeningElement.new(@ifc_exporter, @planar, self, opening)
    end
    # delete temporary group
    aOpenings[1].erase!
  end
  def ifcSlabTypeEnum(planar)
    # Return options: FLOOR, ROOF, LANDING, BASESLAB, USERDEFINED, NOTDEFINED
    if planar.element_type == "Floor"
      return ".FLOOR."
    elsif planar.element_type == "Roof"
      return ".ROOF."
    else
      return ".NOTDEFINED."
    end
  end
end

#97 = IFCOPENINGELEMENT('2LcE70iQb51PEZynawyvuT', #2, 'Opening Element xyz', 'Description of Opening', $, #98, #103, $);
#98 = IFCLOCALPLACEMENT(#46, #99);
#99 = IFCAXIS2PLACEMENT3D(#100, #101, #102);
#100 = IFCCARTESIANPOINT((9.000E-1, 0., 2.500E-1));
#101 = IFCDIRECTION((0., 0., 1.));
#102 = IFCDIRECTION((1., 0., 0.));
#103 = IFCPRODUCTDEFINITIONSHAPE($, $, (#110));
#109 = IFCRELVOIDSELEMENT('3lR5koIT51Kwudkm5eIoTu', #2, $, $, #45, #97);
#110 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#111));
#111 = IFCEXTRUDEDAREASOLID(#112, #119, #123, 1.400);
#112 = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, #113);
#113 = IFCPOLYLINE((#114, #115, #116, #117, #118));
#114 = IFCCARTESIANPOINT((0., 0.));
#115 = IFCCARTESIANPOINT((0., 3.000E-1));
#116 = IFCCARTESIANPOINT((7.500E-1, 3.000E-1));
#117 = IFCCARTESIANPOINT((7.500E-1, 0.));
#118 = IFCCARTESIANPOINT((0., 0.));
#119 = IFCAXIS2PLACEMENT3D(#120, #121, #122);
#120 = IFCCARTESIANPOINT((0., 0., 0.));
#121 = IFCDIRECTION((0., 0., 1.));
#122 = IFCDIRECTION((1., 0., 0.));
#123 = IFCDIRECTION((0., 0., 1.));
class IfcOpeningElement < IfcElement
  # Attribute	      Type	                            Defined By
  # GlobalId	      IfcGloballyUniqueId (STRING)	    IfcRoot
  # OwnerHistory	  IfcOwnerHistory (ENTITY)	        IfcRoot
  # Name	          IfcLabel (STRING)	                IfcRoot
  # Description	    IfcText (STRING)	                IfcRoot
  # ObjectType	    IfcLabel (STRING)	                IfcObject
  # ObjectPlacement	IfcObjectPlacement (ENTITY)	      IfcProduct
  # Representation	IfcProductRepresentation (ENTITY)	IfcProduct
  # Tag	            IfcIdentifier (STRING)	          IfcElement
  attr_accessor :name, :description, :record_nr
  def initialize(ifc_exporter, bt_entity, ifcPlate, opening)
    @ifc_exporter = ifc_exporter
    @bt_entity = bt_entity
    @opening = opening
    @entityType = "IFCOPENINGELEMENT"
    ifc_exporter.add(self)
    
    # link to the planar in which to cut the hole
    IfcRelVoidsElement.new(@ifc_exporter, ifcPlate, self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << "'" + @ifc_exporter.project.new_guid + "'"#set_globalId(bt_entity)
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
    @a_Attributes << set_name #optional
    @a_Attributes << set_description #optional
    @a_Attributes << set_ObjectType
    @a_Attributes << set_objectPlacement(bt_entity).record_nr #optional
    @a_Attributes << set_ProductRepresentation.record_nr #optional
    @a_Attributes << set_Tag
  end
  def set_name
    return "$"
  end
  def set_description
    return "$"
  end
  def set_ObjectType
    return "$"
  end
  def set_ProductRepresentation
    aRepresentations = Array.new
    aSweptSolid = Array.new
    aSweptSolid << IfcExtrudedAreaSolid.new(@ifc_exporter, @bt_entity, @opening).record_nr
    aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Body'", "'SweptSolid'", aSweptSolid).record_nr
    return IfcProductDefinitionShape.new(@ifc_exporter, @bt_entity, aRepresentations)
  end
  def set_Tag
    return "$"
  end
end

#46 = IFCRELCONTAINEDINSPATIALSTRUCTURE('2Or2FBptr1gPkbt_$syMeu', #2, 'Default Building', 'Contents of Building Storey', (#47, #170), #37);
class IfcRelContainedInSpatialStructure < IfcProduct
  # Attribute	        Type	                              Defined By
  # GlobalId	        IfcGloballyUniqueId (STRING)	      IfcRoot
  # OwnerHistory	    IfcOwnerHistory (ENTITY)	          IfcRoot
  # Name	            IfcLabel (STRING)	                  IfcRoot                           OPTIONAL
  # Description	      IfcText (STRING)	                  IfcRoot                           OPTIONAL
  # RelatedElements	  SET OF IfcProduct (ENTITY)	        IfcRelContainedInSpatialStructure
  # RelatingStructure	IfcSpatialStructureElement (ENTITY)	IfcRelContainedInSpatialStructure
  def initialize(ifc_exporter)
    @ifc_exporter = ifc_exporter
    @entityType = "IFCRELCONTAINEDINSPATIALSTRUCTURE"
    @ifc_exporter.add(self)
  end
  def fill()
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << "'" + @ifc_exporter.project.new_guid + "'"
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
    @a_Attributes << "'SiteContainer'" # only correct for site!!!
    @a_Attributes << "'Contents of Site'" # only correct for site!!!
    @a_Attributes << @ifc_exporter.ifcList(@ifc_exporter.aContainedInSite)
    @a_Attributes << @ifc_exporter.ifcSite.record_nr
  end
end

class IfcRelVoidsElement < IfcRoot

  # Attribute	              Type	                                Defined By
  # GlobalId	              IfcGloballyUniqueId (STRING)	        IfcRoot
  # OwnerHistory	          IfcOwnerHistory (ENTITY)	            IfcRoot
  # Name	                  IfcLabel (STRING)	                    IfcRoot
  # Description	            IfcText (STRING)	                    IfcRoot
  # RelatingBuildingElement	IfcElement (ENTITY)	                  IfcRelVoidsElement
  # RelatedOpeningElement	  IfcFeatureElementSubtraction (ENTITY)	IfcRelVoidsElement
  attr_accessor :name, :description, :record_nr
  def initialize(ifc_exporter, ifcPlate, ifcOpeningElement)
    @ifc_exporter = ifc_exporter
    @entityType = "IFCRELVOIDSELEMENT"
    ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << set_globalId()
    @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
    @a_Attributes << set_name #optional
    @a_Attributes << set_description #optional
    @a_Attributes << ifcPlate.record_nr
    @a_Attributes << ifcOpeningElement.record_nr
  end
  def set_name
    return "$"
  end
  def set_description
    return "$"
  end
end

# IFCPRODUCTDEFINITIONSHAPE($, $, (#79, #83));
#20 = IFCGEOMETRICREPRESENTATIONCONTEXT = none, $
#79 = IFCSHAPEREPRESENTATION(#20, 'Axis', 'Curve2D', (#80));
#83 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#84));
#84 = IFCEXTRUDEDAREASOLID(#85, #92, #96, 2.300);
#85 = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, #86);
#92 = IFCAXIS2PLACEMENT3D(#93, #94, #95);
#96 = IFCDIRECTION((0., 0., 1.));
class IfcProductDefinitionShape < IfcBase
  attr_accessor :name, :description, :record_nr, :representations
  def initialize(ifc_exporter, bt_entity, aRepresentations)
    @ifc_exporter = ifc_exporter
    @bt_entity = bt_entity
    @representations = aRepresentations
    @entityType = "IFCPRODUCTDEFINITIONSHAPE"
    ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << set_name #optional
    @a_Attributes << set_description #optional
    @a_Attributes << set_representations #optional
  end
  def set_name
    if @bt_entity.name?.nil? || @bt_entity.name? == ""
      @name = "$"
    else
      @name = @bt_entity.name?
    end
  end
  def set_description
    if @bt_entity.description?.nil? || @bt_entity.description? == ""
      @description = "$"
    else
      @description = @bt_entity.description?
    end
  end
  def set_representations
    return @ifc_exporter.ifcList(@representations)
  end
end

class IfcShapeRepresentation < IfcBase
  # Attribute       Type                               Defined By
  # Name            IfcLabel (STRING)                  IfcProductRepresentation
  # Description     IfcText (STRING)                   IfcProductRepresentation
  # Representations LIST OF IfcRepresentation (ENTITY) IfcProductRepresentation
  attr_accessor :name, :description, :representations, :record_nr
  def initialize(ifc_exporter, name, description, aRepresentations)
    @ifc_exporter = ifc_exporter
    @name = name
    @description = description
    @representations = aRepresentations
    @entityType = "IFCSHAPEREPRESENTATION"
    ifc_exporter.add(self)
    
    # "local" IFC array
    @a_Attributes = Array.new
    @a_Attributes << @ifc_exporter.set_IfcGeometricRepresentationContext.record_nr
    @a_Attributes << @name #optional
    @a_Attributes << @description #optional
    @a_Attributes << set_representations #optional
  end
  def set_representations
    return @ifc_exporter.ifcList(@representations)
  end
end
