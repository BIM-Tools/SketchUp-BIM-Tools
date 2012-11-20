#       bt_dialog_css.rb
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

		# returns the dialog css
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
  end # module BimTools
end # module Brewsky
