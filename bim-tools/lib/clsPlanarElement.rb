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
    @source_hidden = @project.visible_geometry? # for function in ClsBuildingElement
    @geometry = nil
    @aPlanesHor = nil
    @element_type = nil
    @name = ""
    @description = ""
    @guid = ""
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
    
    #a_set_geometry = Array[self]
    # updates geometry connecting bt_entities(how to exclude double updating itself?)
    #@project.bt_entities_set_geometry(a_set_geometry)
    
    # deze observer houdt het basisvlak in de gaten, mocht deze wijzigen dan wijzigt ook de geometrie.
    #observer = SourceObserver.new
    #observer.set_planar(self)
    #@source.add_observer(observer)
  end
  
  # create the geometry for the planar element
  def set_geometry
    entities = Sketchup.active_model.active_entities
    if @geometry.nil?
      #if @geometry.deleted?
        group = entities.add_group
        @geometry = group
      #else
      #  group = @geometry
      #  group.entities.clear!
      #end
    else
      if @geometry.deleted?
        group = entities.add_group
        @geometry = group
      else
        group = @geometry
        
        # gets fired furtheron in the script, just before drawing so temporary group also gets deleted
        group.entities.clear!
      end
    end
    origin = @source.vertices[0].position
    zaxis = @source.normal
    t_base_plane = Geom::Transformation.new(origin, zaxis)
    group.transformation = t_base_plane
    
    # array that holds the vertical-planes-array for every loop
    aLoopsVertPlanes = Array.new
    nOuterLoopNum = 0
    nLoopCount = 0
    
    cutting_loops = get_cutting_loops[0]
    temp_group = get_cutting_loops[1]
    
    loops = @source.loops + get_cutting_loops[0]
    
    loops.each do |loop|
      
      # keep the loops array-index of the outer loop
      if loop == @source.outer_loop
        nOuterLoopNum == nLoopCount
      end
      
      nLoopCount += 1
      
      aPlanesVert = Array.new
      
      # let op! als 2 vlakken gelijk zijn kan geen snijlijn worden uitgerekend!
      
      #bepaal de zij-planes door de cross-product te berekenen van de 2 vectoren(normal basisplane en vector edge) en 1 punt (edge.start) op te geven.
      normal = @source.normal # 1e vector
      
      
      prev_edge = loop.edges.last
      
      # zoek de verticale plane voor alle edges
      loop.edges.each do |edge|# @source.outer_loop.edges.each do |edge|
        line = edge.line # line bestaat uit een array van 1 punt en 1 vector
        point = line[0] # punt op lijn
        line_vector = line[1] # 2e vector
        
        # determine the number of connecting bt-source-faces
        a_connecting_faces = Array.new # Array to hold al connecting faces
        connected = edge.faces
        connected.each do |con_ent|
        
          # check only if this face is not the base-face
          if con_ent != @source
          
            # add only bt-source-faces to array, bt-entities must not react to "normal" faces
            unless @project.library.source_to_bt_entity(@project, con_ent).nil?
              a_connecting_faces << con_ent
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
        
        #bekijk of de 
        if edge.line[1].parallel? prev_edge.line[1] # what if the vectors are on the same line but facing each other?
          perp_plane = [prev_edge.start.position, prev_edge.line[1]]
          aPlanesVert << perp_plane
        end
        prev_edge = edge
        
        aPlanesVert << plane# voeg toe aan array met verticale planes
      end
      aLoopsVertPlanes << aPlanesVert
    end
    
    nLoopCount = 0
    
    # array will hold all temporary top and bottom faces(that is all exept that of the outer loop)
    aTempFaces = Array.new
    
    
    #placed here so temporary group also gets deleted
    group.entities.clear!
    
    aLoopsVertPlanes.each do |aPlanesVert|
      
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
        
        
        
        
        
        
        # bug fix:
        # bepaal endpoint van 1 van de edges op het snijvlak.
        # bepaal het vlak door dit punt, haaks op de edge
        # gebruik dit vlak om de snijpunten te berekenen
        
        
        
        
        
        
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
        
        #if nOuterLoopNum == nLoopCount
        unless aFacePtsTop.last == pts[0]
          aFacePtsTop << pts[0]
        end
        unless aFacePtsBottom.last == pts[1]
          aFacePtsBottom << pts[1]
        end
        #end
        
        #pts.uniq!
        #door het extra tussen gevoegde vlak ontstaan dubbele punten?
        #puts pts
        
        # when a face has duplicate points it cannot be created, temporary solution: skip face
        begin
          face = group.entities.add_face pts
        rescue
          puts "error: failed to create face"
        end
        
        i += 1
      end
      
      # create the top and bottom faces
      face_top = group.entities.add_face aFacePtsTop
      face_bottom = group.entities.add_face aFacePtsBottom
      
      # remove all temporary top and bottom faces
      unless nOuterLoopNum == nLoopCount
        face_top.erase!
        face_bottom.erase!
      end
      nLoopCount += 1
    end

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
    
    # save all properties as attributes in the group
    set_attributes
  end
  
  # create array of loop objects for face-cutting instances
  def get_cutting_loops
  
    # start only if get_glued_instances is not nil???????
    
    aLoops = Array.new
    group = @geometry.entities.add_group
    
    @source.get_glued_instances.each do |instance|
    
      transform =  group.transformation.invert! * instance.transformation
    
      # copy all edges that are on the x-y plane to the new group
      instance.definition.entities.each do |entity|
        if entity.typename == "Edge"
          if entity.start.position.z == 0
            if entity.end.position.z == 0
              new_start = entity.start.position.transform transform
              new_end = entity.end.position.transform transform
              group.entities.add_edges new_start, new_end
            end
          end
        end
      end
    
    end
    
    # intersect all edges
    faces=[]
    group.entities.each do |entity|
      faces << entity
    end
    group.entities.intersect_with false, group.transformation, group.entities, group.transformation, true, faces
    
    # create all possible faces
    group.entities.each do |entity|
      if entity.typename == "Edge"
        entity.find_faces
      end
    end
    
    # delete unneccesary edges
    group.entities.each do |entity|
      if entity.typename == "Edge"
        if entity.faces.length != 1
          entity.erase!
        end
      end
    end
    
    #find all outer loops
    group.entities.each do |entity|
      if entity.typename == "Face"
        aLoops << entity.outer_loop
      end
    end
    
    return Array[aLoops, group]
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
  def geometry=(geometry)
    @geometry = geometry
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
  
    if @source.deleted?
      self_destruct
    else
    
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
    
    if @geometry.deleted?
      set_geometry
    end
    
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
  
  #same as previous, but without mm conversion
  def set_properties(h_Properties)
    @width = h_Properties["width"]
    @offset = h_Properties["offset"]
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
  # write planar attributes to geometry object
  def set_attributes
    unless @geometry.nil?
      @geometry.set_attribute "ifc", "guid", guid?
      @geometry.set_attribute "ifc", "type", element_type?
      @geometry.set_attribute "ifc", "offset", @offset.to_s #needs to be in planarelement class
      @geometry.set_attribute "ifc", "width", @width.to_s #needs to be in planarelement class
      @geometry.set_attribute "ifc", "description", description?.to_s
      @geometry.set_attribute "ifc", "name", name?.to_s
    end
    unless @source.nil?
      @source.set_attribute "ifc", "guid", guid?
    end
  end
end
