#       clsDialogSection.rb
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

class ClsDialogSection
  def initialize(dialog)
    @dialog = dialog
    @status = true
    @name = "default"
    @title = "default"
    @html_content = ""
  end
  def html
    if @status == true
      output = "
<a href='skp:min_max@" + @name + "=false'><h1 style='background-image: url(" + @dialog.imagepath + "minimize.png)'><img src='" + @dialog.imagepath + @name + "_small.png' />" + @title + "</h1></a><hr />
      "
      output = output + @html_content
      return output
    else
      return"
<a href='skp:min_max@" + @name + "=true'><h1 style='background-image: url(" + @dialog.imagepath + "maximize.png)'><img src='" + @dialog.imagepath + @name + "_small.png' />" + @title + "</h1></a><hr />
      "
    end
  end
  def name?
    return @name
  end
  def minimize
    @status = false
  end
  def maximize
    @status = true
  end
  def refresh_dialog
    @dialog.refresh
  end
  def split_string(string)
    a_form_data = Array.new
    a_split = string.split("?")
    a_split = a_split[1].split("&")
    a_split.each do |value|
      a_form_data << value.split("=")
    end
    return a_form_data
  end
  
  # allowed data fields
  def fields
    # array[name, Shown name, field_type, unit, value]

    a_fields = Array.new
    a_fields << Array["length", "Length", "text", 3000, "length"]
    a_fields << Array["height", "Height", "text", 2600, "length"]
    a_fields << Array["width", "Thickness", "text", 300, "length"]
    a_fields << Array["offset", "Offset", "text", 150, "length"]
    a_fields << Array["element_type", "Element type", "select", "Wall",]
    a_fields << Array["profile", "Profile", "text", "definition",]
    a_fields << Array["material", "Material", "text", "material_name",]
    # a_fields << Array["layer", "Layer", "select", "Layer 01",]
    a_fields << Array["name", "Name", "text", "name",]
    a_fields << Array["description", "Description", "text",]
    a_fields << Array["guid", "GUID", "text",  "string"]
    a_fields << Array["volume", "Volume", "text", 300, "mm3"]
    
    return a_fields
  end
  
  # sorts data fields before building html form
  # input hash contains key = name from list and value=value
  def data_in(h_properties)
    a_form_input = Array.new
    fields.each do |field|

      # if field exists in input hash, then add field + new value to array
      if h_properties.has_key?(field[0]) == true
      
        if h_properties[field[0]].nil?
          h_properties[field[0]] = ""
        end        
      
        field[3] = h_properties[field[0]]
        a_form_input << field
      end
    end
    
    return a_form_input
  end
  
  # extract and validate data from html form
  def extract_data(a_form_data)
    h_Properties = Hash.new
    a_form_data.each do |pair|
      fields.each do |field|
        if pair[0] == field[0]
          if field[4] == "length"
            if pair[1].nil? # == nil
              h_Properties[pair[0]] = 0
            elsif pair[1] != "..."
              length = extract_length(pair[1])
              if length.eql? false
              else
                h_Properties[pair[0]] = length
              end
            end
          elsif field[4] == "select"
            unless pair[1].nil? || pair[1] == "..."
            #if pair[1] == nil
            #  h_Properties[pair[0]] = ""
            #elsif pair[1] == "..."
            #else
              h_Properties[pair[0]] = pair[1].to_s
            end
          else # if not length, than string # this is not allways correct, an array(select) could contain numbers(lengths)
            
            # better notation?
            unless pair[1].nil? || pair[1] == "..."
            #if pair[1] == nil
            #  h_Properties[pair[0]] = ""
            #elsif pair[1] == "..."
            #else
              h_Properties[pair[0]] = pair[1]#.to_s
            end
          end
        end
      end
    end
    return h_Properties
  end
  def extract_length(string)
    begin
      length = string.to_l.to_mm
      if length
        return length
      end
    rescue
      return false
    end
  end
end
