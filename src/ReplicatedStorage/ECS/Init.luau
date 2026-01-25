--!strict
local module = {}
module.__index = module
type component = {
	sparse: {number},
	dense: {[number]: number},
    data: {[number]: any}
}

local nextID = 0

local function swaptable(tabletoswap, from, to)
	local todata = tabletoswap[to]
	tabletoswap[to] = tabletoswap[from]
	tabletoswap[from] = todata
end

local function getsmallestcomponent(self, ...): component?
    local components = table.pack(...)
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
    self.Components = {} :: {[string]: component}
    return self
end

function module:newEntity()
    nextID = nextID + 1
    return nextID
end

function module:destroyEntity(entity)
    for ComponentType: string, component: component in pairs(self.Components) do
        local index = component.sparse[entity]
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
    if self.hasComponent(entity, ComponentType) then
        warn(tostring(entity).." already has "..ComponentType)
        return
    end

    local component = self.Components[ComponentType]
    if not component then
        self.registerComponent(ComponentType)
        component = self.Components[ComponentType]
    end
    
    table.insert(component.data, Component)
    local index = #component.data
    component.sparse[entity] = index
    component.dense[index] = entity
end

function module:removeComponent(entity, ComponentType)
    local component = self.Components[ComponentType]
    if not component then
        return
    end

    if not self.hasComponent(entity, ComponentType) then
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
    
    if not component then return end

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

--debug purposes
function module:returneverything()
    return self.Components
end

return module