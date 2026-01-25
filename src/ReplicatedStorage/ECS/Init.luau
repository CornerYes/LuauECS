--!strict
local CommerceService = game:GetService("CommerceService")
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

function module.hasComponent(EntityID, ComponentType)
    return Components[ComponentType].sparse[EntityID]
end

function module.addComponent(EntityID, ComponentType, Component: any)
    if module.hasComponent(EntityID, ComponentType) then
        warn(tostring(EntityID).." already has "..ComponentType)
        return
    end

    local componentlist = Components[ComponentType]
    if not Components[ComponentType] then
        module.registerComponent(ComponentType)
    end
    
    table.insert(componentlist.data, Component)
    local index = #componentlist.data
    componentlist.sparse[EntityID] = index
    componentlist.dense[index] = EntityID
end

function module.removeComponent(EntityID, ComponentType)
    local componentlist = Components[ComponentType]
    print(componentlist)

    local index = componentlist.sparse[EntityID]
    local lastindex = #componentlist.dense
    local lastEntityID = componentlist.dense[lastindex]

    swaptable(componentlist.data, index, lastindex)
    swaptable(componentlist.dense, index, lastindex)
    componentlist.sparse[lastEntityID] = index

    componentlist.sparse[EntityID] = nil
    componentlist.dense[lastindex] = nil
    componentlist.data[lastindex] = nil
    print(componentlist)
end

function module.getAllEntities(...)
    
end

function module.returncomponent()
    return Components
end

return module