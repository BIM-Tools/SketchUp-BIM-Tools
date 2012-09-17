#       project_data.rb
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

module Brewsky::BimTools

  # Save project data to SketchUp attribute library
  def project_data_update(string_key_value)
      model = Sketchup.active_model
      
      #split string into separate values
      array_key_value = string_key_value.split(",")
      key = array_key_value[0]
      value = array_key_value[1]
      
      #write attribute
		  model.set_attribute "ifc", key, value
		  
	    #print current attribute value
      #test1 = model.get_attribute "ifc", key, "Default project"
	    #UI.messagebox("Attribute: " + test1.to_s)
	    
	    #if changed value is "project_name" or "project_description, also update "model name" and "model description"
	    if key == "project_name"
		  model.name = value
	    elsif key == "project_description"
		  model.description = value
	    end
	    
	    #update webdialog for confirmation
	    webdialog_update(key, value)
  end
  def webdialog_update(key, value)
	  js_command = "getData('" + key.to_s + "', '" + value.to_s + "')"
	  @dialog.execute_script(js_command)
  end

end
