def guid()#function returns a new IFC object ID - function has to be updated to use official Globally Unique Identifier - http://buildingsmart-tech.org/implementation/get-started/ifc-guid
  length=22
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  string = ''
  length.times { string << chars[rand(chars.size)] }
  return string
end

class IfcObject #to be subclassed by all ifc classes, contains basic methods
  def id_s(increment)
    index = @index + increment
    return "#" + index.to_s
  end
end

class IfcRelContainedInSpatialStructure < IfcObject #collection of all elements in a storey
	def initialize(index, building_storey)
    @index = index # current highest ifc id number, no string!
    @contained_elements = Array.new
    @building_storey = building_storey
  end
  def add_element(element_index)
    @contained_elements << "#" + element_index.to_s
  end
  def get_ifc()
		buildingstoreycontainer_id = guid
		buildingstoreycontainer_name = "Default Building"
		buildingstoreycontainer_description = "Contents of Building Storey"
    
    ifc_record = id_s(1) + " = IFCRELCONTAINEDINSPATIALSTRUCTURE('" + buildingstoreycontainer_id + "', #2, '" + buildingstoreycontainer_name + "', '" + buildingstoreycontainer_description + "', ("
    length = @contained_elements.length
    i = 0
    until i == length -1
      ifc_record = ifc_record + @contained_elements[i] + ", "
      i += 1
    end
    ifc_record = ifc_record + @contained_elements[length -1] + "), " + @building_storey + ");"
    array = Array.new
    array << ifc_record
    return array
  end
end

class IfcProject < IfcObject #ifc project object
	def initialize(index)#ifc_index, bt_opening, ifc_owner_history, ifc_local_placement, ifc_wall_standard_case, ifc_geometric_representation_context)
    @index = index # current highest ifc id number, no string!
    @building_storey = 0
    #@bt_opening = bt_opening
    #@ifc_owner_history = ifc_owner_history #2
    #@ifc_local_placement = ifc_local_placement #46, Can be aquired from geometry?
    #@ifc_wall_standard_case = ifc_wall_standard_case #Can be aquired from geometry?
    #@ifc_geometric_representation_context = ifc_geometric_representation_context #Can be aquired from geometry?
  end
  def building_storey
    return @building_storey
  end
  def get_ifc() # returns an array with the ifc records describing the opening object
    model = Sketchup.active_model
    
    # IFC info, needs to be editable from sketchup
		author = model.get_attribute "ifc", "author", "Architect"
		organization = model.get_attribute "ifc", "organization", "Building Designer Office"
		preprocessor_version = "SU2IFC01"
		originating_system = "SU2IFC01"
		authorization = model.get_attribute "ifc", "authorization", "The authorising person"
		project_id = model.get_attribute "ifc", "project_id", guid
		project_name = model.get_attribute "ifc", "project_name", "Default Project"
		project_description = model.get_attribute "ifc", "project_description", "Description of Default Project"
		owner_creation_date = "1296506003"
		person_id = model.get_attribute "ifc", "person_id", "ID001"
		person_familyname = model.get_attribute "ifc", "person_familyname", "Lastname"
		person_givenname = model.get_attribute "ifc", "person_givenname", "Firstname"
		organisation_name = model.get_attribute "ifc", "organisation_name", "Company"
		organisation_description = model.get_attribute "ifc", "organisation_description", "Company description"
		application_version = "0.01"
		application_name = "SU2IFC"
		application_identifier = "SU2IFC01"
		site_id = model.get_attribute "ifc", "site_id", guid
		site_name = model.get_attribute "ifc", "site_name", "Default Site"
		site_description = model.get_attribute "ifc", "site_description", "Description of Default Site"
		building_id = model.get_attribute "ifc", "building_id", guid
		building_name = model.get_attribute "ifc", "building_name", "Default Building"
		building_description = model.get_attribute "ifc", "building_description", "Description of Default Building"
		buildingstorey_id = guid
		buildingstorey_name = "Default Building Storey"
		buildingstorey_description = "Description of Default Building Storey"
		buildingcontainer_id = model.get_attribute "ifc", "buildingcontainer_id", guid
		buildingcontainer_name = model.get_attribute "ifc", "buildingcontainer_name", "BuildingContainer"
		buildingcontainer_description = model.get_attribute "ifc", "buildingcontainer_description", "BuildingContainer for BuildingStories"
		sitecontainer_id = model.get_attribute "ifc", "sitecontainer_id", guid
		sitecontainer_name = model.get_attribute "ifc", "sitecontainer_name", "SiteContainer"
		sitecontainer_description = model.get_attribute "ifc", "sitecontainer_description", "SiteContainer For Buildings"
		projectcontainer_id = model.get_attribute "ifc", "projectcontainer_id", guid
		projectcontainer_name = model.get_attribute "ifc", "projectcontainer_name", "ProjectContainer"
		projectcontainer_description = model.get_attribute "ifc", "projectcontainer_description", "ProjectContainer for Sites"
		buildingstoreycontainer_id = guid
		buildingstoreycontainer_name = "Default Building"
		buildingstoreycontainer_description = "Contents of Building Storey"
    
    # get project location
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
    
    array = Array.new
    array << id_s(1)  + " = IFCPROJECT('" + project_id + "', " + id_s(2) + ", '" + project_name + "', '" + project_description + "', $, $, $, (" + id_s(20) + "), " + id_s(7) + ");"
    array << id_s(2)  + " = IFCOWNERHISTORY(" + id_s(3) + ", " + id_s(6) + ", $, .ADDED., $, $, $, " + owner_creation_date + ");"
    array << id_s(3)  + " = IFCPERSONANDORGANIZATION(" + id_s(4) + ", " + id_s(5) + ", $);"
    array << id_s(4)  + " = IFCPERSON('" + person_id + "', '" + person_familyname + "', '" + person_givenname + "', $, $, $, $, $);"
    array << id_s(5)  + " = IFCORGANIZATION($, '" + organisation_name + "', '" + organisation_description + "', $, $);"
    array << id_s(6)  + " = IFCAPPLICATION(" + id_s(5) + ", '" + application_version + "', '" + application_name + "', '" + application_identifier + "');"
    array << id_s(7)  + " = IFCUNITASSIGNMENT((" + id_s(8) + ", " + id_s(9) + ", " + id_s(10) + ", " + id_s(11) + ", " + id_s(15) + ", " + id_s(16) + ", " + id_s(17) + ", " + id_s(18) + ", " + id_s(19) + "));"
    array << id_s(8)  + " = IFCSIUNIT(*, .LENGTHUNIT., .MILLI., .METRE.);"
    array << id_s(9)  + " = IFCSIUNIT(*, .AREAUNIT., $, .SQUARE_METRE.);"
    array << id_s(10)  + " = IFCSIUNIT(*, .VOLUMEUNIT., $, .CUBIC_METRE.);"
    array << id_s(11) + " = IFCCONVERSIONBASEDUNIT(" + id_s(12) + ", .PLANEANGLEUNIT., 'DEGREE', " + id_s(13) + ");"
    array << id_s(12) + " = IFCDIMENSIONALEXPONENTS(0, 0, 0, 0, 0, 0, 0);"
    array << id_s(13) + " = IFCMEASUREWITHUNIT(IFCPLANEANGLEMEASURE(1.745E-2), " + id_s(14) + ");"
    array << id_s(14) + " = IFCSIUNIT(*, .PLANEANGLEUNIT., $, .RADIAN.);"
    array << id_s(15) + " = IFCSIUNIT(*, .SOLIDANGLEUNIT., $, .STERADIAN.);"
    array << id_s(16) + " = IFCSIUNIT(*, .MASSUNIT., $, .GRAM.);"
    array << id_s(17) + " = IFCSIUNIT(*, .TIMEUNIT., $, .SECOND.);"
    array << id_s(18) + " = IFCSIUNIT(*, .THERMODYNAMICTEMPERATUREUNIT., $, .DEGREE_CELSIUS.);"
    array << id_s(19) + " = IFCSIUNIT(*, .LUMINOUSINTENSITYUNIT., $, .LUMEN.);"
    array << id_s(20) + " = IFCGEOMETRICREPRESENTATIONCONTEXT($, 'Model', 3, 1.000E-5, " + id_s(21) + ", $);"
    array << id_s(21) + " = IFCAXIS2PLACEMENT3D(" + id_s(22) + ", $, $);"
    array << id_s(22) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    array << id_s(23) + " = IFCSITE('" + site_id + "', " + id_s(2) + ", '" + site_name + "', '" + site_description + "', $, " + id_s(24) + ", $, $, .ELEMENT., (" + lat[0] + ", " + lat[1] + ", " + lat[2] + "), (" + long[0] + ", " + long[1] + ", " + long[2] + "), $, $, $);"
    array << id_s(24) + " = IFCLOCALPLACEMENT($, " + id_s(25) + ");"
    array << id_s(25) + " = IFCAXIS2PLACEMENT3D(" + id_s(26) + ", " + id_s(27) + ", " + id_s(28) + ");"
    array << id_s(26) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    array << id_s(27) + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(28) + " = IFCDIRECTION((1., 0., 0.));"
    array << id_s(29) + " = IFCBUILDING('" + building_id + "', " + id_s(2) + ", '" + building_name + "', '" + building_description + "', $, " + id_s(30) + ", $, $, .ELEMENT., $, $, $);"
    array << id_s(30) + " = IFCLOCALPLACEMENT(" + id_s(24) + ", " + id_s(31) + ");"
    array << id_s(31) + " = IFCAXIS2PLACEMENT3D(" + id_s(32) + ", " + id_s(33) + ", " + id_s(34) + ");"
    array << id_s(32) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    array << id_s(33) + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(34) + " = IFCDIRECTION((1., 0., 0.));"
    array << id_s(35) + " = IFCBUILDINGSTOREY('" + buildingstorey_id + "', " + id_s(2) + ", '" + buildingstorey_name + "', '" + buildingstorey_description + "', $, " + id_s(36) + ", $, $, .ELEMENT., 0.);"
    @building_storey = id_s(35)
    array << id_s(36) + " = IFCLOCALPLACEMENT(" + id_s(30) + ", " + id_s(37) + ");"
    array << id_s(37) + " = IFCAXIS2PLACEMENT3D(" + id_s(38) + ", " + id_s(39) + ", " + id_s(40) + ");"
    array << id_s(38) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    array << id_s(39) + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(40) + " = IFCDIRECTION((1., 0., 0.));"
    array << id_s(41) + " = IFCRELAGGREGATES('" + buildingcontainer_id + "', " + id_s(2) + ", '" + buildingcontainer_name + "', '" + buildingcontainer_description + "', " + id_s(29) + ", (" + id_s(35) + "));"
    array << id_s(42) + " = IFCRELAGGREGATES('" + sitecontainer_id + "', " + id_s(2) + ", '" + sitecontainer_name + "', '" + sitecontainer_description + "', " + id_s(23) + ", (" + id_s(29) + "));"
    array << id_s(43) + " = IFCRELAGGREGATES('" + projectcontainer_id + "', " + id_s(2) + ", '" + projectcontainer_name + "', '" + projectcontainer_description + "', " + id_s(1) + ", (" + id_s(23) + "));"
    return array
  end # get_ifc
end # IfcProject

class IfcWallStandardCase < IfcObject #ifc standard wall object
	def initialize(index, wall)#ifc_index, bt_opening, ifc_owner_history, ifc_local_placement, ifc_wall_standard_case, ifc_geometric_representation_context)
    @index = index # current highest ifc id number, no string!
    @wall = wall # the bim-tools wall object
    @wall_index = index + 1
    @wall_index
    @wall_id
  end
  def index
    return @wall_index
  end
  def get_ifc() # returns an array with the ifc records describing the wall object
    if @wall.material == nil
      wall_material = "Default material"
    else
      wall_material = @wall.material.name
    end
    width = @wall.width
    length = @wall.length
    height = @wall.height
    # determine the wall element´s position and direction
    group_transformation = @wall.transformation
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
    
    ents=@wall.geometry.entities.to_a
    faces=ents.find_all{|e|e.class==Sketchup::Face}
    area_verts = Array.new
    faces.each { |face|
      if face.attribute_dictionary "ifc"
        construct = face.get_attribute "ifc", "ifc_construct"
        if construct == "IfcArea"
          area_verts = face.vertices
        end
      end
    }
    v = 0
    area_verts << area_verts[0]
    v_tot = area_verts.length
  
    # wall properties
    wall_width = sprintf('%.6f', width.to_f).sub(/0{1,6}$/, '')#hoort hier de conversion bij de wall of export functie???
    wall_offset = sprintf('%.6f', (width.to_f/2*-1)).sub(/0{1,6}$/, '')
    wall_length = sprintf('%.6f', length.to_f.to_mm).sub(/0{1,6}$/, '')
    wall_height = sprintf('%.6f', height.to_f).sub(/0{1,6}$/, '')
    grossSideArea = sprintf('%.6f', height.to_f * wall_length.to_f / 1000000).sub(/0{1,6}$/, '') # Area of the wall as viewed by an elevation view of the middle plane of the wall.  It does not take into account any wall modifications (such as openings).
    netSideArea = sprintf('%.6f', height.to_f * wall_length.to_f / 1000000).sub(/0{1,6}$/, '') # Area of the wall as viewed by an elevation view of the middle plane. It does take into account all wall modifications (such as openings).
    grossVolume = sprintf('%.6f', height.to_f * wall_length.to_f * wall_width.to_f / 1000000000).sub(/0{1,6}$/, '') # Should be height * surface(not width/length). Volume of the wall, without taking into account the openings and the connection geometry.
    netVolume = sprintf('%.6f', height.to_f * wall_length.to_f * wall_width.to_f / 1000000000).sub(/0{1,6}$/, '') # (include endcaps) Volume of the wall, after subtracting the openings and after considering the connection geometry.
    grossFootprintArea = sprintf('%.6f', (wall_length.to_f * wall_width.to_f / 1000000).to_f).sub(/0{1,6}$/, '') # (include endcaps) Area of the wall as viewed by a ground floor view, not taking any wall modifications (like recesses) into account. It is also referred to as the foot print of the wall.
    # netFootprintArea = sprintf('%.6f', (wall_length.to_f * wall_width.to_f / 1000000).to_f).sub(/0{1,6}$/, '') # (include endcaps) Area of the wall as viewed by a ground floor view, taking all wall modifications (like recesses) into account. It is also referred to as the foot print of the wall.
    shaperepresentationX1 = "0." # "150."
    shaperepresentationX2 = "0." # "150."
    shaperepresentationY1 = "0."
    shaperepresentationY2 = wall_length

    # IFC specific

    array = Array.new
    array << id_s(1)  + " = IFCWALLSTANDARDCASE('" + guid + "', #2, 'Wall " + id_s(1) + "', 'Description of Wall " + id_s(1) + "', $, " + id_s(2) + ", " + id_s(7) + ", $);"
    array << id_s(2)  + " = IFCLOCALPLACEMENT(#36, " + id_s(3) + ");"
    array << id_s(3)  + " = IFCAXIS2PLACEMENT3D(" + id_s(4) + ", " + id_s(5) + ", " + id_s(6) + ");"
    array << id_s(4)  + " = IFCCARTESIANPOINT((" + wall_x + ", " + wall_y + ", " + wall_z + "));"
    array << id_s(5)  + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(6)  + " = IFCDIRECTION((" + wall_r_x + ", " + wall_r_y + ", " + wall_r_z + "));"
    array << id_s(7)  + " = IFCPRODUCTDEFINITIONSHAPE($, $, (" + id_s(35) + ", " + id_s(39) + ", " + id_s(48 + v_tot) + "));"
    array << id_s(8)  + " = IFCPROPERTYSET('" + guid + "', #2, 'Pset_WallCommon', $, (" + id_s(9) + ", " + id_s(10) + ", " + id_s(11) + ", " + id_s(12) + ", " + id_s(13) + ", " + id_s(14) + ", " + id_s(15) + ", " + id_s(16) + ", " + id_s(17) + ", " + id_s(18) + "));"
    array << id_s(9)  + " = IFCPROPERTYSINGLEVALUE('Reference', 'Reference', IFCTEXT(''), $);"
    array << id_s(10) + " = IFCPROPERTYSINGLEVALUE('AcousticRating', 'AcousticRating', IFCTEXT(''), $);"
    array << id_s(11) + " = IFCPROPERTYSINGLEVALUE('FireRating', 'FireRating', IFCTEXT(''), $);"
    array << id_s(12) + " = IFCPROPERTYSINGLEVALUE('Combustible', 'Combustible', IFCBOOLEAN(.F.), $);"
    array << id_s(13) + " = IFCPROPERTYSINGLEVALUE('SurfaceSpreadOfFlame', 'SurfaceSpreadOfFlame', IFCTEXT(''), $);"
    array << id_s(14) + " = IFCPROPERTYSINGLEVALUE('ThermalTransmittance', 'ThermalTransmittance', IFCREAL(2.400E-1), $);"
    array << id_s(15) + " = IFCPROPERTYSINGLEVALUE('IsExternal', 'IsExternal', IFCBOOLEAN(.T.), $);"
    array << id_s(16) + " = IFCPROPERTYSINGLEVALUE('ExtendToStructure', 'ExtendToStructure', IFCBOOLEAN(.F.), $);"
    array << id_s(17) + " = IFCPROPERTYSINGLEVALUE('LoadBearing', 'LoadBearing', IFCBOOLEAN(.F.), $);"
    array << id_s(18) + " = IFCPROPERTYSINGLEVALUE('Compartmentation', 'Compartmentation', IFCBOOLEAN(.F.), $);"
    array << id_s(19) + " = IFCRELDEFINESBYPROPERTIES('" + guid + "', #2, $, $, (" + id_s(1) + "), " + id_s(8) + ");"
    array << id_s(20) + " = IFCELEMENTQUANTITY('" + guid + "', #2, 'BaseQuantities', $, $, (" + id_s(21) + ", " + id_s(22) + ", " + id_s(23) + ", " + id_s(24) + ", " + id_s(25) + ", " + id_s(26) + ", " + id_s(27) + ", " + id_s(28) + "));"
    array << id_s(21) + " = IFCQUANTITYLENGTH('Width', 'Width', $, " + wall_width + ");"
    array << id_s(22) + " = IFCQUANTITYLENGTH('Lenght', 'Lenght', $, " + wall_length + ");"
    array << id_s(23) + " = IFCQUANTITYAREA('GrossSideArea', 'GrossSideArea', $, " + grossSideArea + ");"
    array << id_s(24) + " = IFCQUANTITYAREA('NetSideArea', 'NetSideArea', $, " + netSideArea + ");"
    array << id_s(25) + " = IFCQUANTITYVOLUME('GrossVolume', 'GrossVolume', $, " + grossVolume + ");"
    array << id_s(26) + " = IFCQUANTITYVOLUME('NetVolume', 'NetVolume', $, " + netVolume + ");"
    array << id_s(27) + " = IFCQUANTITYLENGTH('Height', 'Height', $, " + wall_height + ");"
    array << id_s(28) + " = IFCQUANTITYAREA('GrossFootprintArea', 'GrossFootprintArea', $, " + grossFootprintArea + ");"
    array << id_s(29) + " = IFCRELDEFINESBYPROPERTIES('" + guid + "', #2, $, $, (" + id_s(1) + "), " + id_s(20) + ");"
    array << id_s(30) + " = IFCRELASSOCIATESMATERIAL('" + guid + "', #2, $, $, (" + id_s(1) + "), " + id_s(31) + ");"
    array << id_s(31) + " = IFCMATERIALLAYERSETUSAGE(" + id_s(32) + ", .AXIS2., .POSITIVE., " + wall_offset + ");"
    array << id_s(32) + " = IFCMATERIALLAYERSET((" + id_s(33) + "), $);"
    array << id_s(33) + " = IFCMATERIALLAYER(" + id_s(34) + ", " + wall_width + ", $);"
    array << id_s(34) + " = IFCMATERIAL('" + wall_material + "');"
    array << id_s(35) + " = IFCSHAPEREPRESENTATION(#20, 'Axis', 'Curve2D', (" + id_s(36) + "));"
    array << id_s(36) + " = IFCPOLYLINE((" + id_s(37) + ", " + id_s(38) + "));"
    array << id_s(37) + " = IFCCARTESIANPOINT((" + shaperepresentationY1 + ", " + shaperepresentationX1 + "));"
    array << id_s(38) + " = IFCCARTESIANPOINT((" + shaperepresentationY2 + ", " + shaperepresentationX2 + "));"
    array << id_s(39) + " = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (" + id_s(40) + "));"
    array << id_s(40) + " = IFCEXTRUDEDAREASOLID(" + id_s(41) + ", " + id_s(48) + ", " + id_s(47 + v_tot) + ", " + wall_height + ");"
    array << id_s(41) + " = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, " + id_s(42) + ");"

    polyline = id_s(42) + " = IFCPOLYLINE(("
    vertex_array = Array.new
    
    area_verts.each { |vert|
      v+=1
      vertex_position = vert.position
      vert_x = sprintf('%.6f', vertex_position.x.to_mm).sub(/0{1,6}$/, '')
      vert_y = sprintf('%.6f', vertex_position.y.to_mm).sub(/0{1,6}$/, '')
      #id_vert = (@ifc_id+=1).to_s
      polyline = polyline + id_s(42 + v) + ","
      vertex_array << id_s(42 + v) + " = IFCCARTESIANPOINT((" + vert_x + ", " + vert_y + "));"
    }
    polyline.chop! #remove trailing comma
    polyline = polyline + "));" 

    array << polyline
    vertex_array.each { |vert_s|
      array << vert_s
    }
    
    array << id_s(43 + v_tot) + " = IFCAXIS2PLACEMENT3D(" + id_s(44 + v) + ", " + id_s(45 + v) + ", " + id_s(46 + v) + ");"
    array << id_s(44 + v_tot) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    array << id_s(45 + v_tot) + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(46 + v_tot) + " = IFCDIRECTION((1., 0., 0.));"
    array << id_s(47 + v_tot) + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(48 + v_tot) + " = IFCSHAPEREPRESENTATION(#20, 'Box', 'BoundingBox', (" + id_s(49 + v) + "));"
    array << id_s(49 + v_tot) + " = IFCBOUNDINGBOX(" + id_s(50 + v) + ", " + wall_length + ", " + wall_width + ", " + wall_height + ");"
    array << id_s(50 + v_tot) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    return array
  end # get_ifc
end # IfcWallStandardCase

class IfcOpeningElement < IfcObject #ifc opening object
	def initialize(index, building_element)#ifc_index, bt_opening, ifc_owner_history, ifc_local_placement, ifc_wall_standard_case, ifc_geometric_representation_context)
    @index = index # current highest ifc id number, no string!
    @building_element = building_element
    @voiding_element = @building_element.voids_element
    voiding_element_index = @voiding_element.ifc_get_id
    @ifc_voiding_element = "#" + (voiding_element_index).to_s
    @voiding_element_placement = "#" + (voiding_element_index + 1).to_s
    

    #@bt_opening = bt_opening
    #@ifc_owner_history = ifc_owner_history #2
    #@ifc_local_placement = ifc_local_placement #46, Can be aquired from geometry?
    #@ifc_wall_standard_case = ifc_wall_standard_case #Can be aquired from geometry?
    #@ifc_geometric_representation_context = ifc_geometric_representation_context #Can be aquired from geometry?
  end

  def get_ifc() # returns an array with the ifc records describing the opening object
  
    require 'bim-tools/cut_opening.rb'
    @opening = CuttingFace.new(@building_element.geometry, @voiding_element.geometry)
    #list all faces
    faces = Array.new
    @opening.geometry.entities.each do |entity|
      if entity.typename == "Face"
        faces << entity
      end
    end
    bounding_box = @opening.geometry.bounds
    opening_position = bounding_box.min#temporary solution, not correct insertionpoint
    
    invert = opening_position.y * -1
    
    @opening_position_x = sprintf('%.6f', opening_position.x.to_mm).sub(/0{1,6}$/, '')
    @opening_position_y = sprintf('%.6f', invert.to_mm).sub(/0{1,6}$/, '')
    @opening_position_z = sprintf('%.6f', opening_position.z.to_mm).sub(/0{1,6}$/, '')
    
    thickness = opening_position.y * -2#temporary wall thickness
    
    @bounding_box_depth = sprintf('%.6f', bounding_box.depth.to_mm).sub(/0{1,6}$/, '')
    @bounding_box_height = sprintf('%.6f', thickness.to_mm).sub(/0{1,6}$/, '')
    @bounding_box_width = sprintf('%.6f', bounding_box.width.to_mm).sub(/0{1,6}$/, '')
    
    
    ents=@opening.geometry.entities.to_a
    faces=ents.find_all{|e|e.class==Sketchup::Face}
    area_verts = Array.new
    #faces.each { |face|
    #  if face.attribute_dictionary "ifc"
    #    construct = face.get_attribute "ifc", "ifc_construct"
    #    if construct == "IfcArea"
    #      area_verts = face.vertices
    #    end
    #  end
    #}
    area_verts = faces[0].vertices
    v = 0
    area_verts << area_verts[0]
    v_tot = area_verts.length
    
    
    array = Array.new
    array << id_s(1)  + " = IFCOPENINGELEMENT('2LcE70iQb51PEZynawyvuT', #2, 'Opening Element xyz', 'Description of Opening', $, " + id_s(2) + ", " + id_s(7) + ", $);"
    array << id_s(2)  + " = IFCLOCALPLACEMENT(" + @voiding_element_placement + ", " + id_s(3) + ");"
    array << id_s(3)  + " = IFCAXIS2PLACEMENT3D(" + id_s(4) + ", " + id_s(5) + ", " + id_s(6) + ");"
    array << id_s(4)  + " = IFCCARTESIANPOINT((" + @opening_position_x + ", " + @opening_position_y + ", " + @opening_position_z + "));"
    array << id_s(5)  + " = IFCDIRECTION((0., -1., 0.));"
    array << id_s(6)  + " = IFCDIRECTION((1., 0., 0.));"
    array << id_s(7)  + " = IFCPRODUCTDEFINITIONSHAPE($, $, (" + id_s(14) + "));"
    array << id_s(8)  + " = IFCELEMENTQUANTITY('2yDPSWYWf319fWaWWvPxwA', #2, 'BaseQuantities', $, $, (" + id_s(9) + ", " + id_s(10) + ", " + id_s(11) + "));"
    array << id_s(9)  + " = IFCQUANTITYLENGTH('Depth', 'Depth', $, " + @bounding_box_depth + ");"
    array << id_s(10) + " = IFCQUANTITYLENGTH('Height', 'Height', $, " + @bounding_box_height + ");"
    array << id_s(11) + " = IFCQUANTITYLENGTH('Width', 'Width', $, " + @bounding_box_width + ");"
    array << id_s(12) + " = IFCRELDEFINESBYPROPERTIES('2UEO1blXL9sPmb1AMeW7Ax', #2, $, $, (" + id_s(1) + "), " + id_s(8) + ");"
    array << id_s(13) + " = IFCRELVOIDSELEMENT('3lR5koIT51Kwudkm5eIoTu', #2, $, $, " + @ifc_voiding_element + ", " + id_s(1) + ");"
    array << id_s(14) + " = IFCSHAPEREPRESENTATION(#20, 'Body', 'SweptSolid', (" + id_s(15) + "));"
    array << id_s(15) + " = IFCEXTRUDEDAREASOLID(" + id_s(16) + ", " + id_s(18 + v_tot) + ", " + id_s(22 + v_tot) + ", " + @bounding_box_height + ");"
    array << id_s(16) + " = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, " + id_s(17) + ");"
    
   # array << id_s(17 + v_tot) + " = IFCPOLYLINE((" + id_s(18) + ", " + id_s(19) + ", " + id_s(20) + ", " + id_s(21) + ", " + id_s(18) + "));"



    
    polyline = id_s(17) + " = IFCPOLYLINE(("
    vertex_array = Array.new
    
    area_verts.each { |vert|
      v+=1
      vertex_position = vert.position - opening_position
      vert_x = sprintf('%.6f', vertex_position.x.to_mm).sub(/0{1,6}$/, '')
      vert_z = sprintf('%.6f', vertex_position.z.to_mm).sub(/0{1,6}$/, '')
      #id_vert = (@ifc_id+=1).to_s
      polyline = polyline + id_s(17 + v) + ","
      vertex_array << id_s(17 + v) + " = IFCCARTESIANPOINT((" + vert_x + ", " + vert_z + "));"
    }
      polyline = polyline + id_s(17 + 1)
    
    #polyline.chop! #remove trailing comma
    polyline = polyline + "));" 

    array << polyline
    vertex_array.each { |vert_s|
      array << vert_s
    }

    
    array << id_s(18 + v_tot) + " = IFCAXIS2PLACEMENT3D(" + id_s(19 + v_tot) + ", " + id_s(20 + v_tot) + ", " + id_s(21 + v_tot) + ");"
    array << id_s(19 + v_tot) + " = IFCCARTESIANPOINT((0., 0., 0.));"
    array << id_s(20 + v_tot) + " = IFCDIRECTION((0., 0., 1.));"
    array << id_s(21 + v_tot) + " = IFCDIRECTION((1., 0., 0.));"
    array << id_s(22 + v_tot) + " = IFCDIRECTION((0., 0., 1.));"
    
    @opening.geometry.erase!
    
    return array
  end # get_ifc
end # IfcOpeningElement

class IfcHeader < IfcObject #ifc file header object
	def initialize(export_base_file)
    model = Sketchup.active_model
    @index = 0 # current highest ifc id number, no string! Start with header, value = 0
    @export_base_file = export_base_file
    time = Time.new
		@timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
    @author = model.get_attribute "ifc", "author", "Architect"
		@organization = model.get_attribute "ifc", "organization", "Building Designer Office"
		@preprocessor_version = "SU2IFC020"
		@originating_system = "SU2IFC020"
		@authorization = model.get_attribute "ifc", "authorization", "The authorising person"
    
  end
  def get_ifc() # returns an array with the ifc records describing the file header
    array = Array.new
		array << "ISO-10303-21;"
		array << "HEADER;"
		array << "FILE_DESCRIPTION (('ViewDefinition [CoordinationView, QuantityTakeOffAddOnView]'), '2;1');"
		array << "FILE_NAME ('" + @export_base_file + "', '" + @timestamp + "', ('" + @author + "'), ('" + @organization + "'), '" + @preprocessor_version + "', '" + @originating_system + "', '" + @authorization + "');"
		array << "FILE_SCHEMA (('IFC2X3'));"
		array << "ENDSEC;"
		array << "DATA;"
    return array
  end # get_ifc
end # IfcHeader

class IfcFooter < IfcObject #ifc file footer object
  def get_ifc() # returns an array with the ifc records describing the file footer
    array = Array.new
		array << "ENDSEC;"
		array << "END-ISO-10303-21;"
    return array
  end # get_ifc
end # IfcFooter
