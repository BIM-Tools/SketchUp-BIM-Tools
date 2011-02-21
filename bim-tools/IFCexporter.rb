#       ifc-export.rb
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

class IFCexporter

	def initialize()
			@model=Sketchup.active_model
			path=@model.path.tr("\\", "/")
			if not path or path==""
					UI.messagebox("IFC Exporter:\n\nSave the SKP before Exporting it as IFC\n")
					return nil
			end
			@project_path=File.dirname(path)
			@title=@model.title
			@skpName=@title
			@selection=@model.selection
			self.export()
	end

	def export
	  Sketchup.set_status_text("IFCExporter: Exporting IFC entities...")
		@ifc_="true"
        @ifc_name=@skpName
        @ifc_name=@ifc_name+".ifc"
        @ifc_filepath=File.join(@project_path, @ifc_name)
    
    # function generates random string for object ID´s 
		def random_string(length=22)
        chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
        string = ''
        length.times { string << chars[rand(chars.size)] }
        string
    end
		
		# IFC info, needs to be editable from sketchup
		author = "Architect"
		organization = "Building Designer Office"
		preprocessor_version = "SU2IFC01"
		originating_system = "SU2IFC01"
		authorization = "The authorising person"
		project_id = random_string
		project_name = @model.title
		project_description = @model.description
		owner_creation_date = "1296506003"
		person_id = "ID001"
		person_familyname = "Lastname"
		person_givenname = "Firstname"
		organisation_name = "Company"
		organisation_description = "Company description"
		application_version = "0.01"
		application_name = "SU2IFC"
		application_identifier = "SU2IFC01"
		site_id = random_string
		site_name = "Default Site"
		site_description = "Description of Default Site"
		building_id = random_string
		building_name = "Default Building"
		building_description = "Description of Default Building"
		buildingstorey_id = random_string
		buildingstorey_name = "Default Building Storey"
		buildingstorey_description = "Description of Default Building Storey"
		buildingcontainer_id = random_string
		buildingcontainer_name = "BuildingContainer"
		buildingcontainer_description = "BuildingContainer for BuildingStories"
		sitecontainer_id = random_string
		sitecontainer_name = "SiteContainer"
		sitecontainer_description = "SiteContainer For Buildings"
		projectcontainer_id = random_string
		projectcontainer_name = "ProjectContainer"
		projectcontainer_description = "ProjectContainer for Sites"
		buildingstoreycontainer_id = random_string
		buildingstoreycontainer_name = "Default Building"
		buildingstoreycontainer_description = "Contents of Building Storey"

		export_base_file = File.basename(@model.path, ".skp") + ".ifc"
		time = Time.new
		timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
		
		# get project location
		local_coordinates = [0,0,0]
		local_point = Geom::Point3d.new(local_coordinates)
		ll = @model.point_to_latlong(local_point)
		lat = sprintf("%.4f", ll[0])
		long = sprintf("%.4f", ll[1])
		lat = lat.split('.')
		long = long.split('.')
		latpart = lat[1].split(//)
		longpart = long[1].split(//)
		lat = [lat[0], latpart[0] + latpart[1], latpart[2] + latpart[3]]
		long = [long[0], longpart[0] + longpart[1], longpart[2] + longpart[3]]
		
		# collect all items in array to write to file
		@export_content = Array.new
		@buildingstoreywalls = "#44 = IFCRELCONTAINEDINSPATIALSTRUCTURE('" + buildingstoreycontainer_id + "', #2, '" + buildingstoreycontainer_name + "', '" + buildingstoreycontainer_description + "', ("

		@export_content << "ISO-10303-21;"
		@export_content << "HEADER;"
		@export_content << "FILE_DESCRIPTION (('ViewDefinition [CoordinationView, QuantityTakeOffAddOnView]'), '2;1');"
		@export_content << "FILE_NAME ('" + export_base_file + "', '" + timestamp + "', ('" + author + "'), ('" + organization + "'), '" + preprocessor_version + "', '" + originating_system + "', '" + authorization + "');"
		@export_content << "FILE_SCHEMA (('IFC2X3'));"
		@export_content << "ENDSEC;"
		@export_content << "DATA;"
		@export_content << "#1 = IFCPROJECT('" + project_id + "', #2, '" + project_name + "', '" + project_description + "', $, $, $, (#20), #7);"
		@export_content << "#2 = IFCOWNERHISTORY(#3, #6, $, .ADDED., $, $, $, " + owner_creation_date + ");"
		@export_content << "#3 = IFCPERSONANDORGANIZATION(#4, #5, $);"
		@export_content << "#4 = IFCPERSON('" + person_id + "', '" + person_familyname + "', '" + person_givenname + "', $, $, $, $, $);"
		@export_content << "#5 = IFCORGANIZATION($, '" + organisation_name + "', '" + organisation_description + "', $, $);"
		@export_content << "#6 = IFCAPPLICATION(#5, '" + application_version + "', '" + application_name + "', '" + application_identifier + "');"
		@export_content << "#7 = IFCUNITASSIGNMENT((#8, #9, #10, #11, #15, #16, #17, #18, #19));"
		@export_content << "#8 = IFCSIUNIT(*, .LENGTHUNIT., .MILLI., .METRE.);"
		@export_content << "#9 = IFCSIUNIT(*, .AREAUNIT., $, .SQUARE_METRE.);"
		@export_content << "#10 = IFCSIUNIT(*, .VOLUMEUNIT., $, .CUBIC_METRE.);"
		@export_content << "#11 = IFCCONVERSIONBASEDUNIT(#12, .PLANEANGLEUNIT., 'DEGREE', #13);"
		@export_content << "#12 = IFCDIMENSIONALEXPONENTS(0, 0, 0, 0, 0, 0, 0);"
		@export_content << "#13 = IFCMEASUREWITHUNIT(IFCPLANEANGLEMEASURE(1.745E-2), #14);"
		@export_content << "#14 = IFCSIUNIT(*, .PLANEANGLEUNIT., $, .RADIAN.);"
		@export_content << "#15 = IFCSIUNIT(*, .SOLIDANGLEUNIT., $, .STERADIAN.);"
		@export_content << "#16 = IFCSIUNIT(*, .MASSUNIT., $, .GRAM.);"
		@export_content << "#17 = IFCSIUNIT(*, .TIMEUNIT., $, .SECOND.);"
		@export_content << "#18 = IFCSIUNIT(*, .THERMODYNAMICTEMPERATUREUNIT., $, .DEGREE_CELSIUS.);"
		@export_content << "#19 = IFCSIUNIT(*, .LUMINOUSINTENSITYUNIT., $, .LUMEN.);"
		@export_content << "#20 = IFCGEOMETRICREPRESENTATIONCONTEXT($, 'Model', 3, 1.000E-5, #21, $);"
		@export_content << "#21 = IFCAXIS2PLACEMENT3D(#22, $, $);"
		@export_content << "#22 = IFCCARTESIANPOINT((0., 0., 0.));"
		@export_content << "#23 = IFCSITE('" + site_id + "', #2, '" + site_name + "', '" + site_description + "', $, #24, $, $, .ELEMENT., (" + lat[0] + ", " + lat[1] + ", " + lat[2] + "), (" + long[0] + ", " + long[1] + ", " + long[2] + "), $, $, $);"
		@export_content << "#24 = IFCLOCALPLACEMENT($, #25);"
		@export_content << "#25 = IFCAXIS2PLACEMENT3D(#26, #27, #28);"
		@export_content << "#26 = IFCCARTESIANPOINT((0., 0., 0.));"
		@export_content << "#27 = IFCDIRECTION((0., 0., 1.));"
		@export_content << "#28 = IFCDIRECTION((1., 0., 0.));"
		@export_content << "#29 = IFCBUILDING('" + building_id + "', #2, '" + building_name + "', '" + building_description + "', $, #30, $, $, .ELEMENT., $, $, $);"
		@export_content << "#30 = IFCLOCALPLACEMENT(#24, #31);"
		@export_content << "#31 = IFCAXIS2PLACEMENT3D(#32, #33, #34);"
		@export_content << "#32 = IFCCARTESIANPOINT((0., 0., 0.));"
		@export_content << "#33 = IFCDIRECTION((0., 0., 1.));"
		@export_content << "#34 = IFCDIRECTION((1., 0., 0.));"
		@export_content << "#35 = IFCBUILDINGSTOREY('" + buildingstorey_id + "', #2, '" + buildingstorey_name + "', '" + buildingstorey_description + "', $, #36, $, $, .ELEMENT., 0.);"
		@export_content << "#36 = IFCLOCALPLACEMENT(#30, #37);"
		@export_content << "#37 = IFCAXIS2PLACEMENT3D(#38, #39, #40);"
		@export_content << "#38 = IFCCARTESIANPOINT((0., 0., 0.));"
		@export_content << "#39 = IFCDIRECTION((0., 0., 1.));"
		@export_content << "#40 = IFCDIRECTION((1., 0., 0.));"
		@export_content << "#41 = IFCRELAGGREGATES('" + buildingcontainer_id + "', #2, '" + buildingcontainer_name + "', '" + buildingcontainer_description + "', #29, (#35));"
		@export_content << "#42 = IFCRELAGGREGATES('" + sitecontainer_id + "', #2, '" + sitecontainer_name + "', '" + sitecontainer_description + "', #23, (#29));"
		@export_content << "#43 = IFCRELAGGREGATES('" + projectcontainer_id + "', #2, '" + projectcontainer_name + "', '" + projectcontainer_description + "', #1, (#23));"
		@export_content << "placeholder"#"#44 = IFCRELCONTAINEDINSPATIALSTRUCTURE('" + buildingstoreycontainer_id + "', #2, '" + buildingstoreycontainer_name + "', '" + buildingstoreycontainer_description + "', (#45), #35);"
		#in de vorige rij moet voor elke wand een nummer worden opgenomen
		record_buildingstorey = @export_content.length - 1
		@ifc_id = 44



		# loop function for creating walls
		@selection.each { |wall|
			
			if wall.material == nil
				wall_material = "Default material"
			else
				wall_material = wall.material.name
			end
			
			su_width = wall.get_attribute "ifc", "width"
			su_length = wall.get_attribute "ifc", "length"
			su_height = wall.get_attribute "ifc", "height"
		
			# determine the wall element´s position and direction
			group_transformation = wall.transformation
			# position Point3d object
			wall_position = group_transformation.origin
			wall_x = sprintf('%.6f', wall_position.x.to_mm).sub(/0{1,6}$/, '')
			wall_y = sprintf('%.6f', wall_position.y.to_mm).sub(/0{1,6}$/, '')
			wall_z = sprintf('%.6f', wall_position.z.to_mm).sub(/0{1,6}$/, '')
			# direction Point3d object
			wall_rotation = group_transformation.xaxis
			wall_r_x = sprintf('%.6f', wall_rotation.x).sub(/0{1,6}$/, '')
			wall_r_y = sprintf('%.6f', wall_rotation.y).sub(/0{1,6}$/, '')
			wall_r_z = sprintf('%.6f', wall_rotation.z).sub(/0{1,6}$/, '')
			
			ents=wall.entities.to_a
			faces=ents.find_all{|e|e.class==Sketchup::Face}
			#areas = faces.find_all{|e|e.class==Sketchup::Face}
			area_verts = Array.new
			faces.each { |face|
				if face.attribute_dictionary "ifc"
					construct = face.get_attribute "ifc", "ifc_construct"
					if construct == "IfcArea"
						area_verts = face.vertices
					end
				end
			}
		
			# wall properties
			wall_width = sprintf('%.6f', su_width.to_f).sub(/0{1,6}$/, '')#hoort hier de conversion bij de wall of export functie???
			wall_length = sprintf('%.6f', su_length.to_f.to_mm).sub(/0{1,6}$/, '')
			wall_height = sprintf('%.6f', su_height.to_f).sub(/0{1,6}$/, '')
			grossSideArea = sprintf('%.6f', su_height.to_f * wall_length.to_f / 1000000).sub(/0{1,6}$/, '') # "11.500" opp zijkant
			netSideArea = sprintf('%.6f', (su_height.to_f * wall_length.to_f / 1000000 / 1.1).to_f).sub(/0{1,6}$/, '') # "10.450" #opp zijkant - 10%?
			grossVolume = sprintf('%.6f', (su_height.to_f * wall_length.to_f * wall_width.to_f / 1000000000).to_f).sub(/0{1,6}$/, '') # "3.450" volume. Should be height * surface(not width/length).
			netVolume = sprintf('%.6f', (su_height.to_f * wall_length.to_f * wall_width.to_f / 1000000000 / 1.1).to_f).sub(/0{1,6}$/, '') # "3.135" #volume - 10%?
			grossFootprintArea = sprintf('%.6f', (wall_length.to_f * wall_width.to_f / 1000000).to_f).sub(/0{1,6}$/, '') # "1.500" Should be surface(not width*length).
			shaperepresentationX1 = "0." # "150."
			shaperepresentationX2 = "0." # "150."
			shaperepresentationY1 = "0."
			shaperepresentationY2 = wall_length
			
			# follow up id numbers
			id_00 = (@ifc_id+=1).to_s
			id_01 = (@ifc_id+=1).to_s
			id_02 = (@ifc_id+=1).to_s
			id_03 = (@ifc_id+=1).to_s
			id_04 = (@ifc_id+=1).to_s
			id_05 = (@ifc_id+=1).to_s
			id_06 = (@ifc_id+=1).to_s
			id_07 = (@ifc_id+=1).to_s
			id_08 = (@ifc_id+=1).to_s
			id_09 = (@ifc_id+=1).to_s
			id_10 = (@ifc_id+=1).to_s
			id_11 = (@ifc_id+=1).to_s
			id_12 = (@ifc_id+=1).to_s
			id_13 = (@ifc_id+=1).to_s
			id_14 = (@ifc_id+=1).to_s
			id_15 = (@ifc_id+=1).to_s
			id_16 = (@ifc_id+=1).to_s
			id_17 = (@ifc_id+=1).to_s
			id_18 = (@ifc_id+=1).to_s
			id_19 = (@ifc_id+=1).to_s
			id_20 = (@ifc_id+=1).to_s
			id_21 = (@ifc_id+=1).to_s
			id_22 = (@ifc_id+=1).to_s
			id_23 = (@ifc_id+=1).to_s
			id_24 = (@ifc_id+=1).to_s
			id_25 = (@ifc_id+=1).to_s
			id_26 = (@ifc_id+=1).to_s
			id_27 = (@ifc_id+=1).to_s
			id_28 = (@ifc_id+=1).to_s
			id_29 = (@ifc_id+=1).to_s
			id_30 = (@ifc_id+=1).to_s
			id_31 = (@ifc_id+=1).to_s
			id_32 = (@ifc_id+=1).to_s
			id_33 = (@ifc_id+=1).to_s
			id_34 = (@ifc_id+=1).to_s
			id_35 = (@ifc_id+=1).to_s
			id_36 = (@ifc_id+=1).to_s
			id_37 = (@ifc_id+=1).to_s
			id_38 = (@ifc_id+=1).to_s
			id_39 = (@ifc_id+=1).to_s
			id_40 = (@ifc_id+=1).to_s
			id_41 = (@ifc_id+=1).to_s
			
			polyline = "#" + id_41 + " = IFCPOLYLINE(("
			vertex_array = Array.new
			
			area_verts << area_verts[0]
			
			area_verts.each { |vert|
				vertex_position = vert.position
				vert_x = sprintf('%.6f', vertex_position.x.to_mm).sub(/0{1,6}$/, '')
				vert_y = sprintf('%.6f', vertex_position.y.to_mm).sub(/0{1,6}$/, '')
				id_vert = (@ifc_id+=1).to_s
				polyline = polyline + "#" + id_vert + ","
				vertex_array << "#" + id_vert + " = IFCCARTESIANPOINT((" + vert_x + ", " + vert_y + "));"
			}
			polyline.chop! #remove trailing comma
			polyline = polyline + "));" 
			
			id_47 = (@ifc_id+=1).to_s
			id_48 = (@ifc_id+=1).to_s
			id_49 = (@ifc_id+=1).to_s
			id_50 = (@ifc_id+=1).to_s
			id_51 = (@ifc_id+=1).to_s
			id_52 = (@ifc_id+=1).to_s
			id_53 = (@ifc_id+=1).to_s
			id_54 = (@ifc_id+=1).to_s
			
			#@export_content << "#" + id_0x + " = IFCRELCONTAINEDINSPATIALSTRUCTURE('" + random_string + "', #2, '" + buildingstoreycontainer_name + "', '" + buildingstoreycontainer_description + "', (#" + id_00 + "), #35);"

			#add wall to list of walls in building storey
			@buildingstoreywalls = @buildingstoreywalls + "#" + id_00 + ","
			@export_content << "#" + id_00 + " = IFCWALLSTANDARDCASE('" + random_string + "', #2, 'Wall " + id_00 + "', 'Description of Wall " + id_00 + "', $, #" + id_01 + ", #" + id_06 + ", $);"
			@export_content << "#" + id_01 + " = IFCLOCALPLACEMENT(#36, #" + id_02 + ");"
			@export_content << "#" + id_02 + " = IFCAXIS2PLACEMENT3D(#" + id_03 + ", #" + id_04 + ", #" + id_05 + ");"
			@export_content << "#" + id_03 + " = IFCCARTESIANPOINT((" + wall_x + ", " + wall_y + ", " + wall_z + "));"
			@export_content << "#" + id_04 + " = IFCDIRECTION((0., 0., 1.));"
			@export_content << "#" + id_05 + " = IFCDIRECTION((" + wall_r_x + ", " + wall_r_y + ", " + wall_r_z + "));"
			@export_content << "#" + id_06 + " = IFCPRODUCTDEFINITIONSHAPE($, $, (#" + id_34 + ", #" + id_38 + ", #" + id_52 + "));"
			@export_content << "#" + id_07 + " = IFCPROPERTYSET('" + random_string + "', #2, 'Pset_WallCommon', $, (#" + id_08 + ", #" + id_09 + ", #" + id_10 + ", #" + id_11 + ", #" + id_12 + ", #" + id_13 + ", #" + id_14 + ", #" + id_15 + ", #" + id_16 + ", #" + id_17 + "));"
			@export_content << "#" + id_08 + " = IFCPROPERTYSINGLEVALUE('Reference', 'Reference', IFCTEXT(''), $);"
			@export_content << "#" + id_09 + " = IFCPROPERTYSINGLEVALUE('AcousticRating', 'AcousticRating', IFCTEXT(''), $);"
			@export_content << "#" + id_10 + " = IFCPROPERTYSINGLEVALUE('FireRating', 'FireRating', IFCTEXT(''), $);"
			@export_content << "#" + id_11 + " = IFCPROPERTYSINGLEVALUE('Combustible', 'Combustible', IFCBOOLEAN(.F.), $);"
			@export_content << "#" + id_12 + " = IFCPROPERTYSINGLEVALUE('SurfaceSpreadOfFlame', 'SurfaceSpreadOfFlame', IFCTEXT(''), $);"
			@export_content << "#" + id_13 + " = IFCPROPERTYSINGLEVALUE('ThermalTransmittance', 'ThermalTransmittance', IFCREAL(2.400E-1), $);"
			@export_content << "#" + id_14 + " = IFCPROPERTYSINGLEVALUE('IsExternal', 'IsExternal', IFCBOOLEAN(.T.), $);"
			@export_content << "#" + id_15 + " = IFCPROPERTYSINGLEVALUE('ExtendToStructure', 'ExtendToStructure', IFCBOOLEAN(.F.), $);"
			@export_content << "#" + id_16 + " = IFCPROPERTYSINGLEVALUE('LoadBearing', 'LoadBearing', IFCBOOLEAN(.F.), $);"
			@export_content << "#" + id_17 + " = IFCPROPERTYSINGLEVALUE('Compartmentation', 'Compartmentation', IFCBOOLEAN(.F.), $);"
			@export_content << "#" + id_18 + " = IFCRELDEFINESBYPROPERTIES('" + random_string + "', #2, $, $, (#" + id_00 + "), #" + id_07 + ");"
			@export_content << "#" + id_19 + " = IFCELEMENTQUANTITY('" + random_string + "', #2, 'BaseQuantities', $, $, (#" + id_20 + ", #" + id_21 + ", #" + id_22 + ", #" + id_23 + ", #" + id_24 + ", #" + id_25 + ", #" + id_26 + ", #" + id_27 + "));"
			@export_content << "#" + id_20 + " = IFCQUANTITYLENGTH('Width', 'Width', $, " + wall_width + ");"
			@export_content << "#" + id_21 + " = IFCQUANTITYLENGTH('Lenght', 'Lenght', $, " + wall_length + ");"
			@export_content << "#" + id_22 + " = IFCQUANTITYAREA('GrossSideArea', 'GrossSideArea', $, " + grossSideArea + ");"
			@export_content << "#" + id_23 + " = IFCQUANTITYAREA('NetSideArea', 'NetSideArea', $, " + netSideArea + ");"
			@export_content << "#" + id_24 + " = IFCQUANTITYVOLUME('GrossVolume', 'GrossVolume', $, " + grossVolume + ");"
			@export_content << "#" + id_25 + " = IFCQUANTITYVOLUME('NetVolume', 'NetVolume', $, " + netVolume + ");"
			@export_content << "#" + id_26 + " = IFCQUANTITYLENGTH('Height', 'Height', $, " + wall_height + ");"
			@export_content << "#" + id_27 + " = IFCQUANTITYAREA('GrossFootprintArea', 'GrossFootprintArea', $, " + grossFootprintArea + ");"
			@export_content << "#" + id_28 + " = IFCRELDEFINESBYPROPERTIES('" + random_string + "', #2, $, $, (#" + id_00 + "), #" + id_19 + ");"
			@export_content << "#" + id_29 + " = IFCRELASSOCIATESMATERIAL('" + random_string + "', #2, $, $, (#" + id_00 + "), #" + id_30 + ");"
			@export_content << "#" + id_30 + " = IFCMATERIALLAYERSETUSAGE(#" + id_31 + ", .AXIS2., .POSITIVE., -150.);"
			@export_content << "#" + id_31 + " = IFCMATERIALLAYERSET((#" + id_32 + "), $);"
			@export_content << "#" + id_32 + " = IFCMATERIALLAYER(#" + id_33 + ", 300., $);"
			@export_content << "#" + id_33 + " = IFCMATERIAL('" + wall_material + "');"
			@export_content << "#" + id_34 + " = IFCSHAPEREPRESENTATION(#20, 'Axis', 'Curve2D', (#" + id_35 + "));"
			@export_content << "#" + id_35 + " = IFCPOLYLINE((#" + id_36 + ", #" + id_37 + "));"
			@export_content << "#" + id_36 + " = IFCCARTESIANPOINT((" + shaperepresentationY1 + ", " + shaperepresentationX1 + "));"
			@export_content << "#" + id_37 + " = IFCCARTESIANPOINT((" + shaperepresentationY2 + ", " + shaperepresentationX2 + "));"
			@export_content << "#" + id_38 + " = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#" + id_39 + "));"
			@export_content << "#" + id_39 + " = IFCEXTRUDEDAREASOLID(#" + id_40 + ", #" + id_47 + ", #" + id_51 + ", " + wall_height + ");"
			@export_content << "#" + id_40 + " = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, #" + id_41 + ");"
			
			

			
			#@export_content << "#" + id_41 + " = IFCPOLYLINE((#" + id_42 + ", #" + id_43 + ", #" + id_44 + ", #" + id_45 + ", #" + id_46 + "));"
			@export_content << polyline
			vertex_array.each { |vert_s|
				@export_content << vert_s
			}
			
			#@export_content << "#" + id_42 + " = IFCCARTESIANPOINT((0., 0.));"
			#@export_content << "#" + id_43 + " = IFCCARTESIANPOINT((0., " + wall_width + "));"
			#@export_content << "#" + id_44 + " = IFCCARTESIANPOINT((" + wall_length + ", " + wall_width + "));"
			#@export_content << "#" + id_45 + " = IFCCARTESIANPOINT((" + wall_length + ", 0.));"
			#@export_content << "#" + id_46 + " = IFCCARTESIANPOINT((0., 0.));"
			
			@export_content << "#" + id_47 + " = IFCAXIS2PLACEMENT3D(#" + id_48 + ", #" + id_49 + ", #" + id_50 + ");"
			@export_content << "#" + id_48 + " = IFCCARTESIANPOINT((0., 0., 0.));"
			@export_content << "#" + id_49 + " = IFCDIRECTION((0., 0., 1.));"
			@export_content << "#" + id_50 + " = IFCDIRECTION((1., 0., 0.));"
			@export_content << "#" + id_51 + " = IFCDIRECTION((0., 0., 1.));"
			@export_content << "#" + id_52 + " = IFCSHAPEREPRESENTATION(#20, 'Box', 'BoundingBox', (#" + id_53 + "));"
			@export_content << "#" + id_53 + " = IFCBOUNDINGBOX(#" + id_54 + ", " + wall_length + ", " + wall_width + ", " + wall_height + ");"
			@export_content << "#" + id_54 + " = IFCCARTESIANPOINT((0., 0., 0.));"
		}

		@export_content << "ENDSEC;"
		@export_content << "END-ISO-10303-21;"
		
		
		@buildingstoreywalls.chop! #remove trailing comma
		@export_content[record_buildingstorey] = @buildingstoreywalls + "), #35);"

#		export_file = @model.path.sub(".skp", ".ifc")
		File.open(@ifc_filepath, 'w') {|f|	@export_content.each{|l|		f.write(l + "\n")	}}
	end

end#class IFCexporter #####################################################
###

### make shortcut to tool #################################################
def ifcexporter()
  Sketchup.active_model.select_tool(IFCexporter.new())
end
###

### add menu item etc #####################################################
if not file_loaded?(File.basename(__FILE__))
	UI.menu("PlugIns").add_item("IFCexporter..."){IFCexporter.new()}
end#if
file_loaded(File.basename(__FILE__))
###
