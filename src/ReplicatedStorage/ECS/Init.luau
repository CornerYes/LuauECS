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

function module.new()
    local self = setmetatable({}, module)
    self.Components = {} :: {[string]: component}
    return self
end

function module:newEntity()
    nextID = nextID + 1
    return nextID
end

function module:registerComponent(ComponentType)
	self.Components[ComponentType] = {
		sparse = {},
        dense = {},
        data = {},
	}
end

function module:hasComponent(EntityID, ComponentType): boolean?
    if not self.Components[ComponentType] then
        return nil
    end
    return self.Components[ComponentType].sparse[EntityID] ~= nil
end

function module:addComponent(EntityID, ComponentType, Component: any)
    if self.hasComponent(EntityID, ComponentType) then
        warn(tostring(EntityID).." already has "..ComponentType)
        return
    end

    local componentlist = self.Components[ComponentType]
    if not componentlist then
        self.registerComponent(ComponentType)
        componentlist = self.Components[ComponentType]
    end
    
    table.insert(componentlist.data, Component)
    local index = #componentlist.data
    componentlist.sparse[EntityID] = index
    componentlist.dense[index] = EntityID
end

function module:removeComponent(EntityID, ComponentType)
    local componentlist = self.Components[ComponentType]
    if not componentlist then
        return
    end

    if not self.hasComponent(EntityID, ComponentType) then
        return
    end

    local index = componentlist.sparse[EntityID]
    local lastindex = #componentlist.data
    local lastEntityID = componentlist.dense[lastindex]

    swaptable(componentlist.data, index, lastindex)
    swaptable(componentlist.dense, index, lastindex)
    componentlist.sparse[lastEntityID] = index

    componentlist.sparse[EntityID] = nil
    componentlist.dense[lastindex] = nil
    componentlist.data[lastindex] = nil
end

function module:getcomponent(entityID, ComponentType): any?
    local componentList = self.Components[ComponentType]
    if componentList then
        local index = componentList.sparse[entityID]
        return componentList.data[index]
    end
    return nil
end

function module:queryentities(...)
    local result = {}
    local componentstofind = table.pack(...)
    local smallest = math.huge
    local Componentpicked = nil

    for i, componentType in ipairs(componentstofind) do
        if self.Components[componentType] then
            local amountOfEntities = #self.Components[componentType].dense
            if amountOfEntities < smallest then
                smallest = amountOfEntities
                Componentpicked = componentType
            end
        end
    end

    local ComponentList = self.Components[Componentpicked]

    for i = 1, #ComponentList.dense do
        local entityID = ComponentList.dense[i]
        local hasall = true

        for _, ComponentType in ipairs(componentstofind) do
            if ComponentType ~= Componentpicked then
                local Component = self.Components[ComponentType]
                if not Component.sparse[entityID] then
                    hasall = false
                    break
                end
            end
        end

        if hasall then
            table.insert(result, entityID)
        end
    end
    return result
end

--debug purposes
function module:returneverything()
    return self.Components
end

return module