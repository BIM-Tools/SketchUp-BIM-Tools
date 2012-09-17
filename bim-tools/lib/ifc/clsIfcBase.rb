#       clsIfcBase.rb
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

module Brewsky::BimTools
  
  # basic IFC classes
  
  # IFC export base element
  class IfcBase
    attr_accessor :record_nr, :a_Attributes, :entityType
    
    # returns a new row number
    def record_nr=(s_record_nr)
      @record_nr = s_record_nr
    end
    
    # function returns IFC "content"
    def record_content
      return ""
    end
    
    # function creates full IFC record
    def record
      return @ifc_exporter.ifcRecord(self)
      #return @record_nr + " = " + record_content + ";
  #"
    end
  end
  
  class IfcQuantityLength < IfcBase
  # Attribute	  Type	                  Defined By
  # Name	      IfcLabel (STRING)	      IfcPhysicalQuantity
  # Description	IfcText (STRING)	      IfcPhysicalQuantity
  # Unit	      IfcNamedUnit (ENTITY)	  IfcPhysicalSimpleQuantity
  # LengthValue	IfcLengthMeasure (REAL)	IfcQuantityLength
    attr_accessor :record_nr
    def initialize(ifc_exporter, name, value)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCQUANTITYLENGTH"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << ifc_exporter.ifcLabel(name)
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << ifc_exporter.ifcLengthMeasure(value)
    end
  end
  
  class IfcQuantityArea < IfcBase
  # Attribute	  Type	                  Defined By
  # Name	      IfcLabel (STRING)	      IfcPhysicalQuantity
  # Description	IfcText (STRING)	      IfcPhysicalQuantity
  # Unit	      IfcNamedUnit (ENTITY)	  IfcPhysicalSimpleQuantity
  # AreaValue	  IfcAreaMeasure (REAL)	  IfcQuantityArea
    attr_accessor :record_nr
    def initialize(ifc_exporter, name, value)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCQUANTITYAREA"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << ifc_exporter.ifcLabel(name)
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << ifc_exporter.ifcAreaMeasure(value)
    end
  end
  
  class IfcQuantityVolume < IfcBase
  # Attribute	    Type	                  Defined By
  # Name	        IfcLabel (STRING)	      IfcPhysicalQuantity
  # Description	  IfcText (STRING)	      IfcPhysicalQuantity
  # Unit	        IfcNamedUnit (ENTITY)	  IfcPhysicalSimpleQuantity
  # VolumeValue	  IfcVolumeMeasure (REAL)	IfcQuantityVolume
    attr_accessor :record_nr
    def initialize(ifc_exporter, name, value)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCQUANTITYVOLUME"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << ifc_exporter.ifcLabel(name)
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << ifc_exporter.ifcVolumeMeasure(value)
    end
  end
  
  class IfcRoot < IfcBase
    attr_accessor :globalId, :name, :description, :record_nr#, :ownerHistory
    def set_globalId(entity=nil)
      if entity.nil?
        
        # generate new guid
        @globalId = "'" + @ifc_exporter.project.new_guid + "'"
      else
        @globalId = "'" + entity.guid? + "'"
      end
      return @globalId
    end
    #def set_ownerHistory()
    #  @ownerHistory = IfcOwnerHistory.new(@ifc_exporter, @project).record_nr
    #end
    def set_name(entity=nil)
      if entity.nil?
          @name = "$"
      else
        if entity.name?.nil? || entity.name? == ""
          @name = "$"
        else
          @name = entity.name?
        end
      end
      return @name
    end
    def set_description(entity=nil)
      if entity.nil?
          @description = "$"
      else
        if entity.description?.nil? || entity.description? == ""
          @description = "$"
        else
          @description = entity.description?
        end
      end
      return @description
    end
  end
  
  class IfcObject < IfcRoot
    attr_accessor :objectType
    def set_objectType(entity)
      @objectType = "$"
    end
  end
  
  #1 = IFCPROJECT('0YvctVUKr0kugbFTf53O9L', #2, 'Default Project', 'Description of Default Project', $, $, $, (#20), #7);
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
  class IfcProject < IfcObject
    # Attribute	              Type	                                    Defined By
    # GlobalId	              IfcGloballyUniqueId (STRING)	            IfcRoot
    # OwnerHistory	          IfcOwnerHistory (ENTITY)	                IfcRoot
    # Name	                  IfcLabel (STRING)	                        IfcRoot
    # Description	            IfcText (STRING)	                        IfcRoot
    # ObjectType	            IfcLabel (STRING)	                        IfcObject
    # LongName	              IfcLabel (STRING)	                        IfcProject
    # Phase	                  IfcLabel (STRING)	                        IfcProject
    # RepresentationContexts	SET OF IfcRepresentationContext (ENTITY)	IfcProject
    # UnitsInContext	        IfcUnitAssignment (ENTITY)	              IfcProject
    attr_accessor :record_nr, :ifcOwnerHistory
    def initialize(ifc_exporter)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCPROJECT"
      @ifc_exporter.add(self)
      @ifcOwnerHistory = IfcOwnerHistory.new(@ifc_exporter)
      ifcUnitAssignment = IfcUnitAssignment.new(@ifc_exporter)
      aIfcGeometricRepresentationContext = Array.new
      aIfcGeometricRepresentationContext << @ifc_exporter.set_IfcGeometricRepresentationContext.record_nr#IfcGeometricRepresentationContext.new(@ifc_exporter, @project).record_nr
            
      # TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      #43 = IFCRELAGGREGATES('1hGct2v1LFjuexLy7xe$Mo', #2, 'ProjectContainer', 'ProjectContainer for Sites', #1, (#23));
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << "'" + @project.guid + "'"
      @a_Attributes << @ifcOwnerHistory.record_nr
      @a_Attributes << set_name
      @a_Attributes << set_description
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << @ifc_exporter.ifcList(aIfcGeometricRepresentationContext)
      @a_Attributes << ifcUnitAssignment.record_nr
    end
    def set_name
      if @project.name.nil?
        return "$"
      else
        return "'" + @project.name + "'"
      end
    end
    def set_description
      if @project.description.nil?
        return "$"
      else
        return "'" + @project.description + "'"
      end
    end
  end
  
  #2 = IFCOWNERHISTORY(#3, #6, $, .ADDED., $, $, $, 1217620436);
  class IfcOwnerHistory < IfcBase
    # Attribute	                Type	                            Defined By
    # OwningUser	              IfcPersonAndOrganization (ENTITY)	IfcOwnerHistory
    # OwningApplication	        IfcApplication (ENTITY)         	IfcOwnerHistory
    # State	                    IfcStateEnum (ENUM)	              IfcOwnerHistory (optional)
    # ChangeAction	            IfcChangeActionEnum (ENUM)	      IfcOwnerHistory
    # LastModifiedDate	        IfcTimeStamp (INTEGER)	          IfcOwnerHistory (optional)
    # LastModifyingUser	        IfcPersonAndOrganization (ENTITY)	IfcOwnerHistory (optional)
    # LastModifyingApplication  IfcApplication (ENTITY)	          IfcOwnerHistory (optional)
    # CreationDate	            IfcTimeStamp (INTEGER)	          IfcOwnerHistory
    attr_accessor :record_nr
    def initialize(ifc_exporter)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCOWNERHISTORY"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << IfcPersonAndOrganization.new(@ifc_exporter).record_nr
      @a_Attributes << IfcApplication.new(@ifc_exporter).record_nr
      @a_Attributes << "$"
      @a_Attributes << ".ADDED." # ???
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "1217620436" # !!!
    end
  end
  
  #3 = IFCPERSONANDORGANIZATION(#4, #5, $);
  class IfcPersonAndOrganization < IfcBase
    # Attribute	      Type	                        Defined By
    # ThePerson	      IfcPerson (ENTITY)	          IfcPersonAndOrganization
    # TheOrganization	IfcOrganization (ENTITY)	    IfcPersonAndOrganization
    # Roles           LIST OF IfcActorRole (ENTITY)	IfcPersonAndOrganization (optional)
    attr_accessor :record_nr
    def initialize(ifc_exporter)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCPERSONANDORGANIZATION"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << IfcPerson.new(@ifc_exporter).record_nr
      @a_Attributes << @ifc_exporter.set_IfcOrganization.record_nr
      @a_Attributes << "$"
    end
  end
  
  #4 = IFCPERSON('ID001', 'Bonsma', 'Peter', $, $, $, $, $);
  class IfcPerson < IfcBase
    # Attribute	    Type	                        Defined By
    # ID	          IfcIdentifier (STRING)	      IfcPerson (optional)
    # FamilyName	  IfcLabel (STRING)	            IfcPerson (optional)
    # GivenName	    IfcLabel (STRING)	            IfcPerson (optional)
    # MiddleNames	  LIST OF IfcLabel (STRING)	    IfcPerson (optional)
    # PrefixTitles	LIST OF IfcLabel (STRING)	    IfcPerson (optional)
    # SuffixTitles	LIST OF IfcLabel (STRING)	    IfcPerson (optional)
    # Roles	        LIST OF IfcActorRole (ENTITY)	IfcPerson (optional)
    # Addresses	    LIST OF IfcAddress (ENTITY)	  IfcPerson (optional)
    attr_accessor :record_nr
    def initialize(ifc_exporter)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCPERSON"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
      @a_Attributes << "$"
    end
  end
  
  #5 = IFCORGANIZATION($, 'TNO', 'TNO Building Innovation', $, $);
  class IfcOrganization < IfcBase
    # Attribute	    Type	                        Defined By
    # ID	          IfcIdentifier (STRING)	      IfcOrganization (optional)
    # Name      	  IfcLabel (STRING)	            IfcOrganization
    # Description	  IfcText (STRING)	            IfcOrganization (optional)
    # Roles	        LIST OF IfcActorRole (ENTITY)	IfcOrganization (optional)
    # Addresses	    LIST OF IfcAddress (ENTITY)	  IfcOrganization (optional)
    attr_accessor :record_nr
    def initialize(ifc_exporter, organisation_name="$", organisation_description="$")
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCORGANIZATION"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      @a_Attributes << "$"
      @a_Attributes << organisation_name
      @a_Attributes << organisation_description
      @a_Attributes << "$"
      @a_Attributes << "$"
    end
  end
  
  #6 = IFCAPPLICATION(#5, '0.10', 'Test Application', 'TA 1001');
  class IfcApplication < IfcBase
    # Attribute	            Type	                    Defined By
    # ApplicationDeveloper	IfcOrganization (ENTITY)	IfcApplication
    # Version	              IfcLabel (STRING)	        IfcApplication
    # ApplicationFullName	  IfcLabel (STRING)	        IfcApplication
    # ApplicationIdentifier	IfcIdentifier (STRING)	  IfcApplication
    attr_accessor :record_nr
    def initialize(ifc_exporter)
      @ifc_exporter = ifc_exporter
      @project = ifc_exporter.project
      @entityType = "IFCAPPLICATION"
      @ifc_exporter.add(self)
      
      # "local" IFC array
      @a_Attributes = Array.new
      #@a_Attributes << @ifc_exporter.set_IfcOrganization.record_nr
      @a_Attributes << IfcOrganization.new(@ifc_exporter, "'BIM-Tools Project'", "'Open source Building-modeller project'").record_nr
      @a_Attributes << "'0.11.0'"
      @a_Attributes << "'BIM-Tools for SketchUp'"
      @a_Attributes << "'BIM-Tools'"
    end
  end

end
