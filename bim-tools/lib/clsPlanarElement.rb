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

module Brewsky::BimTools

  require 'bim-tools/lib/clsBuildingElement.rb'
  
  # building element subtype “planar” class
  # Object "parallel" to sketchup "face" object
  class ClsPlanarElement < ClsBuildingElement
    attr_reader :element_type, :openings
    def initialize(project, face, width=nil, offset=nil, guid=nil) # profilecomponent=width, offset
      @project = project
      @source = face
      @deleted = false
      @source_hidden = @project.visible_geometry? # for function in ClsBuildingElement
      @geometry
      @aPlanesHor
      
      # Array that holds sub-arrays containing the point3d-objects from all opening-loops
      @openings = Array.new
      @element_type
      @name
      @description
      @guid = guid
      @length
      @height
      if width.nil?
        @width = 300.mm
      else
        @width = width
      end
      if offset.nil?
        @offset = 150.mm
      else
        @offset = offset
      end
    
      init_type
      add_to_lib
      if @guid.nil?
        set_guid
      end
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
      self.check_source
      # do not update geometry when the planar element is in the process of beeing deleted(marked for deletion)
      if @deleted == false
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
        
        #find origin
        
        tmp_origin = @source.vertices[0].position
        zaxis = @source.normal
        t_base_plane = Geom::Transformation.new(tmp_origin, zaxis)
        
        ti = t_base_plane.inverse
         
        a_Vertices = Array.new
        a_Vectors = Array.new
        x = nil
        y = nil
        z = nil
        
        @source.vertices.each do |vertex|
          po = vertex.position
          pn = Geom::Point3d.new(po.x, po.y, po.z)
          
          pn.transform! ti
          
          #find lowest value for x, y and z
          if x.nil?
            x = pn.x
          else
            if pn.x < x
              x = pn.x
            end
          end
          if y.nil?
            y = pn.y
          else
            if pn.y < y
              y = pn.y
            end
          end
          if z.nil?
            z = pn.z
          else
            if pn.z < z
              z = pn.z
            end
          end
        end
        
        point = Geom::Point3d.new(x, y, z)
  
        translation = Geom::Transformation.new point
        
        #origin.transform! t_base_plane
        
        t_base_plane = t_base_plane * translation
        
        group.transformation = t_base_plane
        
        # array that holds the vertical-planes-array for every loop
        aLoopsVertPlanes = Array.new
        nOuterLoopNum = 0
        nLoopCount = 0
        
        loops = get_openings[0]
        #temporary group "get_openings[1]" gets deleted in line 243
        
        #add the outer loop on position 0
        loops.insert(0, @source.outer_loop)# << @source.outer_loop
        nOuterLoopNum == 0
  
        loops.each do |loop|
          
          # keep the loops array-index of the outer loop
          #if loop == @source.outer_loop
          #  nOuterLoopNum == nLoopCount
          #end
          
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
  
            #door het extra tussen gevoegde vlak ontstaan dubbele punten?
            
            # when a face has duplicate points it cannot be created, temporary solution: skip face
            begin
              face = group.entities.add_face pts
              face.material= @source.material
              
              #still errors
              vector = Geom::Vector3d.new @source.normal
              vector2 = Geom::Vector3d.new face.normal
              d = vector.dot vector2
              
              unless d.abs < 0.000001
                
                #better not recreate layer every time?
                Sketchup.active_model.layers.add "element_connections"
                face.layer= "element_connections"
              end
            rescue
              puts "error: failed to create face"
            end
  
            i += 1
          end
          
          # create the top and bottom faces
          face_top = group.entities.add_face aFacePtsTop
          face_top.material= @source.material
          face_bottom = group.entities.add_face aFacePtsBottom
          face_bottom.material= @source.back_material
          
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
      #@geometry.material= @source.material
      #@aOpenings.each do |opening|
      #puts opening
      #end
    end
    
    # returns an array of all openings in a planar object(face-cutting instances AND normal openings(loops))
    # Make sure you delete the temporary group afterwards
    def get_openings
    
      # start only if get_glued_instances is not nil???????
      
      aLoops = Array.new
      group = @geometry.entities.add_group
      
      @source.get_glued_instances.each do |instance|
      
        transform =  group.transformation.invert! * instance.transformation
      
        # copy all edges that are on the x-y plane to the new group
        instance.definition.entities.each do |entity|
          if entity.is_a?(Sketchup::Edge)
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
      
      #find all outer loops of the cutting component
      group.entities.each do |entity|
        if entity.is_a?(Sketchup::Face)
          aLoops << entity.outer_loop
        end
      end
      
      #get all non-outer_loops of the source face
      @source.loops.each do |loop|
        unless loop == @source.outer_loop
          aLoops << loop
        end
      end
      
      t = @geometry.transformation.inverse
      
      # copy all loop-Point3d-objects to the @openings array
      # the purpose of this is that the temporary group could be erased earlier
      aLoops.each do |loop|
        opening = Array.new
        loop.vertices.each do |vert|
          point = vert.position.transform t
          opening << point
        end
        @openings << opening
      end
      
      return Array[aLoops, group]
    end
    
    def possible_types
      return Array["Wall", "Floor", "Roof"]
    end
    def length?
    
      # define_length here might cause unneccesary overhead
      define_length
      return @length
    end  
    def height?
    
      # define_height here might cause unneccesary overhead
      define_height
      return @height
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
      define_length
      define_height
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
    
    # calculate the planar´s "length" == size in x-direction
    def define_length
      length = nil
      min = nil
      max = nil
      
      #check if geometry object is valid, how best?
      check_source
      #check_geometry
      unless @geometry.deleted?
        t = @geometry.transformation.inverse
        @source.vertices.each do |vertex|
          p = vertex.position.transform t
          if min.nil?
            min = p.x
          elsif p.x < min
            min = p.x
          end
          if max.nil?
            max = p.x
          elsif p.x > max
            max = p.x
          end
        end
        tot = max - min
        length = tot.to_mm.mm
      end
      return @length = length
    end
    
    # calculate the planar´s "height"  == size in y-direction
    def define_height
      height = nil
      min = nil
      max = nil
      
      #check if geometry object is valid, how best?
      check_source
      #check_geometry
      unless @geometry.deleted?
        t = @geometry.transformation.inverse
        check_source
        @source.vertices.each do |vertex|
          p = vertex.position.transform t
          if min.nil?
            min = p.y
          elsif p.y < min
            min = p.y
          end
          if max.nil?
            max = p.y
          elsif p.y > max
            max = p.y
          end
        end
        tot = max - min
        height = tot.to_mm.mm
      end
      return @height = height
    end
    
    # scale @source to match a new height and length
    def scale_source(new_length, new_height)
      if new_length.nil? || new_length == 0
        x_scale = 1
      else
        x_scale = new_length / length?
      end
      if new_height.nil? || new_height == 0
        y_scale = 1
      else
        y_scale = new_height / height?
      end
      z_scale = 1
      
      model = Sketchup.active_model
      entities = model.active_entities
  
      t = @geometry.transformation
      ti = t.inverse
      
      ts = Geom::Transformation.scaling(x_scale, y_scale, z_scale)
      
      a_Vertices = Array.new
      a_Vectors = Array.new
      
      @source.vertices.each do |vertex|
        po = vertex.position
        pn = Geom::Point3d.new(po.x, po.y, po.z)
        
        pn.transform! ti
        pn.transform! ts
        pn.transform! t
      
        vx = pn.x - po.x
        vy = pn.y - po.y
        vz = pn.z - po.z
        
        v = Geom::Vector3d.new vx,vy,vz
        
        a_Vertices << vertex
        a_Vectors << v
        
      end
      
      entities.transform_by_vectors a_Vertices, a_Vectors
      
      #why is @source deleted??? is moving vertices the same as scaling face???
      @project.source_recovery
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
      h_Properties["length"] = length?
      h_Properties["height"] = height?
      h_Properties["element_type"] = a_types
      # h_Properties["layer"] = a_layers
      h_Properties["name"] = @name
      h_Properties["description"] = @description
      return h_Properties
    end
    
    def properties=(h_Properties)
    
      @width = h_Properties["width"].to_f.mm
      @offset = h_Properties["offset"].to_f.mm
      length_new = h_Properties["length"].to_f.mm
      height_new = h_Properties["height"].to_f.mm
      #if length_new.nil?# || length_new == 0
      #  length_new = length?
      #end
      #if height_new.nil?
      #  height_new = height?
      #end
      
      unless length_new.nil? && height_new.nil?
      
      # check if length or height has changed
      #if length_new != length? || height_new != height?
      
        # scale_source to match new length
        scale_source(h_Properties["length"].to_f.mm, h_Properties["height"].to_f.mm)
      end
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
        @geometry.set_attribute "ifc", "length", length?.to_s
        @geometry.set_attribute "ifc", "height", height?.to_s
        @geometry.set_attribute "ifc", "width", @width.to_s #needs to be in planarelement class
        @geometry.set_attribute "ifc", "offset", @offset.to_s #needs to be in planarelement class
        @geometry.set_attribute "ifc", "description", description?.to_s
        @geometry.set_attribute "ifc", "name", name?.to_s
      end
      unless @source.nil?
        @source.set_attribute "ifc", "guid", guid?
      end
    end
    def ifc_export(exporter)
      #require 'bim-tools/lib/ifc_export/clsIfc.rb'
      if @element_type == "Wall"
      
        # function to figure out if both values are almost equal
        def approx(val, other, relative_epsilon=Float::EPSILON, epsilon=Float::EPSILON)
          difference = other - val
          return true if difference.abs <= epsilon
          relative_error = (difference / (val > other ? val : other)).abs
          return relative_error <= relative_epsilon
        end
        square_area = height? * length?
        
        # if the area of the source face equals length*height the face is a square
        # exept when wall openings are present!!!
        # and probably a wallstandardcase
        if approx(@source.area, square_area)
        
          # if the source face vector has an Z-value of zero then the wall is a standardcase
          # BEWARE OF NESTED COMPONENTS!
          if @source.normal.z == 0
            IfcWallStandardCase.new(@project, exporter, self)
          end
        else
          IfcWall.new(@project, exporter, self)
        end
      elsif @element_type == "Floor" || @element_type == "Roof"
        IfcSlab.new(@project, exporter, self)
      else
        IfcPlate.new(@project, exporter, self)
      end
    end
  end

end
