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

module Brewsky
  module BimTools
  
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
      def set_objectPlacement(bt_entity=nil)
        
        #parent transformation
        transformation_parent = nil
        
        #entity transformation
        if bt_entity.nil?
          transformation = nil
        else
          transformation = bt_entity.geometry.transformation
        end
        
        return IfcLocalPlacement.new(@ifc_exporter, transformation_parent, transformation)
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
        @a_Attributes << set_representations.record_nr #optional
        @a_Attributes << set_tag(planar) #optional
        
        # define openings
        openings
        
        #add self to the list of entities contained in the building
        @ifc_exporter.add_to_building(self)
      end
      def set_representations
        # Ifcplate has 2 or more representations, 
        # SweptSolid Representation(1)
        # Clipping Representation
        # MappedRepresentation(2)
        aRepresentations = Array.new
        aSweptSolid = Array.new
        #83 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#84));
        loop = @planar.source.outer_loop
        
        @points = Array.new
        loop.vertices.each do |vert|
          t = @planar.geometry.transformation.inverse
          p = vert.position.transform! t
          @points << p
        end
        
        aSweptSolid << IfcExtrudedAreaSolid.new(@ifc_exporter, @planar, @points).record_nr
        aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Body'", "'SweptSolid'", aSweptSolid).record_nr # SweptSolid Representation
        #a_representations << IfcShapeRepresentation.new(@ifc_exporter, 'Body', 'MappedRepresentation', aRepresentations).record_nr # Mapped Representation
        return IfcProductDefinitionShape.new(@ifc_exporter, @planar, aRepresentations)
      end
      def openings
      
        # get all opening-loops from planar
        #aOpenings = @planar.get_openings
        #aOpenings[0].each do |opening|
        @planar.openings.each do |opening|
          IfcOpeningElement.new(@ifc_exporter, @planar, self, opening)
        end
        # delete temporary group
        #aOpenings[1].erase!
      end
    end
    
    #copy from ifcplate, needs cleaning up
    class IfcWall < IfcPlate #officially not correct!!! IfcBuildingElement
      attr_accessor :record_nr
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
        @a_Attributes << set_representations.record_nr #optional
        @a_Attributes << set_tag(planar) #optional
        
        # define openings
        openings
        
        set_BaseQuantities
        
        #add self to the list of entities contained in the building
        @ifc_exporter.add_to_building(self)
      end
      def set_BaseQuantities
        aRelatedObjects = [self.record_nr]
        IfcRelDefinesByProperties.new(@ifc_exporter, @planar, aRelatedObjects)
      end
    end
    
    # http://www.buildingsmart-tech.org/ifc/IFC2x4/alpha/html/ifcsharedbldgelements/lexical/ifcwall.htm
    
    # Quantity Use Definition:
    # The quantities relating to the IfcWall and IfcWallStandardCase are defined by the IfcElementQuantity and attached by the IfcRelDefinesByProperties relationship. It is accessible by the inverse IsDefinedBy relationship. The following base quantities are defined and should be exchanged with the IfcElementQuantity.MethodOfMeasurement = 'BaseQuantities'. Other quantities can be defined being subjected to local standard of measurement with another string value assigned to MethodOfMeasurement.
    
    # Name	              Description	Value                                                                                                                                                         Type
    # Length	            Total nominal length of the wall along the wall path.	                                                                                                                    IfcQuantityLength
    # Width	              Total nominal width (or thickness) of the wall measured perpendicular to the wall path. It should only be provided, if it is constant along the wall path.	              IfcQuantityLength
    # Height	            Total nominal height of the wall. It should only be provided, if it is constant along the wall path.	                                                                    IfcQuantityLength
    # GrossFootprintArea	Area of the wall as viewed by a ground floor view, not taking any wall modifications (like recesses) into account. It is also referred to as the foot print of the wall.	IfcQuantityArea
    # NetFootprintArea	  Area of the wall as viewed by a ground floor view, taking all wall modifications (like recesses) into account. It is also referred to as the foot print of the wall.	    IfcQuantityArea
    # GrossSideArea	      Area of the wall as viewed by an elevation view of the middle plane of the wall.  It does not take into account any wall modifications (such as openings).	              IfcQuantityArea
    # NetSideArea	        Area of the wall as viewed by an elevation view of the middle plane. It does take into account all wall modifications (such as openings).	                                IfcQuantityArea
    # GrossVolume	        Volume of the wall, without taking into account the openings and the connection geometry.	                                                                                IfcQuantityVolume
    # NetVolume	          Volume of the wall, after subtracting the openings and after considering the connection geometry.	                                                                        IfcQuantityVolume
    
    class IfcElementQuantity < IfcRoot
    # Attribute	          Type	                              Defined By
    # GlobalId	          IfcGloballyUniqueId (STRING)	      IfcRoot
    # OwnerHistory	      IfcOwnerHistory (ENTITY)	          IfcRoot
    # Name	              IfcLabel (STRING)	                  IfcRoot             OPTIONAL
    # Description	        IfcText (STRING)	                  IfcRoot             OPTIONAL
    # MethodOfMeasurement	IfcLabel (STRING)	                  IfcElementQuantity  OPTIONAL
    # Quantities	        SET OF IfcPhysicalQuantity (ENTITY)	IfcElementQuantity
    
      def initialize(ifc_exporter, planar)
        @ifc_exporter = ifc_exporter
        @project = ifc_exporter.project
        @planar = planar
        @entityType = "IFCELEMENTQUANTITY"
        @ifc_exporter.add(self)
        
        quantities = Array.new
        quantities << IfcQuantityLength.new(@ifc_exporter, "Length", planar.length?).record_nr #quantities["Length"] = planar.length?
        quantities << IfcQuantityLength.new(@ifc_exporter, "Width", planar.width).record_nr #quantities["Width"] = planar.width
        quantities << IfcQuantityLength.new(@ifc_exporter, "Height", planar.height?).record_nr #quantities["Height"] = planar.height?
        quantities << IfcQuantityArea.new(@ifc_exporter, "GrossFootprintArea", planar.length? * planar.width).record_nr #quantities["GrossFootprintArea"] = planar.length? * planar.width
        quantities << IfcQuantityArea.new(@ifc_exporter, "NetFootprintArea", planar.length? * planar.width).record_nr #quantities["NetFootprintArea"] = planar.length? * planar.width
        quantities << IfcQuantityArea.new(@ifc_exporter, "GrossSideArea", planar.height? * planar.length?).record_nr #quantities["GrossSideArea"] = planar.height? * planar.length?
        quantities << IfcQuantityArea.new(@ifc_exporter, "NetSideArea", planar.height? * planar.length?).record_nr #quantities["NetSideArea"] = planar.height? * planar.length?
        quantities << IfcQuantityVolume.new(@ifc_exporter, "GrossVolume", planar.height? * planar.length? * planar.width).record_nr #quantities["GrossVolume"] = planar.height? * planar.length? * planar.width
        quantities << IfcQuantityVolume.new(@ifc_exporter, "NetVolume", planar.geometry.volume * (25.4 **3)).record_nr #quantities["NetVolume"] = planar.geometry.volume * (25.4 **3)
    
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_globalId
        @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
        @a_Attributes << set_name
        @a_Attributes << set_description
        @a_Attributes << "'BaseQuantities'"
        @a_Attributes << ifc_exporter.ifcList(quantities)
      end
    end
    
    class IfcRelDefinesByProperties < IfcRoot
    # Attribute	                  Type	                            Defined By
    # GlobalId	                  IfcGloballyUniqueId (STRING)	    IfcRoot
    # OwnerHistory	              IfcOwnerHistory (ENTITY)	        IfcRoot
    # Name	                      IfcLabel (STRING)	                IfcRoot
    # Description	                IfcText (STRING)	                IfcRoot
    # RelatedObjects	            SET OF IfcObject (ENTITY)	        IfcRelDefines
    # RelatingPropertyDefinition	IfcPropertySetDefinition (ENTITY)	IfcRelDefinesByProperties
      attr_accessor :record_nr
      def initialize(ifc_exporter, planar, aRelatedObjects)
        @ifc_exporter = ifc_exporter
        @project = ifc_exporter.project
        @entityType = "IFCRELDEFINESBYPROPERTIES"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_globalId
        @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
        @a_Attributes << set_name
        @a_Attributes << set_description
        @a_Attributes << ifc_exporter.ifcList(aRelatedObjects)
        @a_Attributes << IfcElementQuantity.new(@ifc_exporter, planar).record_nr
      end
    end


    # IFCMATERIAL('100 Leeg- Binnenblad');
    class IfcMaterial < IfcBase
      # Attribute	  Type	            Defined By
      # Name	      IfcLabel (STRING)	IfcMaterial
      # Description IfcText           IfcMaterial   OPTIONAL 2x4
      # Category    IfcLabel          IfcMaterial   OPTIONAL 2x4
      def initialize(ifc_exporter, material_name)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCMATERIAL"
        ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "'" + material_name + "'"
      end
    end

    # IFCMATERIALLAYER(#148,100.,.U.);
    class IfcMaterialLayer < IfcBase
      # Attribute	      Type	                          Defined By
      # Material	      IfcMaterial (ENTITY)	          IfcMaterialLayer
      # LayerThickness	IfcPositiveLengthMeasure (REAL)	IfcMaterialLayer
      # IsVentilated	  IfcLogical (LOGICAL)	          IfcMaterialLayer
      def initialize(ifc_exporter, material_name, layerThickness)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCMATERIALLAYER"
        ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << IfcMaterial.new(ifc_exporter, material_name).record_nr
        @a_Attributes << layerThickness.to_m.to_f.to_s
        @a_Attributes << ".U."
      end
    end
    
    # IFCMATERIALLAYERSET((#136,#141,#146,#151),'01 Algemene BU wand iso');
    class IfcMaterialLayerSet < IfcBase
      # Attribute	      Type	                            Defined By
      # MaterialLayers	LIST OF IfcMaterialLayer (ENTITY)	IfcMaterialLayerSet
      # LayerSetName	  IfcLabel (STRING)	                IfcMaterialLayerSet
      def initialize(ifc_exporter, aMaterialLayers, sLayerSetName)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCMATERIALLAYERSET"
        ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << ifc_exporter.ifcList(aMaterialLayers)
        @a_Attributes << "'" + sLayerSetName + "'"
      end
    end

    # IFCMATERIALLAYERSETUSAGE(#153,.AXIS2.,.POSITIVE.,0.);
    class IfcMaterialLayerSetUsage < IfcBase
      # Attribute	              Type	                          Defined By
      # ForLayerSet	            IfcMaterialLayerSet (ENTITY)	  IfcMaterialLayerSetUsage
      # LayerSetDirection	      IfcLayerSetDirectionEnum (ENUM)	IfcMaterialLayerSetUsage
      # DirectionSense	        IfcDirectionSenseEnum (ENUM)	  IfcMaterialLayerSetUsage
      # OffsetFromReferenceLine	IfcLengthMeasure (REAL)	        IfcMaterialLayerSetUsage
      def initialize(ifc_exporter, ifcMaterialLayerSet)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCMATERIALLAYERSETUSAGE"
        ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << ifcMaterialLayerSet.record_nr
        @a_Attributes << ".AXIS2."
        @a_Attributes << ".POSITIVE."
        @a_Attributes << "0."
      end
    end
    
    # IFCRELASSOCIATESMATERIAL('3rezN6ZsexG8ShnqMhP$g5',#13,$,$,(#170),#155);
    class IfcRelAssociatesMaterial < IfcRoot
      # Attribute	        Type	                        Defined By
      # GlobalId	        IfcGloballyUniqueId (STRING)	IfcRoot
      # OwnerHistory	    IfcOwnerHistory (ENTITY)	    IfcRoot                   OPTIONAL
      # Name	            IfcLabel (STRING)	            IfcRoot                   OPTIONAL
      # Description	      IfcText (STRING)	            IfcRoot                   OPTIONAL
      # RelatedObjects	  SET OF IfcRoot (ENTITY)	      IfcRelAssociates
      # RelatingMaterial	IfcMaterialSelect (SELECT)	  IfcRelAssociatesMaterial
      def initialize(ifc_exporter, aRelatedObjects, ifcMaterialLayerSetUsage)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCRELASSOCIATESMATERIAL"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_globalId
        @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
        @a_Attributes << "$"
        @a_Attributes << "$"
        @a_Attributes << ifc_exporter.ifcList(aRelatedObjects)
        @a_Attributes << ifcMaterialLayerSetUsage.record_nr
      end
    end
    
    #IFCCOLOURRGB($,0.76078431,0.61568627,0.54509804);
    class IfcColourRgb < IfcBase
      # Attribute	Type	                            Defined By
      # Red	      IfcNormalisedRatioMeasure (REAL)	IfcColourRgb
      # Green	    IfcNormalisedRatioMeasure (REAL)	IfcColourRgb
      # Blue	    IfcNormalisedRatioMeasure (REAL)	IfcColourRgb
      def initialize(ifc_exporter, material)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCCOLOURRGB"
        @ifc_exporter.add(self)
        @material = material

        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "$"
        @a_Attributes << color(0)
        @a_Attributes << color(1)
        @a_Attributes << color(2)
      end
      def color(id)
        if @material.nil?
          return "1."
        else
          rgb = @material.color.to_a[id]
          return (rgb.to_f / 255.to_f).to_s
        end
      end
    end
    
    #IFCSURFACESTYLERENDERING(#246,0.,IFCNORMALISEDRATIOMEASURE(0.69),$,$,$,IFCNORMALISEDRATIOMEASURE(0.83),$,.NOTDEFINED.);
    class IfcSurfaceStyleShading < IfcBase
      # Attribute	                Type	                              Defined By
      # SurfaceColour	            IfcColourRgb (ENTITY)	              IfcSurfaceStyleShading
      def initialize(ifc_exporter, material)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCSURFACESTYLESHADING"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << IfcColourRgb.new(ifc_exporter, material).record_nr
      end
    end
    
    #IFCSURFACESTYLE('21 Buitenwand metselwerk',.BOTH.,(#247));
    class IfcSurfaceStyle < IfcBase
      # Attribute Type	                                        Defined By
      # Name	    IfcLabel (STRING)	                            IfcPresentationStyle
      # Side	    IfcSurfaceSide (ENUM)	                        IfcSurfaceStyle
      # Styles	  SET OF IfcSurfaceStyleElementSelect (SELECT)	IfcSurfaceStyle
      def initialize(ifc_exporter, material, side)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCSURFACESTYLE"
        @ifc_exporter.add(self)
        aSurfaceStyleElementSelect = Array.new
        aSurfaceStyleElementSelect << IfcSurfaceStyleShading.new(ifc_exporter, material).record_nr
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "'" + material_name(material) + "'"
        @a_Attributes << "." + side + "."
        @a_Attributes << ifc_exporter.ifcList(aSurfaceStyleElementSelect)
      end
      def material_name(material)
        material == nil ? "Default" : material.name
      end
    end
    
  #250= IFCPRESENTATIONSTYLEASSIGNMENT((#248));
    class IfcPresentationStyleAssignment < IfcBase
      # Attribute Type	                                      Defined By
      # Styles	  SET OF IfcPresentationStyleSelect (SELECT)	IfcPresentationStyleAssignment
      def initialize(ifc_exporter, material, side)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCPRESENTATIONSTYLEASSIGNMENT"
        @ifc_exporter.add(self)
        aPresentationStyleSelect = Array.new
        aPresentationStyleSelect << IfcSurfaceStyle.new(ifc_exporter, material, side).record_nr
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << ifc_exporter.ifcList(aPresentationStyleSelect)
      end
    end
    
    #IFCSTYLEDITEM(#231,(#250),$);
    class IfcStyledItem < IfcBase
      # Attribute Type	                                          Defined By
      # Item	    IfcRepresentationItem (ENTITY)	                IfcStyledItem
      # Styles	  SET OF IfcPresentationStyleAssignment (ENTITY)	IfcStyledItem
      # Name	    IfcLabel (STRING)                               IfcStyledItem OPTIONAL
      def initialize(ifc_exporter, entity, source)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCSTYLEDITEM"
        @ifc_exporter.add(self)
        aPresentationStyles = Array.new
        aPresentationStyles << IfcPresentationStyleAssignment.new(ifc_exporter, source.material, "POSITIVE").record_nr
        aPresentationStyles << IfcPresentationStyleAssignment.new(ifc_exporter, source.back_material, "NEGATIVE").record_nr
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << entity
        @a_Attributes << ifc_exporter.ifcList(aPresentationStyles)
        @a_Attributes << "$"
      end
    end
    
  # kleur exporteren
  #231= IFCEXTRUDEDAREASOLID(#227,#228,#36,2960.);
  #246= IFCCOLOURRGB($,0.76078431,0.61568627,0.54509804);
  #247= IFCSURFACESTYLERENDERING(#246,0.,IFCNORMALISEDRATIOMEASURE(0.69),$,$,$,IFCNORMALISEDRATIOMEASURE(0.83),$,.NOTDEFINED.);
  #248= IFCSURFACESTYLE('21 Buitenwand metselwerk',.BOTH.,(#247));
  #250= IFCPRESENTATIONSTYLEASSIGNMENT((#248));
  #252= IFCSTYLEDITEM(#231,(#250),$);

  # materiaal omschrijving exporteren
  #136= IFCMATERIALLAYER(#123,100.,.U.);
  #138= IFCMATERIAL('410 Luchtspouw buiten');
  #141= IFCMATERIALLAYER(#138,40.,.U.);
  #143= IFCMATERIAL('400 Isolatie basis');
  #146= IFCMATERIALLAYER(#143,100.,.U.);
  #148= IFCMATERIAL('100 Leeg- Binnenblad');
  #151= IFCMATERIALLAYER(#148,100.,.U.);
  #153= IFCMATERIALLAYERSET((#136,#141,#146,#151),'01 Algemene BU wand iso');
  #155= IFCMATERIALLAYERSETUSAGE(#153,.AXIS2.,.POSITIVE.,0.);
  #244= IFCRELASSOCIATESMATERIAL('3rezN6ZsexG8ShnqMhP$g5',#13,$,$,(#170),#155);
  #170= IFCWALLSTANDARDCASE('0lJANQLbCEHPkU1Xq9w_bk',#13,'Wand-001',$,$,#167,#240,'2F4CA5DA-5653-0E45-9B-9E-061D09EBE96E');

    #copy from IfcWall, needs cleaning up
    class IfcWallStandardCase < IfcWall
      # Attribute	      Type	                            Defined By
      # GlobalId	      IfcGloballyUniqueId (STRING)	    IfcRoot
      # OwnerHistory	  IfcOwnerHistory (ENTITY)	        IfcRoot
      # Name	          IfcLabel (STRING)	                IfcRoot     OPTIONAL
      # Description	    IfcText (STRING)	                IfcRoot     OPTIONAL
      # ObjectType	    IfcLabel (STRING)	                IfcObject   OPTIONAL
      # ObjectPlacement	IfcObjectPlacement (ENTITY)	      IfcProduct  OPTIONAL
      # Representation	IfcProductRepresentation (ENTITY)	IfcProduct  OPTIONAL
      # Tag           	IfcIdentifier (STRING)	          IfcElement  OPTIONAL
      attr_accessor :record_nr
      def initialize(project, ifc_exporter, planar)
        @project = project
        @ifc_exporter = ifc_exporter
        @planar = planar
        @entityType = "IFCWALLSTANDARDCASE"
        @ifc_exporter.add(self)
    
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_globalId(planar)
        @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr
        @a_Attributes << set_name(planar)
        @a_Attributes << set_description(planar)
        @a_Attributes << set_objectType("Planar")
        @a_Attributes << set_objectPlacement(planar).record_nr
        @a_Attributes << set_representations.record_nr
        @a_Attributes << set_tag(planar)
        
        # define openings
        openings
        
        set_BaseQuantities
        set_materials
        
        #add self to the list of entities contained in the building
        @ifc_exporter.add_to_building(self)
      end
      def set_materials
        if @planar.source.material.nil?
          material_name = "Default"
        else
          material_name = @planar.source.material.name
        end
        layerThickness = @planar.width
        aMaterialLayers = Array.new
        aMaterialLayers << IfcMaterialLayer.new(@ifc_exporter, material_name, layerThickness).record_nr
        sLayerSetName = layerThickness.to_s + " " + material_name
        materialLayerSet = IfcMaterialLayerSet.new(@ifc_exporter, aMaterialLayers, sLayerSetName)
        materialLayerSetUsage = IfcMaterialLayerSetUsage.new(@ifc_exporter, materialLayerSet)
        aRelatedObjects = Array.new
        aRelatedObjects << self.record_nr
        IfcRelAssociatesMaterial.new(@ifc_exporter, aRelatedObjects, materialLayerSetUsage)
      end
      def set_objectPlacement(bt_entity)
        
        #parent transformation
        transformation_parent = nil
        
        #entity transformation, rotated for IfcWallStandardCase
        if bt_entity.nil?
          transformation = nil
        else
          # hij moet draaien om de interne as van de group en niet om die van de oorsprong!!!!!!!!!!!!!!
          t_bt_entity = bt_entity.geometry.transformation
          #xaxis = t_bt_entity.xaxis
          #yaxis = t_bt_entity.zaxis.reverse
          #origin = t_bt_entity.origin
          #transformation = Geom::Transformation.new(origin, xaxis, yaxis)
          point = Geom::Point3d.new(0, 0, 0)
          vector = Geom::Vector3d.new(1, 0, 0)
          angle = Math::PI / -2
          rotation = Geom::Transformation.rotation(point, vector, angle)
          transformation = t_bt_entity * rotation
        end
        return IfcLocalPlacement.new(@ifc_exporter, transformation_parent, transformation)
      end
      def set_representations
        aRepresentations = Array.new
        aCurve2d = Array.new
        aPath = Array.new
        aPath << Geom::Point3d.new(0,0,0)
        aPath << Geom::Point3d.new(@planar.length?,0,0)
        aSweptSolid = Array.new
        projection = get_projection(@planar)
        loop = projection
        aCurve2d << IfcPolyline.new(@ifc_exporter, @planar, aPath, false).record_nr
        aSweptSolid << WscIfcExtrudedAreaSolid.new(@ifc_exporter, @planar, loop, @planar.height?).record_nr
  #201= IFCSHAPEREPRESENTATION(#51,'Axis','Curve2D',(#197));
        aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Axis'", "'Curve2D'", aCurve2d).record_nr # SweptSolid Representation
        aRepresentations << IfcShapeRepresentation.new(@ifc_exporter, "'Body'", "'SweptSolid'", aSweptSolid).record_nr # SweptSolid Representation
        #group.erase!
        #aRepresentations.each do|representation|
          IfcStyledItem.new(@ifc_exporter, aCurve2d[0], @planar.source)
          IfcStyledItem.new(@ifc_exporter, aSweptSolid[0], @planar.source)
        #end
        return IfcProductDefinitionShape.new(@ifc_exporter, @planar, aRepresentations)
      end
      
      # returns the loop (and group) of the vertical projection of the wall
      # Make sure you delete the temporary group afterwards
      # based on clsPlanarElement.get_openings
      def get_projection(bt_entity)
        @geometry = bt_entity.geometry
        loop = nil
        group = Sketchup.active_model.entities.add_group
        
          point = Geom::Point3d.new(0, 0, 0)
          vector = Geom::Vector3d.new(1, 0, 0)
          angle = Math::PI / -2
          rotation = Geom::Transformation.rotation(point, vector, angle)
          group.transform! rotation
        
        #transform =  group.transformation.invert! * instance.transformation
      
        # copy all geometry edges to the new group
        #@geometry.entities.each do |entity|
          #if entity.is_a?(Sketchup::Edge)
            #new_start = entity.start.position.transform rotation.inverse
            #new_start.z= 0
            #new_end = entity.end.position.transform rotation.inverse
            #new_end.z= 0
            #group.entities.add_edges new_start, new_end
          #end
        #end
        
        ## intersect all edges
        #faces=[]
        #group.entities.each do |entity|
          #faces << entity
        #end
        #group.entities.intersect_with false, group.transformation, group.entities, group.transformation, true, faces
        
        aEdges = Array.new
        
          # copy all edges that are on the x-y plane to the new group
          @geometry.entities.each do |entity|
            if entity.is_a?(Sketchup::Edge)
                  new_start = entity.start.position.transform rotation.inverse
                  new_start.z= 0
                  new_end = entity.end.position.transform rotation.inverse
                  new_end.z= 0
                  
                  edge = group.entities.add_line new_start, new_end
                  unless edge.nil?
                    aEdges << edge
                  end
            end
          end

        group.entities.intersect_with false, group.transformation, group.entities, group.transformation, true, aEdges
        
        # create all possible faces
        group.entities.each do |entity|
          
          if entity.is_a?(Sketchup::Edge)
            entity.find_faces
          end
        end
        
        # delete unneccesary edges
        group.entities.each do |entity|
          if entity.is_a?(Sketchup::Edge)
            if entity.faces.length != 1
              entity.erase!
            end
          end
        end
        # delete unneccesary edges #twice??? not all edges removed in the first run...
        group.entities.each do |entity|
          if entity.is_a?(Sketchup::Edge)
            if entity.faces.length != 1
              entity.erase!
            end
          end
        end
        
        
        #find all outer loops of the cutting component
        group.entities.each do |entity|
          if entity.is_a?(Sketchup::Face)
            loop = entity.outer_loop
          end
        end
        points = Array.new
        loop.vertices.each do |vert|
          points << vert.position
        end
        group.erase!
        return points
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
    
  #18=IFCBUILDING('ABCDEFGHIJKLMNOPQ00002',#9,'Testgebouw ','Omschrijving',$,$,$,$,.ELEMENT.,$,$,$);
    class IfcBuilding < IfcProduct
      # Attribute	            Type	                            Defined By
      # GlobalId	            IfcGloballyUniqueId (STRING)	    IfcRoot
      # OwnerHistory	        IfcOwnerHistory (ENTITY)	        IfcRoot
      # Name	                IfcLabel (STRING)	                IfcRoot
      # Description	          IfcText (STRING)	                IfcRoot
      # ObjectType	          IfcLabel (STRING)	                IfcObject
      # ObjectPlacement	      IfcObjectPlacement (ENTITY)	      IfcProduct
      # Representation	      IfcProductRepresentation (ENTITY)	IfcProduct
      # LongName	            IfcLabel (STRING)	                IfcSpatialStructureElement
      # CompositionType	      IfcElementCompositionEnum (ENUM)	IfcSpatialStructureElement
      # ElevationOfRefHeight	IfcLengthMeasure (REAL)	          IfcBuilding
      # ElevationOfTerrain	  IfcLengthMeasure (REAL)	          IfcBuilding
      # BuildingAddress	      IfcPostalAddress (ENTITY)	        IfcBuilding
      def initialize(ifc_exporter)
        @project = ifc_exporter.project
        @ifc_exporter = ifc_exporter
        @entityType = "IFCBUILDING"
        @ifc_exporter.add(self)
        
        # TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        #41 = IFCRELAGGREGATES('2QTqyzvgj6qBjsx1U3rHkG', #2, 'BuildingContainer', 'BuildingContainer for BuildigStories', #29, (#35));
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "'" + @project.building_guid + "'"
        @a_Attributes << @ifc_exporter.ifcProject.ifcOwnerHistory.record_nr #set_ownerHistory()
        @a_Attributes << set_name
        @a_Attributes << set_description
        @a_Attributes << "$"
        @a_Attributes << "$"# set_objectPlacement().record_nr
        @a_Attributes << "$"
        @a_Attributes << "$"
        @a_Attributes << ".ELEMENT."
        @a_Attributes << "$"
        @a_Attributes << "$"
        @a_Attributes << "$"
      end
      def set_name
        if @project.building_name.nil?
          return "$"
        else
          return "'" + @project.building_name + "'"
        end
      end
      def set_description
        if @project.building_description.nil?
          return "$"
        else
          return "'" + @project.building_description + "'"
        end
      end
    end
    
    #copy from ifcplate, needs cleaning up
    class IfcSlab < IfcPlate
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
        @a_Attributes << set_representations.record_nr #optional
        @a_Attributes << set_tag(planar) #optional
        @a_Attributes << ifcSlabTypeEnum(planar) #optional
        
        # define openings
        openings
        
        #add self to the list of entities contained in the building
        @ifc_exporter.add_to_building(self)
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
        @a_Attributes << "'BuildingContainer'" # only correct for site!!!
        @a_Attributes << "'Contents of Building'" # only correct for site!!!
        @a_Attributes << @ifc_exporter.ifcList(@ifc_exporter.aContainedInBuilding)
        @a_Attributes << @ifc_exporter.ifcBuilding.record_nr
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
  end # module BimTools
end # module Brewsky
