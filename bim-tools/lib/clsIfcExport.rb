#       clsIfcExport.rb
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

  require 'bim-tools/lib/ifc/clsIfcBase.rb'
  require 'bim-tools/lib/ifc/clsIfcUnits.rb'
  require 'bim-tools/lib/ifc/clsIfcGeometry.rb'
  require 'bim-tools/lib/ifc/clsIfcBuilding.rb'
  
  # basic IFC export class
  class IfcExporter
    attr_reader :a_Ifc, :ifcProject, :ifcOrganisation, :project, :ifcOwnerHistory, :ifcGeometricRepresentationContext, :ifcSite, :ifcBuilding, :aContainedInBuilding
    def initialize(project, selection=nil)
      @model=Sketchup.active_model
      @project = project
      # "total" IFC array
      @a_Ifc = Array.new
      
      # This array will hold the record numbers of all entities that are direct "child" objects to the site
      @aContainedInBuilding = Array.new
      
      # create IfcProject object
      set_IfcProject
      
      # create IfcSite object
      set_IfcSite(@ifcProject)
      
      set_IfcBuilding(@ifcSite)
  
      path=@model.path.tr("\\", "/")
      if not path or path==""
        UI.messagebox("IFC Exporter:\n\nPlease save your project before Exporting to IFC\n")
        return nil
      end
      @project_path=File.dirname(path)
      @title=@model.title
      @skpName=@title
      @bt_lib = project.library
      @aExport = @bt_lib.entities #Array will contain all objects from the selection that can be exported
        
      aEntities = get_entities
      if aEntities.length > 0 #if exportable objects have been found, start exporter
        self.export(aEntities)
      else
        UI.messagebox("IFC Exporter:\n\nNo entities to export to IFC.\nExport failed.\n")
      end
    end
    def export(aEntities)
      Sketchup.set_status_text("IFCExporter: Exporting IFC entities...") # inform user that ifc-export is running
  
      ifc_name = @skpName + ".ifc"
      ifc_filepath=File.join(@project_path, ifc_name)
      export_base_file = File.basename(@model.path, ".skp") + ".ifc"
      
      # create empty site container object
      container = IfcRelContainedInSpatialStructure.new(self)
      
      aEntities.each do |bt_entity|
        bt_entity.ifc_export(self)
      end
      
      # fill site container object with ifc entities
      container.fill()
  
      File.open(ifc_filepath, 'w') do |file|
        file.write(self.ifc)
      end
    end
    def get_entities()
      selection=@model.selection
      bt_entities = Array.new
      if selection.length == 0
        bt_entities = @project.library.entities
      else
        selection.each do |entity|
          bt_entity = @project.library.geometry_to_bt_entity(@project, entity)
          unless bt_entity.nil?
            bt_entities << bt_entity
          end
        end
      end
      return bt_entities
    end
    def add(entity)
      new_record_nr = @a_Ifc.length + 1
      new_record_nr = "#" + new_record_nr.to_s
      entity.record_nr=(new_record_nr)
      @a_Ifc << entity
    end
    
    def set_IfcProject()
      @ifcProject = IfcProject.new(self)
    end
    
    def set_IfcOwnerHistory()
      if @ifcOwnerHistory.nil?
        @ifcOwnerHistory = IfcOwnerHistory.new(self)
      end
      return @ifcOwnerHistory # is this needed or automatically returned?
    end
    
    def set_IfcOrganization()
      if @ifcOrganization.nil?
        organisation_name = "'" + @project.organisation_name + "'"
        organisation_description = "'" + @project.organisation_description + "'"
        @ifcOrganization = IfcOrganization.new(self, organisation_name, organisation_description)
      end
      return @ifcOrganization
    end
    
    def set_IfcGeometricRepresentationContext()
      if @ifcGeometricRepresentationContext.nil?
        @ifcGeometricRepresentationContext = IfcGeometricRepresentationContext.new(self)
      end
      return @ifcGeometricRepresentationContext
    end
    
    def set_IfcSite(project)
      if @ifcSite.nil?
        @ifcSite = IfcSite.new(self)
        # IFCRELAGGREGATES('1hGct2v1LFjuexLy7xe$Mo', #2, 'ProjectContainer', 'ProjectContainer for Sites', #1, (#23));
        name = "'ProjectContainer'"
        description = "'ProjectContainer for Sites'"
        IfcRelAggregates.new(self, name, description, project, @ifcSite)
      end
      return @ifcSite
    end
    
    # create a building on the site, temporary solution because multiple buildings could be present
    def set_IfcBuilding(site)
      if @ifcBuilding.nil?
        @ifcBuilding = IfcBuilding.new(self)
        # IFCRELAGGREGATES('1_M0EvY2z24AX0l7nBeVj1', #2, 'SiteContainer', 'SiteContainer For Buildings', #23, (#29));
        name = "'SiteContainer'"
        description = "'SiteContainer For Buildings'"
        IfcRelAggregates.new(self, name, description, site, @ifcBuilding)
      end
      return @ifcBuilding
    end
    
    def add_to_building(ifc_entity)
      @aContainedInBuilding << ifc_entity.record_nr
    end
    
    # returns a string containing the full IFC file
    def ifc
      @a_Ifc
      s_EntityRecords = ""
      @a_Ifc.each do |ifcEntity|
        s_EntityRecords = s_EntityRecords + ifcEntity.record
      end
      return header + s_EntityRecords + footer
    end
    
    # returns a string containing a ifc entity's record/line
    def ifcRecord(ifcEntity)
      entityType = ifcEntity.entityType
      recordNr = ifcEntity.record_nr
      s_Attributes = ifcEntity.a_Attributes.join ', '
      return recordNr + " = " + entityType + "(" + s_Attributes + ");\n"
    end
    def header
      #@export_base_file = export_base_file
      time = Time.new
      @timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
      @author = @model.get_attribute "ifc", "author", "Architect"
      @organization = @model.get_attribute "ifc", "organization", "Building Designer Office"
      @preprocessor_version = "BIM-Tools"
      @originating_system = "example"
      @authorization = @model.get_attribute "ifc", "authorization", "The authorising person"
      
      return "ISO-10303-21;
HEADER;
FILE_DESCRIPTION (('ViewDefinition [CoordinationView]'), '2;1');
FILE_NAME ('" + @skpName + ".ifc', '" + @timestamp + "', ('" + @author + "'), ('" + @organization + "'), '" + @preprocessor_version + "', '" + @originating_system + "', '" + @authorization + "');
FILE_SCHEMA (('IFC2X3'));
ENDSEC;
DATA;
"
    end
    def footer
      return "ENDSEC;
END-ISO-10303-21;
"
    end
  
    # returns a length converted to m, as a string
    def ifcLengthMeasure(number)
      return sprintf('%.8f', number.to_m).sub(/0{1,8}$/, '')
    end
  
    # returns a length converted to m, as a string
    def ifcAreaMeasure(number)
      return sprintf('%.8f', number.to_m).sub(/0{1,8}$/, '') # not correct for area!!!
    end
  
    # returns a length converted to m, as a string
    def ifcVolumeMeasure(number)
      return sprintf('%.8f', number.to_m).sub(/0{1,8}$/, '') # not correct for area!!!
    end
    
    # returns the value as a string
    def ifcLabel(value)
      return "'" + value + "'"
    end
    
    # returns a Real number, rounded down, as a string
    def ifcReal(number)
      return sprintf('%.8f', number).sub(/0{1,8}$/, '')
    end
  
    # returns a IFC list-string out of an array
    def ifcList(aList)
      sList = "("
      if aList.is_a? Array
        aList.each_index do |index|
          sList = sList + aList[index]
          unless aList.length - 1 == index
            sList = sList + ","
          end
        end
      else
        sList = sList + aList
      end
      sList = sList + ")"
      return sList
    end
  end
  
#  class IfcHeader
#    attr_accessor :header, :footer
#    def initialize
#      @header = "ISO-10303-21;
#HEADER;
#FILE_DESCRIPTION (('ViewDefinition [CoordinationView]'), '2;1');
#FILE_NAME ('test.ifc', '2012-01-01T11:11:11', ('Architect'), ('Building Designer Office'), 'BIM-Tools', 'example', 'The authorising person');
#FILE_SCHEMA (('IFC2X3'));
#ENDSEC;
#DATA;
#"
#      @footer = "ENDSEC;
#END-ISO-10303-21;
#"
#    end
#  end

end
