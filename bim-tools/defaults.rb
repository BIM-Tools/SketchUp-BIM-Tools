#       defaults.rb
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

class Set_defaults

	def initialize()
		require 'bim-tools\config.rb'
				
		set_value("author", Bt_Config::Author)
		set_value("organization", Bt_Config::Organization)
		set_value("project_name", Bt_Config::Project_name)
		set_value("project_description", Bt_Config::Project_description)
		set_value("owner_creation_date", Bt_Config::Owner_creation_date)
		set_value("person_id", Bt_Config::Person_id)
		set_value("person_familyname", Bt_Config::Person_familyname)
		set_value("person_givenname", Bt_Config::Person_givenname)
		set_value("organisation_name", Bt_Config::Organisation_name)
		set_value("organisation_description", Bt_Config::Organisation_description)
		set_value("site_name", Bt_Config::Site_name)
		set_value("site_description", Bt_Config::Site_description)
		set_value("building_name", Bt_Config::Building_name)
		set_value("building_description", Bt_Config::Building_description)
		
	end
	
	def set_value(key, value)
		model = Sketchup.active_model
		attrib = model.get_attribute "ifc", key
		#write attribute if not exist/empty
		if attrib == 0 || attrib == nil
 		  model.set_attribute "ifc", key, value
		end
		# Sketchup.active_model.get_attribute "ifc", "ifc_person_id"
	end

end
