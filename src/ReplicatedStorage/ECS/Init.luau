--!strict
local StartPageService = game:GetService("StartPageService")
local module = {}
module.__index = module
type component = {
	sparse: { number },
	dense: { [number]: number },
	data: { [number]: any },
}

local nextID = 0

local function swaptable(tabletoswap, from, to)
	local todata = tabletoswap[to]
	tabletoswap[to] = tabletoswap[from]
	tabletoswap[from] = todata
end

local function getsmallestcomponent(self, components): string?
	local smallest = math.huge
	local Componentpicked = nil

	for i, componentType in ipairs(components) do
		if self.Components[componentType] then
			local amountOfEntities = #self.Components[componentType].dense
			if amountOfEntities < smallest then
				smallest = amountOfEntities
				Componentpicked = componentType
			end
		end
	end

	return Componentpicked
end

function module.new()
	local self = setmetatable({}, module)
	self.Components = {} :: { [string]: component }
	self.Entities = {} :: { [number]: { string } }
	self.Events = {
		ComponentAdded = Instance.new("BindableEvent"),
		ComponentRemoved = Instance.new("BindableEvent"),
	}
	return self
end

function module:newEntity()
	nextID = nextID + 1
	self.Entities[nextID] = {}
	return nextID
end

function module:destroyEntity(entity)
	local usedComponents = self.Entities[entity]

	for ComponentType, _ in pairs(usedComponents) do
		local Component = self.Components[ComponentType]
		local index = Component.sparse[entity]
		if index then
			self:removeComponent(entity, ComponentType)
		end
	end
end

function module:registerComponent(ComponentType)
	self.Components[ComponentType] = {
		sparse = {},
		dense = {},
		data = {},
	}
end

function module:hasComponent(entity, ComponentType): boolean?
	if not self.Components[ComponentType] then
		return nil
	end
	return self.Components[ComponentType].sparse[entity] ~= nil
end

function module:addComponent(entity, ComponentType, Component: any)
	if self:hasComponent(entity, ComponentType) then
		warn(tostring(entity) .. " already has " .. ComponentType)
		return
	end

	self.Entities[entity][ComponentType] = true

	local component = self.Components[ComponentType]
	if not component then
		self:registerComponent(ComponentType)
		component = self.Components[ComponentType]
	end

	table.insert(component.data, Component)
	local index = #component.data
	component.sparse[entity] = index
	component.dense[index] = entity

	self.Events.ComponentAdded:Fire(entity, ComponentType)
end

function module:removeComponent(entity, ComponentType)
	local component = self.Components[ComponentType]
	if not component then
		return
	end

	self.Entities[entity][ComponentType] = nil

	if not self:hasComponent(entity, ComponentType) then
		return
	end

	local index = component.sparse[entity]
	local lastindex = #component.data
	local lastentity = component.dense[lastindex]

	swaptable(component.data, index, lastindex)
	swaptable(component.dense, index, lastindex)
	component.sparse[lastentity] = index

	component.sparse[entity] = nil
	component.dense[lastindex] = nil
	component.data[lastindex] = nil

	self.Events.ComponentRemoved:Fire(entity, ComponentType)
end

function module:getcomponent(entity, ComponentType): any?
	if self:hasComponent(entity, ComponentType) then
		local component = self.Components[ComponentType]
		local index = component.sparse[entity]
		return component.data[index]
	end
	return nil
end

function module:queryentities(...)
	local result = {}
	local componentstofind = table.pack(...)
	local smallestComponent = getsmallestcomponent(self, componentstofind)
	local component = self.Components[smallestComponent]

	if not component then
		return result
	end

	for i = 1, #component.dense do
		local entity = component.dense[i]
		local hasall = true

		for _, ComponentType in ipairs(componentstofind) do
			if ComponentType ~= smallestComponent then
				local Component = self.Components[ComponentType]
				if not Component.sparse[entity] then
					hasall = false
					break
				end
			end
		end

		if hasall then
			table.insert(result, entity)
		end
	end

	return result
end

function module:foreach(components, callback: (number) -> ())
	local smallestComponent = getsmallestcomponent(self, components)
	local component = self.Components[smallestComponent]

	if not component or smallestComponent then
		return
	end

	for i = 1, #component.dense do
		local entity = component.dense[i]
		local hasall = true

		for _, ComponentType in pairs(components) do
			if ComponentType ~= smallestComponent then
				local Component = self.Components[ComponentType]
				if not Component.sparse[entity] then
					hasall = false
					break
				end
			end
		end

		if hasall then
            local newpcall: (...any) -> (boolean, string?) = pcall
            local success, errormsg = newpcall(callback, entity)
            if not success and errormsg then
                warn("Error: "..errormsg)
            end
		end
	end
end

return module
