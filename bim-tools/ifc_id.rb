class IfcId
	def initialize()
		@model = Sketchup.active_model
		
		# check if ifc_id exists. no? current_id
		if @model.get_attribute "ifc", "id" == nil
			current_id()
		end
	end
	def current_id()
		# loop through all objects and find attributes ifc/id
		# check if id exists
		# yes? problem! model inconsistent! duplicates!
		# no? and add to array ifc_id
		# it might be neccasary to create an additional attribute dictionary under sketchup.active_model with all once used id's to prevent possible conflicts during import/export
		@model.set_attribute "ifc", "id", 0
	end
	def set_id(entity)
		#set ifc id for current element
		entity.set_attribute "ifc", "id", new_id()
	end
	def new_id()
		# get current id value, increment with 1, save as current and return
		current_id = @model.get_attribute "ifc", "id"
		new_id = current_id.to_i + 1
		@model.set_attribute "ifc", "id", new_id
		return new_id
	end
end
