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

# Add a menu item to launch IFC Export.
UI.menu("PlugIns").add_item("IFC Export") {
  ifc_export
}

def ifc_export
  require 'config.rb'
	model = Sketchup.active_model
	entities = model.entities
	
	# IFC info
	author = "Architect"
	organization = "Building Designer Office"
	preprocessor_version = "IFC Engine DLL version 1.02 beta"
	originating_system = "IFC Engine DLL version 1.02 beta"
	authorization = "The authorising person"
	project_id = "323HSLe65A8OTgoXnDKFTH"
	project_name = "Default Project"
	project_description = "Description of Default Project"
	owner_creation_date = "1296506003"
	person_id = "ID001"
	person_familyname = "Lastname"
	person_givenname = "Firstname"
	organisation_name = "Company"
	organisation_description = "Company description"
	application_version = "0.01"
	application_name = "SU2IFC"
	application_identifier = "SU2IFC01"
	site_id = "0_hjT3_8LAJOAPex5YzrsC"
	site_name = "Default Site"
	site_description = "Description of Default Site"
	building_id = "10jmdmX3D6nRXKBBpoXMPg"
	building_name = "Default Building"
	building_description = "Description of Default Building"
	buildingstorey_id = "0fRfAWMHL6kf5TfXc$zQbd"
	buildingstorey_name = "Default Building Storey"
	buildingstorey_description = "Description of Default Building Storey"
	buildingcontainer_id = "2EjwlPjdTEtevFQ9BU3VKh"
	buildingcontainer_name = "BuildingContainer"
	buildingcontainer_description = "BuildingContainer for BuildingStories"
	sitecontainer_id = "2WySMg$698IRj8WC$sXFPq"
	sitecontainer_name = "SiteContainer"
	sitecontainer_description = "SiteContainer For Buildings"
	projectcontainer_id = "3UPJfRAZT0DPAj$z7CELR7"
	projectcontainer_name = "ProjectContainer"
	projectcontainer_description = "ProjectContainer for Sites"
	buildingstoreycontainer_id = "1rbxDpBW97wgpAzlgD9hpf"
	buildingstoreycontainer_name = "Default Building"
	buildingstoreycontainer_description = "Contents of Building Storey"
	

	export_base_file = File.basename(model.path, ".skp") + ".ifcxml"
	time = Time.new
  timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
  
  local_coordinates = [0,0,0]
	local_point = Geom::Point3d.new(local_coordinates)
	ll = model.point_to_latlong(local_point)
	lat = sprintf("%.4f", ll[0])
	long = sprintf("%.4f", ll[1])
	lat = lat.split('.')
	long = long.split('.')
	latpart = lat[1].split(//)
	longpart = long[1].split(//)
	lat = [lat[0], latpart[0] + latpart[1], latpart[2] + latpart[3]]
	long = [long[0], longpart[0] + longpart[1], longpart[2] + longpart[3]]
	
	export_content = Array.new

	export_content << "ISO-10303-21;"
	export_content << "HEADER;"
	export_content << "FILE_DESCRIPTION (('ViewDefinition [CoordinationView, QuantityTakeOffAddOnView]'), '2;1');"
	export_content << "FILE_NAME ('" + export_base_file + "', '" + timestamp + "', ('" + author + "'), ('" + organization + "'), '" + preprocessor_version + "', '" + originating_system + "', '" + authorization + "');"
	export_content << "FILE_SCHEMA (('IFC2X3'));"
	export_content << "ENDSEC;"
	export_content << "DATA;"
	export_content << "#1 = IFCPROJECT('" + project_id + "', #2, '" + project_name + "', '" + project_description + "', $, $, $, (#20), #7);"
	export_content << "#2 = IFCOWNERHISTORY(#3, #6, $, .ADDED., $, $, $, " + owner_creation_date + ");"
	export_content << "#3 = IFCPERSONANDORGANIZATION(#4, #5, $);"
	export_content << "#4 = IFCPERSON('" + person_id + "', '" + person_familyname + "', '" + person_givenname + "', $, $, $, $, $);"
	export_content << "#5 = IFCORGANIZATION($, '" + Company + "', '" + organisation_description + "', $, $);"
	export_content << "#6 = IFCAPPLICATION(#5, '" + application_version + "', '" + application_name + "', '" + application_identifier + "');"
	export_content << "#7 = IFCUNITASSIGNMENT((#8, #9, #10, #11, #15, #16, #17, #18, #19));"
	export_content << "#8 = IFCSIUNIT(*, .LENGTHUNIT., .MILLI., .METRE.);"
	export_content << "#9 = IFCSIUNIT(*, .AREAUNIT., $, .SQUARE_METRE.);"
	export_content << "#10 = IFCSIUNIT(*, .VOLUMEUNIT., $, .CUBIC_METRE.);"
	export_content << "#11 = IFCCONVERSIONBASEDUNIT(#12, .PLANEANGLEUNIT., 'DEGREE', #13);"
	export_content << "#12 = IFCDIMENSIONALEXPONENTS(0, 0, 0, 0, 0, 0, 0);"
	export_content << "#13 = IFCMEASUREWITHUNIT(IFCPLANEANGLEMEASURE(1.745E-2), #14);"
	export_content << "#14 = IFCSIUNIT(*, .PLANEANGLEUNIT., $, .RADIAN.);"
	export_content << "#15 = IFCSIUNIT(*, .SOLIDANGLEUNIT., $, .STERADIAN.);"
	export_content << "#16 = IFCSIUNIT(*, .MASSUNIT., $, .GRAM.);"
	export_content << "#17 = IFCSIUNIT(*, .TIMEUNIT., $, .SECOND.);"
	export_content << "#18 = IFCSIUNIT(*, .THERMODYNAMICTEMPERATUREUNIT., $, .DEGREE_CELSIUS.);"
	export_content << "#19 = IFCSIUNIT(*, .LUMINOUSINTENSITYUNIT., $, .LUMEN.);"
	export_content << "#20 = IFCGEOMETRICREPRESENTATIONCONTEXT($, 'Model', 3, 1.000E-5, #21, $);"
	export_content << "#21 = IFCAXIS2PLACEMENT3D(#22, $, $);"
	export_content << "#22 = IFCCARTESIANPOINT((0., 0., 0.));"
	export_content << "#23 = IFCSITE('" + site_id + "', #2, '" + site_name + "', '" + site_description + "', $, #24, $, $, .ELEMENT., (" + lat[0] + ", " + lat[1] + ", " + lat[2] + "), (" + long[0] + ", " + long[1] + ", " + long[2] + "), $, $, $);"
	export_content << "#24 = IFCLOCALPLACEMENT($, #25);"
	export_content << "#25 = IFCAXIS2PLACEMENT3D(#26, #27, #28);"
	export_content << "#26 = IFCCARTESIANPOINT((0., 0., 0.));"
	export_content << "#27 = IFCDIRECTION((0., 0., 1.));"
	export_content << "#28 = IFCDIRECTION((1., 0., 0.));"
	export_content << "#29 = IFCBUILDING('" + building_id + "', #2, '" + building_name + "', '" + building_description + "', $, #30, $, $, .ELEMENT., $, $, $);"
	export_content << "#30 = IFCLOCALPLACEMENT(#24, #31);"
	export_content << "#31 = IFCAXIS2PLACEMENT3D(#32, #33, #34);"
	export_content << "#32 = IFCCARTESIANPOINT((0., 0., 0.));"
	export_content << "#33 = IFCDIRECTION((0., 0., 1.));"
	export_content << "#34 = IFCDIRECTION((1., 0., 0.));"
	export_content << "#35 = IFCBUILDINGSTOREY('" + buildingstorey_id + "', #2, '" + buildingstorey_name + "', '" + buildingstorey_description + "', $, #36, $, $, .ELEMENT., 0.);"
	export_content << "#36 = IFCLOCALPLACEMENT(#30, #37);"
	export_content << "#37 = IFCAXIS2PLACEMENT3D(#38, #39, #40);"
	export_content << "#38 = IFCCARTESIANPOINT((0., 0., 0.));"
	export_content << "#39 = IFCDIRECTION((0., 0., 1.));"
	export_content << "#40 = IFCDIRECTION((1., 0., 0.));"
	export_content << "#41 = IFCRELAGGREGATES('" + buildingcontainer_id + "', #2, '" + buildingcontainer_name + "', '" + buildingcontainer_description + "', #29, (#35));"
	export_content << "#42 = IFCRELAGGREGATES('" + sitecontainer_id + "', #2, '" + sitecontainer_name + "', '" + sitecontainer_description + "', #23, (#29));"
	export_content << "#43 = IFCRELAGGREGATES('" + projectcontainer_id + "', #2, '" + projectcontainer_name + "', '" + projectcontainer_description + "', #1, (#23));"
	export_content << "#44 = IFCRELCONTAINEDINSPATIALSTRUCTURE('" + buildingstoreycontainer_id + "', #2, '" + buildingstoreycontainer_name + "', '" + buildingstoreycontainer_description + "', (#45), #35);"

	# loop function for creating walls

#45 = IFCWALLSTANDARDCASE('1fKSg0wsb6VeGex0lbKRP8', #2, 'Wall xyz', 'Description of Wall', $, #46, #51, $);
#46 = IFCLOCALPLACEMENT(#36, #47);
#47 = IFCAXIS2PLACEMENT3D(#48, #49, #50);
#48 = IFCCARTESIANPOINT((0., 0., 0.));
#49 = IFCDIRECTION((0., 0., 1.));
#50 = IFCDIRECTION((1., 0., 0.));
#51 = IFCPRODUCTDEFINITIONSHAPE($, $, (#79, #83, #97));
#52 = IFCPROPERTYSET('3G1DCww4j6PgKOXgpCn8By', #2, 'Pset_WallCommon', $, (#53, #54, #55, #56, #57, #58, #59, #60, #61, #62));
#53 = IFCPROPERTYSINGLEVALUE('Reference', 'Reference', IFCTEXT(''), $);
#54 = IFCPROPERTYSINGLEVALUE('AcousticRating', 'AcousticRating', IFCTEXT(''), $);
#55 = IFCPROPERTYSINGLEVALUE('FireRating', 'FireRating', IFCTEXT(''), $);
#56 = IFCPROPERTYSINGLEVALUE('Combustible', 'Combustible', IFCBOOLEAN(.F.), $);
#57 = IFCPROPERTYSINGLEVALUE('SurfaceSpreadOfFlame', 'SurfaceSpreadOfFlame', IFCTEXT(''), $);
#58 = IFCPROPERTYSINGLEVALUE('ThermalTransmittance', 'ThermalTransmittance', IFCREAL(2.400E-1), $);
#59 = IFCPROPERTYSINGLEVALUE('IsExternal', 'IsExternal', IFCBOOLEAN(.T.), $);
#60 = IFCPROPERTYSINGLEVALUE('ExtendToStructure', 'ExtendToStructure', IFCBOOLEAN(.F.), $);
#61 = IFCPROPERTYSINGLEVALUE('LoadBearing', 'LoadBearing', IFCBOOLEAN(.F.), $);
#62 = IFCPROPERTYSINGLEVALUE('Compartmentation', 'Compartmentation', IFCBOOLEAN(.F.), $);
#63 = IFCRELDEFINESBYPROPERTIES('0K3Qn1hzTA$xBh2tc0vKJ_', #2, $, $, (#45), #52);
#64 = IFCELEMENTQUANTITY('2hxcPvzqzFzuEId3jRY7wf', #2, 'BaseQuantities', $, $, (#65, #66, #67, #68, #69, #70, #71, #72));
#65 = IFCQUANTITYLENGTH('Width', 'Width', $, 300.);
#66 = IFCQUANTITYLENGTH('Lenght', 'Lenght', $, 5000.);
#67 = IFCQUANTITYAREA('GrossSideArea', 'GrossSideArea', $, 11.500);
#68 = IFCQUANTITYAREA('NetSideArea', 'NetSideArea', $, 10.450);
#69 = IFCQUANTITYVOLUME('GrossVolume', 'GrossVolume', $, 3.450);
#70 = IFCQUANTITYVOLUME('NetVolume', 'NetVolume', $, 3.135);
#71 = IFCQUANTITYLENGTH('Height', 'Height', $, 2300.);
#72 = IFCQUANTITYAREA('GrossFootprintArea', 'GrossFootprintArea', $, 1.500);
#73 = IFCRELDEFINESBYPROPERTIES('2sQ$TYJPjEIuF4z7KYQiFj', #2, $, $, (#45), #64);
#74 = IFCRELASSOCIATESMATERIAL('02wZZT1efCtwhA7TfskeoM', #2, $, $, (#45), #75);
#75 = IFCMATERIALLAYERSETUSAGE(#76, .AXIS2., .POSITIVE., -150.);
#76 = IFCMATERIALLAYERSET((#77), $);
#77 = IFCMATERIALLAYER(#78, 300., $);
#78 = IFCMATERIAL('Name of the material used for the wall');
#79 = IFCSHAPEREPRESENTATION(#20, 'Axis', 'Curve2D', (#80));
#80 = IFCPOLYLINE((#81, #82));
#81 = IFCCARTESIANPOINT((0., 150.));
#82 = IFCCARTESIANPOINT((5000., 150.));
#83 = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (#84));
#84 = IFCEXTRUDEDAREASOLID(#85, #92, #96, 2300.);
#85 = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, #86);
#86 = IFCPOLYLINE((#87, #88, #89, #90, #91));
#87 = IFCCARTESIANPOINT((0., 0.));
#88 = IFCCARTESIANPOINT((0., 300.));
#89 = IFCCARTESIANPOINT((5000., 300.));
#90 = IFCCARTESIANPOINT((5000., 0.));
#91 = IFCCARTESIANPOINT((0., 0.));
#92 = IFCAXIS2PLACEMENT3D(#93, #94, #95);
#93 = IFCCARTESIANPOINT((0., 0., 0.));
#94 = IFCDIRECTION((0., 0., 1.));
#95 = IFCDIRECTION((1., 0., 0.));
#96 = IFCDIRECTION((0., 0., 1.));
#97 = IFCSHAPEREPRESENTATION(#20, 'Box', 'BoundingBox', (#98));
#98 = IFCBOUNDINGBOX(#99, 5000., 300., 2300.);
#99 = IFCCARTESIANPOINT((0., 0., 0.));
	"ENDSEC;"
	"END-ISO-10303-21;"

	export_file = model.path.sub(".skp", ".ifcxml")
	File.open(export_file, 'w') {|f|	export_content.each{|l|		f.write(l + "\n")	}}
end
