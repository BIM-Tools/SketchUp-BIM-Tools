#       bt_dialog.rb
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

  class Bt_dialog
    attr_reader :dialog#, :h_sections
    
    def initialize(bimTools, visible=false)
      #bimTools.set_btDialog(self)

      @bimTools = bimTools
      #@project = @bimTools.active_BtProject
      #bt_lib = @project.library
  
      new_webdialog
      
      @pathname = File.expand_path( File.dirname(__FILE__) )
      mainpath = @pathname.split('ui')[0]
      @imagepath = mainpath + "images/"
      #@bt_lib = bt_lib
      @javascript = ""
      
      callback
      
      # create BIM-Tools selection object
      require 'bim-tools/lib/clsBtSelection.rb'
      @selection = ClsBtSelection.new(@bimTools, self)
      
      @h_sections = Hash.new
      
      # start min/maximizer
      min_max
      
      # define sections, ordered by hash index number
      
      require 'bim-tools/ui/clsEntityInfo.rb'
      section = ClsEntityInfo.new(self, "0")
      name = section.name?
      @h_sections["0"] = section
      
      require 'bim-tools/ui/clsWallsFromEdges.rb'
      section = ClsWallsFromEdges.new(self, "1")
      name = section.name?
      @h_sections["1"] = section
      
      require 'bim-tools/ui/dlgSecPlanarsFromFaces.rb'
      section = ClsDlgSecPlanarsFromFaces.new(self, "2")
      name = section.name?
      @h_sections["2"] = section
      
      require 'bim-tools/ui/dlgSecProjectData.rb'
      section = ClsDlgSecProjectData.new(self, "3")
      name = section.name?
      @h_sections["3"] = section
      
      require 'bim-tools/ui/clsIfcExport.rb'
      section = UiIfcExport.new(self, "4")
      name = section.name?
      @h_sections["4"] = section
      
      #@h_sections["ProjectData"] = ClsProjectData.new
      
      @dialog.set_html( html )
      if visible == true
        open
      end
      # Attach the observer.
      #Sketchup.active_model.selection.add_observer(MySelectionObserver.new(@project, self, @h_sections))
      return self
    end
    
    # switch dialog visibility
    def toggle
      if @dialog.nil?
        open
      else
        if @dialog.visible?
          close
        else
          open
        end
      end
    end
    def update_sections(selection)
      @h_sections.each_value do |section|
        section.update(selection)
      end
      refresh
    end
    def show
      MAC ? @dialog.show_modal() : @dialog.show()
      # return nil
    end
    def refresh
      @dialog.set_html( html )
    end
    def callback
      self.webdialog.add_action_callback("cmd_bimtools") {|dialog, params|
        self.close
      }
      self.webdialog.add_action_callback("cmd_toggle_geometry") {|dialog, params|
        @bimTools.active_BtProject.toggle_geometry()
      }
      self.webdialog.add_action_callback("cmd_clear") {|dialog, params|
        require "bim-tools/tools/clear_properties.rb"
        selection = Sketchup.active_model.selection
        ClearProperties.new(@bimTools.active_BtProject, selection)
      }
    end
    def html
      content = ""
      @h_sections.each do |id, section|
        content = content + section.html + "<hr />"
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
      <ul>
      <li><a href='skp:cmd_bimtools@true'><img src='" + self.imagepath + "bimtools_large.png' /></a></li>
      <li><a href='skp:cmd_toggle_geometry@true'><img src='" + self.imagepath + "ToggleGeometry_large.png' /></a></li>
      <li><a href='skp:cmd_clear@true'><img src='" + self.imagepath + "clear_large.png' /></a></li>
      </ul>
      <hr />
      "
    end
    def html_bottom
      return "
      </body>
      </html>
      "
    end
    
    #action to be started on webdialog minimize/maximize
    def min_max
      @dialog.add_action_callback("min_max") {|dialog, params|
  
        #split string into separate values
        values =  params.split("=")
        section = values[0]
        max = values[1]
        if max == "true"
          @h_sections[section].maximize
        else
          @h_sections[section].minimize
        end
        @dialog.set_html( html )
      }
    end
    def webdialog
      return @dialog
    end
    def new_webdialog
    
      # Create WebDialog instance, patched for OSX
      require 'bim-tools/lib/WebdialogPatch.rb'
      @dialog = WebDialogPatch.new("BIM-Tools menu", false, "bim-tools", 243, 320, 150, 150, true)
  
      # Create WebDialog instance
      # @dialog = UI::WebDialog.new("BIM-Tools menu")
      @dialog.min_width= 243
      @dialog.max_width= 243
    end
    def open
      if @dialog.nil?
        new_webdialog
      end
      unless @dialog.visible?
        show
      end
    end
    def close
      unless @dialog.nil?
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
      return @bimTools.active_BtProject
    end  # This is an example of an observer that watches the selection for changes.
    #class MySelectionObserver < Sketchup::SelectionObserver
    #  def initialize(project, bt_dialog, h_sections)
    #    @project = project
    #    @bt_dialog = bt_dialog
    #    #@entityInfo = entityInfo
    #    #@wallsfromedges = wallsfromedges
    #    @h_sections = h_sections
    #  end
    #  def onSelectionBulkChange(selection)
    #    # open menu entity_info als de selectie wijzigt
    #    #js_command = "entity_info(1)"
    #    #@dialog.execute_script(js_command)
 # 
 #      
 #       #js_command = 'entity_info_width("' + width.to_s + '")'
 #       #@dialog.execute_script(js_command)
 #       #@entityInfo.update(selection)
 #       #@wallsfromedges.update(selection)
 #       
 #       @h_sections.each_value do |section|
 #         section.update(selection)
 #       end
 #       
 #       #@bt_dialog.webdialog.set_html( @bt_dialog.html )
 #     end
 #     def onSelectionCleared(selection)
 #       #@entityInfo.update(selection)
 #       #@wallsfromedges.update(selection)
 #       
 #             
 #       @h_sections.each_value do |section|
 #         section.update(selection)
 #       end
 #       
 #       #@bt_dialog.webdialog.set_html( @bt_dialog.html )
 #     end
 #   end
  end

end
