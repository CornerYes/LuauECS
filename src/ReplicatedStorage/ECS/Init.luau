--!strict
local module = {}
local nextID = 0

type componentsparse = {
	sparse: {number},
	dense: {[number]: number},
    data: {[number]: any}
}

local Components: {[string]: componentsparse} = {}

local function swaptable(tabletoswap, from, to)
	local todata = tabletoswap[to]
	tabletoswap[to] = tabletoswap[from]
	tabletoswap[from] = todata
end

function module.newEntity()
    nextID = nextID + 1
    return nextID
end

function module.registerComponent(ComponentType)
	Components[ComponentType] = {
		sparse = {},
        dense = {},
        data = {},
	}
end

function module.hasComponent(EntityID, ComponentType): boolean?
    if not Components[ComponentType] then
        return nil
    end
    return Components[ComponentType].sparse[EntityID] ~= nil
end

function module.addComponent(EntityID, ComponentType, Component: any)
    if module.hasComponent(EntityID, ComponentType) then
        warn(tostring(EntityID).." already has "..ComponentType)
        return
    end

    local componentlist = Components[ComponentType]
    if not componentlist then
        module.registerComponent(ComponentType)
        componentlist = Components[ComponentType]
    end
    
    table.insert(componentlist.data, Component)
    local index = #componentlist.data
    componentlist.sparse[EntityID] = index
    componentlist.dense[index] = EntityID
end

function module.removeComponent(EntityID, ComponentType)
    local componentlist = Components[ComponentType]
    if not componentlist then
        return
    end

    if not module.hasComponent(EntityID, ComponentType) then
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

function module.getcomponent(entityID, ComponentType): any?
    local componentList = Components[ComponentType]
    if componentList then
        local index = componentList.sparse[entityID]
        return componentList.data[index]
    end
    return nil
end

function module.queryentities(...)
    local result = {}
    local componentstofind = table.pack(...)
    local smallest = math.huge
    local Componentpicked = nil

    for i, componentType in ipairs(componentstofind) do
        if Components[componentType] then
            local amountOfEntities = #Components[componentType].dense
            if amountOfEntities < smallest then
                smallest = amountOfEntities
                Componentpicked = componentType
            end
        end
    end

    local ComponentList = Components[Componentpicked]

    for i = 1, #ComponentList.dense do
        local entityID = ComponentList.dense[i]
        local hasall = true

        for _, ComponentType in ipairs(componentstofind) do
            if ComponentType ~= Componentpicked then
                local Component = Components[ComponentType]
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

function module.returneverything()
    return Components
end

return module