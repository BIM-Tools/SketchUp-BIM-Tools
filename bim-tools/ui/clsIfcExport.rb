#       clsWallsFromEdges.rb
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

module Brewsky
  module BimTools
    require 'bim-tools/ui/clsDialogSection.rb'
    
    class UiIfcExport < ClsDialogSection
      def initialize(dialog, id)
        @dialog = dialog
        @id = id.to_s
        @dialog = dialog
        @project = dialog.project
        @status = false
        @name = "IfcExport"
        @title = "Export to IFC"
        @buttontext = "Export to IFC file"
        @html_content = html_content
        callback
      end
    
      #action to be started on webdialog form submit
      def callback
        @dialog.webdialog.add_action_callback(@name) {|dialog, params|
          require 'bim-tools/lib/clsIfcExport.rb'
          exporter = IfcExporter.new(@dialog.project)
        }
      end
    
      # update webdialog based on selected entities
      def update(entities)
        @html_content = html_content
        refresh_dialog
      end
    
      def html_content
        return "
    <form id='" + @name + "' name='" + @name + "' action='skp:" + @name + "@true'>
    " + html_properties_editable + html_properties_fixed + "
    <input type='submit' name='submit' id='submit' value='" + @buttontext + "' />
    </form>
        "
      end
    
      def html_properties_editable
        html = ""
        return html
      end
    
      def html_properties_fixed
        html = ""
        return html
      end
    end
  end # module BimTools
end # module Brewsky
