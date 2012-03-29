#       bt_entities_update.rb
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

# Function that takes an array of BIM-Tools-elements as input, and updates its properties and the geometry for all connecting BIM-Tools-elements.
#   parameters: BIM-Tools-project, array of BIM-Tools-elements, properties-hash
#   returns: -

  def bt_entities_update(project, a_bt_entities, h_Properties)
   # start undo section
    model = Sketchup.active_model
    model.start_operation("Change planars", disable_ui=true) # Start of operation/undo section

    # maak een nieuw array waarin alle te updaten bt_entities verzameld worden
    #to_update = Array.new
    
    # check if entity = bt_entity
    a_bt_entities.each do |bt_entity|
      bt_entity.properties=(h_Properties)
      bt_entity.set_planes
    end
    
    project.bt_entities_set_geometry(a_bt_entities)
    
    model.commit_operation # End of operation/undo section
    model.active_view.refresh # Refresh model
  end
#end
  # deze functie moet een betere plek krijgen
  def find_bt_entity_for_face(project, face)
    bt_entity = nil
    project.library.entities.each do |ent|
      if face == ent.source # als het vlak voorkomt in de bt-library
        bt_entity = ent
        break
      end
    end
    return bt_entity
  end
  
  # deze functie moet een betere plek krijgen
  def find_bt_entity_for_group(project, group)
    bt_entity = nil
    project.library.entities.each do |ent|
      if group == ent.geometry # als het vlak voorkomt in de bt-library
        bt_entity = ent
        break
      end
    end
    return bt_entity
  end
