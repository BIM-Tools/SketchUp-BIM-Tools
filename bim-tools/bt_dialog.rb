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

	def initialize(bt_lib)
		
		# Create WebDialog instance
		@dialog = UI::WebDialog.new
		
		pathname = File.expand_path( File.dirname(__FILE__) )
		#@walls = File.join( pathname, 'walls.rb' )
		@walls = File.dirname(__FILE__) + File::SEPARATOR + "parts" + File::SEPARATOR + "wall.rb"
		@exporter = File.join( pathname, 'IFCexporter.rb' )
		@imagepath = File.dirname(__FILE__) + File::SEPARATOR + "images" + File::SEPARATOR
		@bt_lib = bt_lib
		@dialog.set_html( html ) 
		
		self.walls()
		self.project_data()
		self.export()
		
		@dialog.show
		
	end
	
	def project_data
		# Attach an action callback
		@dialog.add_action_callback("get_data") do |dialog,value|
			require 'bim-tools\project_data.rb'
			project_data_update(value)
		end
	end

	def walls()
		require @walls
		@dialog.add_action_callback("walls_from_selection") {|dialog, params|
			wall_height = dialog.get_element_value("height")
			wall_width = dialog.get_element_value("width")
			walls_from_selection(@bt_lib, wall_width, wall_height)
		}
	end

	def export()
		require @exporter
		@dialog.add_action_callback("ifcexporter") {|dialog, params|
			IFCexporter.new(@bt_lib)
			
		}
	end
	
	def html
	
		sections = Array.new
		index = 0
		
		title = "Create"
		content = "
			<h2>Walls</h2>
			<form action='skp:walls_from_selection@true'>
					<span class='input'>Height:</span>
					<input type='text' name='height' value='2600' /><br />
					<span class='input'>Width:</span>
					<input type='text' name='width' value='100' />
				<input class='submit' type='submit' name='submit' value='Walls from selection' />
			</form>
		"
		sections << html_section(index +=1, title, content)
		
		title = "Export"
		content = "
			<h2>Export to IFC</h2>
			<form action='skp:ifcexporter@true'>
				<input class='submit' type='submit' name='submit' value='Export to IFC' />
			</form>
		"
		sections << html_section(index +=1, title, content)
		
		title = "Project"
		content = "
			<h2>Project details:</h2>
				<span class='input'>Name:</span>
				<input type='text' onchange='submitData(\"project_name\")' id='project_name' value='" + get_attribute("project_name") + "' /><br />
				<span class='input'>Description:</span>
				<input type='text' onchange='submitData(\"project_description\")' id='project_description' value='" + get_attribute("project_description") + "' />
			<h2>Site details:</h2>
				<span class='input'>Name:</span>
				<input type='text' onchange='submitData(\"site_name\")' id='site_name' value='" + get_attribute("site_name") + "' /><br />
				<span class='input'>Description:</span>
				<input type='text' onchange='submitData(\"site_description\")' id='site_description' value='" + get_attribute("site_description") + "' />
			<h2>Building details:</h2>
				<span class='input'>Name:</span>
				<input type='text' name='building_name' onchange='submitData(\"building_name\")' id='building_name' value='" + get_attribute("building_name") + "' /><br />
				<span class='input'>Description:</span>
				<input type='text' onchange='submitData(\"building_description\")' id='building_description' value='" + get_attribute("building_description") + "' />
			<h2>Author information:</h2>
				<span class='input'>Role:</span>
				<input type='text' name='author' onchange='submitData(\"author\")' id='author' value='" + get_attribute("author") + "' /><br />
				<span class='input'>Name:</span>
				<input type='text' name='organisation_name' onchange='submitData(\"organisation_name\")' id='o_name' value='" + get_attribute("organisation_name") + "' /><br />
				<span class='input'>Description:</span>
				<input type='text' name='organisation_description' onchange='submitData(\"organisation_description\")' id='organisation_description' value='" + get_attribute("organisation_description") + "' />
		"
		sections << html_section(index +=1, title, content)
		
		content = ""
		
		sections.each do |section|
			content = content + section
		end
		
		return html_top + content + html_bottom
		
	end
	
	def html_section(index, title, content)
		return "
			<div id='" + index.to_s + "' class='section'>
				<img src='" + @imagepath + "maximize.png' class='minmax' onclick='menu_visibility(\"" + index.to_s + "\")'>
				<h1>" + title + "</h1>
				<div class='input-block' style='display:none;'>
				" + content + "
				</div>
			</div>
		"
	end
	
	def html_top
		start_top = "
			<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'
			'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>
			<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en' style='margin:0;padding:0;height:100%:position:relative'>
				<head>
					<title>bt_window</title>
					<link rel='stylesheet' type='text/css' href='bim-tools.css' />
					<meta http-equiv='content-type' content='text/html;charset=utf-8' />
		"
		end_top = "
			</head>
			<body style='margin:0;padding:0;height:100%:position:relative'>
		"
		return start_top + html_css + html_script + end_top
	end
	
	def html_bottom
		return "
				</body>
			</html>
		"
	end
	
	def html_script
		return "
			<script type='text/javascript'>
				function menu_visibility(IDS){
					var section = document.getElementById(IDS).getElementsByTagName('div');
					var expand = document.getElementById(IDS).getElementsByTagName('img');
					if(section[0].style.display == 'block') {
						section[0].style.display = 'none'
						expand[0].src = '" + @imagepath + "maximize.png'
					}
					else {
						section[0].style.display = 'block'
						expand[0].src = '" + @imagepath + "minimize.png'
					}
				}
				function submitData(key) {
					value = document.getElementById(key).value;
					query = 'skp:get_data@' + key +',' + value;
					window.location.href = query;
				}
				function getData(key, value) {
					document.getElementById(key).value = value;
				}
			</script>
		"
	end
	
	def html_css
		return "
			<style type='text/css'>
				html {
					margin: 0;
					padding: 0;
				}
				body {
					font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif;
					font-size: 0.7em;
					background-color: #f0f0f0;
					margin: 0;
					padding: 0;
				}
				h1 {
					font-weight: bold;
					font-size: 1em;
					margin: 0;
					padding: 0.5em 0px 0px 0.8em;
					width: auto;
					height: 1.5em;
					border-bottom: 1px solid #a0a0a0;
				}
				h2 {
					font-weight: bold;
					font-size: 1em;
					width: 100%;
					height: 1em;
					margin: 0;
					padding: 0.5em 2% 0.5em 0;
				}
				hr {
					margin: 0px 3px 0px 3px;
					padding: 0;
				}
				form {
					width: 100%;
					margin: 0;
					padding: 0;
				}
				input {
					font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif;
					font-size: 1em;
					width: 65%;
					height: 1.5em;
					float: left;
					margin: 0.2em 0;
					padding: 0;
				}
				.input {
					display: block;
					height: 1em;
					width: 25%;
					float: left;
					margin: 0;
					padding: 0;
				}
				.submit {
					font-size: 1em;
					height: 2em;
					width: 65%;
					float: left;
					margin: 0 0 0 25%;
					padding: 0;
				}
				.minmax {
					float: right;
					margin: 0px;
					padding: 0px;
					border: 0;
				}
				.section {
					border: 0;
				}
				.input-block {
					width: 100%;
					border: 0 solid #f0f0f0;
					border-width: 0em 0.5em 0em 1.6em;
					margin: 0 0 0.2em 0;
					padding: 0;
				}
			</style>
		"
	end
	
	def get_attribute(key)
		model = Sketchup.active_model
		attribute = model.get_attribute "ifc", key
		return attribute.to_s
	end
end
