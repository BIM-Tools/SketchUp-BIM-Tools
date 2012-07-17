#       dlgSecPLanarsFromFaces.rb
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

require 'bim-tools/ui/clsDialogSection.rb'

class ClsDlgSecProjectData < ClsDialogSection
  def initialize(dialog, id)
    @dialog = dialog
    @id = id.to_s
    @project = dialog.project
    @status = false
    @name = "ProjectData"
    @title = "Edit project properties"
    @buttontext = "Update project properties"
    @html_content = html_content
    callback
  end

  #action to be started on webdialog form submit
  def callback
    @dialog.webdialog.add_action_callback(@name) {|dialog, params|
      h_form_data = Hash.new
      a_split = params.split("?")
      a_split = a_split[1].split("&")
      a_split.each do |value|
        a,b = value.split("=")
        h_form_data[a] = b
      end
      unless h_form_data["project_name"].nil?
        @project.name= h_form_data["project_name"]
      end
      unless h_form_data["project_description"].nil?
        @project.description= h_form_data["project_description"]
      end
    }
  end
  
  # update webdialog based on selected entities
  def update(entities)
    @html_content = html_content
    refresh_dialog
  end
  
  def html_content
    return "
<form id='" + @title + "' name='" + @name + "' action='skp:" + @name + "@true'>
" + html_properties_editable + html_properties_fixed + "
<input type='submit' name='submit' id='submit' value='" + @buttontext + "' />
</form>
    "
  end

  def html_properties_editable
    sel = @dialog.selection
    html = "
			<h2>Project details:</h2>
        <label for='project_name'>Name:</label>
				<input type='text' name='project_name' id='project_name' value='" + @project.name + "' /><br />
        <label for='project_description'>Description:</label>
				<input type='text' name='project_description' id='project_description' value='" + @project.description + "' />
			<h2>Site details:</h2>
        <label for='site_name'>Name:</label>
				<input type='text' name='site_name' id='site_name' value='" + @project.site_name + "' /><br />
        <label for='site_description'>Description:</label>
				<input type='text' name='site_description' id='site_description' value='" + @project.site_description + "' />
			<h2>Building details:</h2>
        <label for='building_name'>Name:</label>
				<input type='text' name='building_name' id='building_name' value='" + @project.building_name + "' /><br />
        <label for='building_description'>Description:</label>
				<input type='text' name='building_description' id='building_description' value='" + @project.building_description + "' />
			<h2>Author information:</h2>
        <label for='author'>Role:</label>
				<input type='text' name='author' id='author' value='" + @project.author + "' /><br />
        <label for='organisation_name'>Name:</label>
				<input type='text' name='organisation_name' id='o_name' value='" + @project.organisation_name + "' /><br />
        <label for='organisation_description'>Description:</label>
				<input type='text' name='organisation_description' id='organisation_description' value='" + @project.organisation_description + "' />
          "
    return html
  end

  def html_properties_fixed
    sel = @dialog.selection
    html = ""
    return html
  end
end
