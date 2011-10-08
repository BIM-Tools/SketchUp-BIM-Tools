#       IFCexporter.rb
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

class IFCexporter

	def initialize(bt_lib)
		@model=Sketchup.active_model
		path=@model.path.tr("\\", "/")
		if not path or path==""
			UI.messagebox("IFC Exporter:\n\nPlease save your project before Exporting to IFC\n")
			return nil
		end
		@project_path=File.dirname(path)
		@title=@model.title
		@skpName=@title
		@selection=@model.selection
		@bt_lib = bt_lib
		@aExport = bt_lib.list #Array will contain all objects from the selection that can be exported
		
		if @aExport.length > 0 #if exportable objects have been found, start exporter
			self.export()
		end
	end

	def export()
	  Sketchup.set_status_text("IFCExporter: Exporting IFC entities...") # inform user that ifc-export is running
	  
		require 'bim-tools\ifc_classes.rb' #contains all ifc-object classes
	  
		ifc_name = @skpName + ".ifc"
		ifc_filepath=File.join(@project_path, ifc_name)
		export_base_file = File.basename(@model.path, ".skp") + ".ifc"
		ifc_array = Array.new
		
		# create ifc objects
		project = IfcProject.new(ifc_array.length)
		header = IfcHeader.new(export_base_file)
		footer = IfcFooter.new()
		
		# gather ifc data
		ifc_array = ifc_array + project.get_ifc()

		contained_in_spatial_structure_index = ifc_array.length
		# object keeps track of elements in building storey
		ifc_array[contained_in_spatial_structure_index] = 0
		contained_in_spatial_structure = IfcRelContainedInSpatialStructure.new(contained_in_spatial_structure_index, project.building_storey)
		
		#wall to include test opening
		@cut_wall = 0#testing
		
		# loop function for creating walls
		@aExport.each { |building_element|
			if building_element.instance_of? BtWall
				wall = IfcWallStandardCase.new(ifc_array.length, building_element)
				ifc_array = ifc_array + wall.get_ifc()
				wall_index = wall.index
				building_element.ifc_set_id(wall_index)#opening needs an index from parent, best to create a single wall class, no sperate ifc class!!!
				contained_in_spatial_structure.add_element(wall_index) # add wall to building storey, #improvement_needed#
			elsif building_element.instance_of? BtOpening
				opening = IfcOpeningElement.new(ifc_array.length, building_element) # create a test opening
				ifc_array = ifc_array + opening.get_ifc() # add a test opening to the ifc file
			end
		}
		
		ifc_array[contained_in_spatial_structure_index] = contained_in_spatial_structure.get_ifc[0] # update the object containing all elements in building storey
		ifc_array = header.get_ifc() + ifc_array + footer.get_ifc() # add up all seperate sections to total ifc_array

		File.open(ifc_filepath, 'w') do |file|
			ifc_array.each do |record|
				if record
					file.write(record + "\n")
				end
			end
		end
	end

end#class IFCexporter
