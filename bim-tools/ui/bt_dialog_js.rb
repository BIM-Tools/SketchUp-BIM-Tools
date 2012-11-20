#       bt_dialog_js.rb
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

		# returns the dialog javascript
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
  end # module BimTools
end # module Brewsky
