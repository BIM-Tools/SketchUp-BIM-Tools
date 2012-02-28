#       bt_dialog.rb
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

class Bt_dialog

  def initialize(project)
    @project = project
    bt_lib = @project.library
		    
    # Create WebDialog instance
    @dialog = UI::WebDialog.new("BIM-Tools menu")
    @dialog.min_width= 243
    @dialog.max_width= 243
    
    @pathname = File.expand_path( File.dirname(__FILE__) )
    mainpath = @pathname.split('ui')[0]
    @imagepath = mainpath + "images" + File::SEPARATOR
    @bt_lib = bt_lib
    @javascript = ""
    
    # create BIM-Tools selection object
    require 'bim-tools/lib/clsBtSelection.rb'
    @selection = ClsBtSelection.new(@project, self)
    
    @h_sections = Hash.new
    
    # define sections
    require 'bim-tools/ui/clsEntityInfo.rb'
    entityInfo = ClsEntityInfo.new(self)
    @h_sections["EntityInfo"] = entityInfo
    #@h_sections["ProjectData"] = ClsProjectData.new
    
    @dialog.set_html( html ) 
    @dialog.show
    
    # Attach the observer.
    Sketchup.active_model.selection.add_observer(MySelectionObserver.new(@project, self, entityInfo))
		
  end
  def refresh
    @dialog.set_html( html ) 
  end
  def html
    content = ""
    @h_sections.each_value do |section|
      content = content + section.html
    end
    return html_top + content + html_bottom
  end
  def html_top
    return "
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset=utf-8'>
    <title>BIM-Tools - webdialog</title>
    <link href='" + @pathname + "/bt_dialog.css' rel='stylesheet' type='text/css' />
    <style type='text/css'> h1 {background-image: url(" + @imagepath + "minimize.png)}</style>
    </head>
    <body>
    "
  end
  def html_bottom
    return "
    </body>
    </html>
    "
  end
  def webdialog
    return @dialog
  end
  def close
    if @dialog.visible?
      @dialog.close
    end
  end
  def selection
    return @selection
  end
  def imagepath
    return @imagepath
  end
  def project
    return @project
  end  # This is an example of an observer that watches the selection for changes.
  class MySelectionObserver < Sketchup::SelectionObserver
    def initialize(project, bt_dialog, entityInfo)
			@project = project
			@bt_dialog = bt_dialog
			@entityInfo = entityInfo
		end
		def onSelectionBulkChange(selection)
			# open menu entity_info als de selectie wijzigt
			#js_command = "entity_info(1)"
			#@dialog.execute_script(js_command)

			
			#js_command = 'entity_info_width("' + width.to_s + '")'
			#@dialog.execute_script(js_command)
			@entityInfo.update(selection)
			#@bt_dialog.webdialog.set_html( @bt_dialog.html )
		end
		def onSelectionCleared(selection)
			@entityInfo.update(selection)
			#@bt_dialog.webdialog.set_html( @bt_dialog.html )
		end
	end
end
