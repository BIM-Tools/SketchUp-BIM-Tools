#       clsIfcUnits.rb
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
  
    # classes for defining IFC units
    
    #7 = IFCUNITASSIGNMENT((#8, #9, #10, #11, #15, #16, #17, #18, #19));
    #8 = IFCSIUNIT(*, .LENGTHUNIT., $, .METRE.);
    #9 = IFCSIUNIT(*, .AREAUNIT., $, .SQUARE_METRE.);
    #10 = IFCSIUNIT(*, .VOLUMEUNIT., $, .CUBIC_METRE.);
    #11 = IFCCONVERSIONBASEDUNIT(#12, .PLANEANGLEUNIT., 'DEGREE', #13);
    #12 = IFCDIMENSIONALEXPONENTS(0, 0, 0, 0, 0, 0, 0);
    #13 = IFCMEASUREWITHUNIT(IFCPLANEANGLEMEASURE(1.745E-2), #14);
    #14 = IFCSIUNIT(*, .PLANEANGLEUNIT., $, .RADIAN.);
    #15 = IFCSIUNIT(*, .SOLIDANGLEUNIT., $, .STERADIAN.);
    #16 = IFCSIUNIT(*, .MASSUNIT., $, .GRAM.);
    #17 = IFCSIUNIT(*, .TIMEUNIT., $, .SECOND.);
    #18 = IFCSIUNIT(*, .THERMODYNAMICTEMPERATUREUNIT., $, .DEGREE_CELSIUS.);
    #19 = IFCSIUNIT(*, .LUMINOUSINTENSITYUNIT., $, .LUMEN.);
    class IfcUnitAssignment < IfcBase
      # Attribute	Type	                  Defined By
      # Units	    SET OF IfcUnit (SELECT)	IfcUnitAssignment
      def initialize(ifc_exporter)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCUNITASSIGNMENT"
        @ifc_exporter.add(self)
        
        aUnits = Array.new
        aUnits << IfcSIUnit.new(@ifc_exporter, ".LENGTHUNIT.", ".METRE.").record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".AREAUNIT.", ".SQUARE_METRE.").record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".VOLUMEUNIT.", ".CUBIC_METRE.").record_nr
        aUnits << IfcConversionBasedUnit.new(@ifc_exporter).record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".SOLIDANGLEUNIT.", ".STERADIAN.").record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".MASSUNIT.", ".GRAM.").record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".TIMEUNIT.", ".SECOND.").record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".THERMODYNAMICTEMPERATUREUNIT.", ".DEGREE_CELSIUS.").record_nr
        aUnits << IfcSIUnit.new(@ifc_exporter, ".LUMINOUSINTENSITYUNIT.", ".LUMEN.").record_nr
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << @ifc_exporter.ifcList(aUnits)
      end
    end
    
    class IfcSIUnit < IfcBase
      # Attribute	  Type	                            Defined By
      # Dimensions*	IfcDimensionalExponents (ENTITY)	IfcSIUnit(Redcl from IfcNamedUnit)
      # UnitType	  IfcUnitEnum (ENUM)	              IfcNamedUnit
      # Prefix	    IfcSIPrefix (ENUM)	              IfcSIUnit
      # Name	      IfcSIUnitName (ENUM)	            IfcSIUnit
      def initialize(ifc_exporter, unitType, name)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCSIUNIT"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "*"
        @a_Attributes << unitType
        @a_Attributes << "$"
        @a_Attributes << name
      end
    end
    
    #11 = IFCCONVERSIONBASEDUNIT(#12, .PLANEANGLEUNIT., 'DEGREE', #13);
    #12 = IFCDIMENSIONALEXPONENTS(0, 0, 0, 0, 0, 0, 0);
    #13 = IFCMEASUREWITHUNIT(IFCPLANEANGLEMEASURE(1.745E-2), #14);
    #14 = IFCSIUNIT(*, .PLANEANGLEUNIT., $, .RADIAN.);
    class IfcConversionBasedUnit < IfcBase
      # Attribute	        Type	                            Defined By
      # Dimensions	      IfcDimensionalExponents (ENTITY)	IfcNamedUnit
      # UnitType	        IfcUnitEnum (ENUM)	              IfcNamedUnit
      # Name	            IfcLabel (STRING)	                IfcConversionBasedUnit
      # ConversionFactor	IfcMeasureWithUnit (ENTITY)	      IfcConversionBasedUnit
      def initialize(ifc_exporter)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCCONVERSIONBASEDUNIT"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << IfcDimensionalExponents.new(@ifc_exporter).record_nr
        @a_Attributes << ".PLANEANGLEUNIT."
        @a_Attributes << "'DEGREE'"
        @a_Attributes << IfcMeasureWithUnit.new(@ifc_exporter).record_nr
      end
    end
    
    
    #12 = IFCDIMENSIONALEXPONENTS(0, 0, 0, 0, 0, 0, 0);
    class IfcDimensionalExponents < IfcBase
      def initialize(ifc_exporter)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCDIMENSIONALEXPONENTS"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "0"
        @a_Attributes << "0"
        @a_Attributes << "0"
        @a_Attributes << "0"
        @a_Attributes << "0"
        @a_Attributes << "0"
        @a_Attributes << "0"
      end
    end
    
    #13 = IFCMEASUREWITHUNIT(IFCPLANEANGLEMEASURE(1.745E-2), #14);
    #14 = IFCSIUNIT(*, .PLANEANGLEUNIT., $, .RADIAN.);
    class IfcMeasureWithUnit < IfcBase
      def initialize(ifc_exporter)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCMEASUREWITHUNIT"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << "IFCPLANEANGLEMEASURE(1.745E-2)"
        @a_Attributes << IfcSIUnit.new(@ifc_exporter, ".PLANEANGLEUNIT.", ".RADIAN.").record_nr
      end
    end
  end # module BimTools
end # module Brewsky
