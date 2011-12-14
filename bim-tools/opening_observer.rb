#       opening_observer.rb
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

class OpeningObserver < Sketchup::EntityObserver
	def onChangeEntity(entity)
		model = Sketchup.active_model
		entity = entity
		glue_surface = entity.glued_to
		
		model.start_operation("Modify opening", disable_ui=true) # Start of operation/undo section
		
		require 'bim-tools/erase_opening.rb'
		erase_opening(entity, glue_surface)
		
		require 'bim-tools/cut_opening.rb'
		CutOpening.new(entity, glue_surface)
		
		model.commit_operation # End of operation/undo section
    model.active_view.refresh # Refresh model
	end
end
