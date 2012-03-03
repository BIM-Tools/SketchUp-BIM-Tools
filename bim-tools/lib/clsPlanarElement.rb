#       clsPlanarElement.rb
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

require 'bim-tools/lib/clsBuildingElement.rb'

# building element subtype “planar” class
# Object "parallel" to sketchup "face" object
class ClsPlanarElement < ClsBuildingElement
  def initialize(project, face, width=nil, offset=nil) # profilecomponent=width, offset
    @project = project
    @source = face
    @source_hidden = false # for function in ClsBuildingElement
    @geometry = nil
    @aPlanesHor = nil
    @element_type = nil
    @name = ""
    @description = ""
    if width == nil
      @width = 300.mm
    else
      @width = width
    end
    if offset == nil
      @offset = 150.mm
    else
      @offset = offset
    end
    init_type
    add_to_lib
    set_guid
    set_attributes
    set_planes
    
    # deze observer houdt het basisvlak in de gaten, mocht deze wijzigen dan wijzigt ook de geometrie.
    #observer = SourceObserver.new
    #observer.set_planar(self)
    #@source.add_observer(observer)
  end
  
  # create the geometry for the planar element
  def set_geometry
    entities = Sketchup.active_model.active_entities
    if @geometry != nil
      group = @geometry
      group.entities.clear!
    else
      group = entities.add_group
      @geometry = group
    end
    origin = @source.vertices[0].position
    zaxis = @source.normal
    t_base_plane = Geom::Transformation.new(origin, zaxis)
    group.transformation = t_base_plane
    
    aPlanesVert = Array.new
    
    # let op! als 2 vlakken gelijk zijn kan geen snijlijn worden uitgerekend!
    
    #bepaal de zij-planes door de cross-product te berekenen van de 2 vectoren(normal basisplane en vector edge) en 1 punt (edge.start) op te geven.
    normal = @source.normal # 1e vector
    
    # zoek de verticale plane voor alle edges
    @source.outer_loop.edges.each do |edge|
      line = edge.line # line bestaat uit een array van 1 punt en 1 vector
      point = line[0] # punt op lijn
      line_vector = line[1] # 2e vector
      
      # bepaal hoeveel aansluitende vlakken(bt-elementen) er zijn
      a_connecting_faces = Array.new#Array met alle aansluitende vlakken
      connected = edge.faces
      connected.each do |con_ent|
        if con_ent != @source # als het vlak niet het basisvlak zelf is
          @project.library.entities.each do |ent| # loop door de library heen # LET OP DAT DIT KAN STOPPEN ALS HET GEVONDEN IS!!!
            if con_ent == ent.source # als het vlak voorkomt in de bt-library
              a_connecting_faces << con_ent # voeg het vlak toe aan het array
            end
          end
        end
      end
      
      # bekijk of het vlak verticaal moet zijn of moet aansluiten op naastliggende geometrie
      if a_connecting_faces.length == 1
        # if source and connecting faces are parallel, then also create vertical end.
        if @source.normal == a_connecting_faces[0].normal
          plane_vector = normal.cross line_vector # unit vector voor plane
          plane = [point, plane_vector]
        else
          #vector1 = a_connecting_faces[0].normal + @source.normal # tel de normal-vectoren van de aansluitende vlakken bij elkaar op, dit geeft een vector met de helft van de hoek.
          #vector2 = line_vector
          #plane_vector = vector1.cross line_vector
          ## alternatieve methode die rekening houdt met de dikte van de planar:
          a_connecting_faces[0]
          connecting_entity = find_bt_entity_for_face(a_connecting_faces[0])
          bottom_line = Geom.intersect_plane_plane(self.planes[0], connecting_entity.planes[0])
          top_line = Geom.intersect_plane_plane(self.planes[1], connecting_entity.planes[1])
          ## line = [point3d, vector3d]
          point1 = bottom_line[0]
          point2 = bottom_line[0] + bottom_line[1]
          point3 = top_line[0]
          plane = Geom.fit_plane_to_points point1, point2, point3
        end
      else
        # verticaal vlak
        plane_vector = normal.cross line_vector # unit vector voor plane
        plane = [point, plane_vector]
      end
      aPlanesVert << plane# voeg toe aan array met verticale planes
    end
    
    # collect the needed points for the top and bottom faces in an array
    aFacePtsTop = Array.new
    aFacePtsBottom = Array.new
    
    # create side faces on every base-face edge
    i = 0
    j = aPlanesVert.length
    while i < j do
      plane = aPlanesVert[i]
      if i == 0
        plane1 = aPlanesVert[j-1]
      else
        plane1 = aPlanesVert[i-1]
      end
      # if both planes are parallel then there is no intersection between planes
      line_start = Geom.intersect_plane_plane(plane1, plane)
      
      if i == j - 1
        plane2 = aPlanesVert[0]
      else
        plane2 = aPlanesVert[i+1]
      end
      # if both planes are parallel then there is no intersection between planes
      line_end = Geom.intersect_plane_plane(plane2, plane)
      
      pts = []
      pts[0] = Geom.intersect_line_plane(line_start, self.planes[0])
      pts[1] = Geom.intersect_line_plane(line_start, self.planes[1])
      pts[2] = Geom.intersect_line_plane(line_end, self.planes[1])
      pts[3] = Geom.intersect_line_plane(line_end, self.planes[0])
      
      aFacePtsTop << pts[0]
      aFacePtsBottom << pts[1]
      
      face = group.entities.add_face pts
      i += 1
    end
    
    # create the top and bottom faces
    face_top = group.entities.add_face aFacePtsTop
    face_bottom = group.entities.add_face aFacePtsBottom

    # move group entities back in position with the inverse transformation
    a_entities = Array.new
    group.entities.each do |entity| # pas de transformatie toe op de volledige inhoud van de group, dit kan beter vooraf gedaan worden...
      a_entities << entity
    end
    group.entities.transform_entities(t_base_plane.invert!, a_entities) # misschien kan beter transform_by_vectors gebruikt worden?
    
    # reset bounding box
    group.entities.parent.invalidate_bounds
    
    # set the group as the planar´s geometry
    #@geometry = group
    
    # check if source or geometry must be hidden
    if @project.visible_geometry? == true
      @source.hidden=true
    else
      @geometry.hidden=true
    end
  end
  
  def possible_types
    return Array["Wall", "Floor", "Roof"]
  end
  
  def width
    return @width
  end
  def width=(width)
    @width = width.mm
    set_planes
  end
  def update_geometry
    set_planes
    set_geometry
  end
  def offset
    return @offset
  end
  def offset=(offset)
    @offset = offset.mm
    set_planes #???
  end
  
  # Array needed to find intersections with planes of connecting elements
  def planes
    return @aPlanesHor
  end
  
  # hiermee worden de outer planes bepaald
  def set_planes
  
    # definieer het basisvlak voor het te maken element
    base_plane = @source.plane
    
    # maak het top-vlak, door het originele array te kopieeren en bij de offset(laatste waarde) de nieuwe afstand op te tellen.
    # Plane is een array van 4 waarden, waarvan de eerste 3 de unit-vector van het vlak beschrijven, en de laatste de loodrechte afstand van het vlak tot de oorsprong.
    top_plane = [base_plane[0], base_plane[1], base_plane[2], base_plane[3] + @width - @offset]
    bottom_plane = [base_plane[0], base_plane[1], base_plane[2], base_plane[3] - @offset]
    
    # Array needed to find intersections with planes of connecting elements
    @aPlanesHor = Array.new
    @aPlanesHor << bottom_plane
    @aPlanesHor << top_plane    
  end
  
  # met deze functie kun je een hash ophalen met alle informatieve eigenschappen
  def properties_fixed
    h_Properties = Hash.new
    if @geometry.volume > 0
      h_Properties["volume"] = (@geometry.volume* (25.4 **3)).round.to_s + " Millimeters ³"
    end
    h_Properties["guid"] = guid?
    return h_Properties
  end
  
  # met deze functie kun je een hash ophalen met alle eigenschappen die rechtstreeks te wijzigen zijn
  def properties_editable
  
    a_types = Array.new
    a_types << @element_type
    possible_types.each do |type|
      if type != @element_type
        a_types << type
      end
    end
        
    a_layers = Array.new
    a_layers << @geometry.layer.name
    Sketchup.active_model.layers.each do |layer|
      if layer != @geometry.layer
        a_layers << layer.name
      end
    end
  
    h_Properties = Hash.new
    h_Properties["width"] = @width
    h_Properties["offset"] = @offset
    h_Properties["element_type"] = a_types
    # h_Properties["layer"] = a_layers
    h_Properties["name"] = @name
    h_Properties["description"] = @description
    return h_Properties
  end
  
  def properties=(h_Properties)
    @width = h_Properties["width"].to_f.mm
    @offset = h_Properties["offset"].to_f.mm
    @element_type = h_Properties["element_type"]
    @name = h_Properties["name"]
    @description = h_Properties["description"]
    set_planes
    #update_geometry
  end
  
  # the element_type based on the initial source state
  def init_type
    if source.normal.z == 0
      @element_type = "Wall"
    elsif source.normal.z == 1
      @element_type = "Floor"
    elsif source.normal.z == -1
      @element_type = "Floor"
    else
      @element_type = "Roof"
    end
  end
end
