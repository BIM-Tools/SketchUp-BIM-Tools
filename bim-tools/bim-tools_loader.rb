#       bim-tools_loader.rb
#       
#       Copyright (C) 2013 Jan Brouwer <jan@brewsky.nl>
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
    extend self
    attr_accessor :aBtProjects, :btDialog
    
    MAC = ( Object::RUBY_PLATFORM =~ /(darwin)/i ? true : false )
    OSX = MAC unless defined?(OSX)
    WIN = ( not MAC ) unless defined?(WIN)
    PC = WIN unless defined?(PC)
    
    @aBtProjects = Array.new
    
    require 'bim-tools/clsBtProject.rb'
    require 'bim-tools/ui/clsBtUi.rb'
    require 'bim-tools/lib/ObserverManager.rb'
    
    def active_BtProject
      @aBtProjects.each do |btProject|
        if btProject.model == Sketchup.active_model
          return btProject
        end
      end
    end
    def new_BtProject
      btProject = ClsBtProject.new
      @aBtProjects << btProject
    end

    new_BtProject
    
    # start all UI elements: webdialog (?toolbar?)
    btUi = ClsBtUi.new(self)
    
    # create access point to webdialog manager
    @btDialog = btUi.btDialog
    

  end # module BimTools
end # module Brewsky
