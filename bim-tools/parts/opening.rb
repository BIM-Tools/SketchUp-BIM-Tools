#       opening.rb
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

# This class checks if a newly placed "cutting" component is glued to a wall, and cuts a hole.
class MyEntitiesObserver < Sketchup::EntitiesObserver
  def initialize(bt_lib)
    @bt_lib = bt_lib
  end
  def onElementAdded(entities, entity)
    require 'bim-tools/BtObjects.rb'
    model = Sketchup.active_model
    # run only if added entity is component instance
    if entity.typename == "ComponentInstance"
      # run only if added entity is "glued"
      if entity.glued_to != nil
	definition = entity.definition
	status = definition.behavior.cuts_opening?
	if (status)# run only if added entity cuts_opening
	  glue_surface = entity.glued_to
	  attribute = glue_surface.get_attribute "ifc", "ifc_element"
	  if attribute == "IfcWallStandardCase" # only cut holes in walls...
	    model.start_operation("Create opening", disable_ui=true) # Start of operation/undo section
	    
	    #require 'bim-tools\ifc_id.rb'
	    #IfcId.new.set_id(entity)
	    # find a unique id number and attach attribute to opening
	    require 'bim-tools/lib/ifcGeneral.rb'
	    set_id(entity)
	    
	    # first erase old hole
	    require 'bim-tools/erase_opening.rb'
	    erase_opening(entity, glue_surface)
	    
	    # cut new hole
	    require 'bim-tools/cut_opening.rb'
	    CutOpening.new(entity, glue_surface)
	    
	    # add observer to opening, to monitor any transformations
	    require 'bim-tools/opening_observer.rb'
	    entity.add_observer(OpeningObserver.new)
	    
	    # Create new opening object from geometry
	    opening_element = BtOpening.new(@bt_lib, entity)
	    
	    model.commit_operation # End of operation/undo section
	    model.active_view.refresh # Refresh model
	  end
	end
      end
    end
  end # onElementAdded
end # MyEntitiesObserver
