#       clsBtEntity.rb
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

  # basic building element class
  # Object "parallel" to sketchup "entity" object
  # optional parameters: id, name, description
  class ClsBtEntity
  
    # attributes accessible from outside class
    attr_reader :id, :name, :description # get entity @id, @name, @desctiption
    # when to use self.xxx?
  
    def initialize(id=nil, name=nil, description=nil)
      @lib = ClsBtLibrary.new # would ClsBtEntities be a better name?
      setProjectId(id) # do or do not use "project" in method names?
      setProjectName(name)
      setProjectDescription(description)
      setProjectObservers
    end
  
    def id!(id) # set entity id
  
      # if id == allowed guid-string
      @id = id
      # else
      #   if @id does not exist
      #     generate new guid
      #     @id = guid
    end
    def name!(name) # set entity name
  
      # if name == string
      @name = name
      # else
      #   get default value for name
      #   @name = default
    end
    def description!(description) # set entity description
  
      # if description == string
      @description = description
      # else
      #   get default value for description
      #   @description = default
    end
  end

end
