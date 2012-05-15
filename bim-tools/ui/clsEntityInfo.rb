#       clsEntityInfo.rb
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

class ClsEntityInfo < ClsDialogSection
  def initialize(dialog)
    @dialog = dialog
    @project = dialog.project
    @status = true
    @name = "EntityInfo"
    @width = "-"
    @offset = "-"
    @volume = "-"
    @guid = "-"
    @html_content = html_content
    callback
  end

  #action to be started on webdialog form submit
  def callback
    require 'bim-tools/tools/bt_entities_update.rb'
    @dialog.webdialog.add_action_callback("EntityInfo") {|dialog, params|
      width = "-"
      offset = "-"

      #split string into separate values
      a_form_data = split_string(params)
      
      # validate data from html form
      h_Properties = extract_data(a_form_data)
      
      sel = @dialog.selection.btEntities?

      bt_entities_update(@project, sel, h_Properties)
    }
  end
  def html_content
    sel = @dialog.selection
    if sel.btEntities?.length == 0
      @status = false
      return "
<h2>No BIM-Tools entities selected</h2>
      "
    else
      @status = true
      return "
<h2>Selected entity</h2>
<form id='EntityInfo' name='EntityInfo' action='skp:EntityInfo@true'>
  " + html_properties_editable + "
  <hr />" + html_properties_fixed + "
  <input type='submit' name='submit' id='submit' value='Update selected entities' />
</form>
      "
    end
  end


  # update webdialog based on selected entities
  def update(entities)
    if entities.length == 0
      @width = "-"
      @offset = "-"
      @volume = "-"
      @guid = "-"
    end
    # pas de waarde voor breedte aan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # zoek in selectie of het een bt-object is, als dat zo is, pas de breedte daar op aan
    bt_entities = @project.library.array_remove_non_bt_entities(@project, entities)

    if bt_entities[0] != nil
      if bt_entities.length == 1
        @volume = bt_entities[0].volume? + " Millimeters ³"
        @guid = bt_entities[0].guid?
      end
      width_total = 0
      offset_total = 0
      bt_entities.each do |entity|
        width_total = width_total + entity.width
        offset_total = offset_total + entity.offset
      end
      if (width_total / bt_entities.length) == bt_entities[0].width
        @width = bt_entities[0].width.to_s
      else
        @width = "..."
      end
      if (offset_total / bt_entities.length) == bt_entities[0].offset
        @offset = bt_entities[0].offset.to_s
      else
        @offset = "..."
      end
    end
    @html_content = html_content
    refresh_dialog
  end
  
  def html_properties_editable
    sel = @dialog.selection
    html = ""
    if sel.common_properties_editable != nil
      input = data_in(sel.common_properties_editable)
      input.each do |field|
        if field[2] == "select"#.kind_of?(Array)
          list = ""
          first = true
          field[3].each do |val|
            unless val.nil?
              unless val.kind_of?(Array)
                if first == true
                  list = list + "
                  <option selected='selected'>" + val + "</option>
                  "
                  first = false
                else
                  list = list + "
                  <option>" + val + "</option>
                  "
                end
              end
            end
          end
          html = html + "
          <label for='" + field[0] + "'>" + field[1] + ":</label>
          <select name='" + field[0] + "' id='" + field[1] + "'>
          " + list + "
          </select>
          "
        else
          html = html + "
          <label for='" + field[0] + "'>" + field[1] + ":</label>
          <input name='" + field[0] + "' type='text' id='" + field[1] + "' value='" + field[3].to_s + "' />
          "
        end
      end
    end
    return html
  end

  def html_properties_fixed
    sel = @dialog.selection
    html = ""
    if sel.common_properties != nil
      sel.common_properties.each do |key, value|
        html = html + "
  <br />
  <label for='" + key + "'>" + key + ":</label>
  <input name='" + key + "' type='text' id='" + key + "' value='" + value + "' disabled='disabled' />
        "
      end
    end
    return html
  end
end
