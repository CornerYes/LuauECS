--!strict
local module = {}

local nextID = 0

local Components: {[string]: {[number]: any}} = {}
local Entities: {[number]: {[string]: any}} = {}

function module.newEntity()
    nextID += 1
    Entities[nextID] = {}
    return nextID
end

function module.registerComponent(ComponentType)
    Components[ComponentType] = {}
end

function module.addComponent(EntityID, ComponentType, Component)
    if not Components[ComponentType] then
        module.registerComponent(ComponentType)
    end

    Components[ComponentType][EntityID] = Component
    Entities[EntityID][ComponentType] = true
end

function module.getAllEntities(...)
    local Componentsrequired = table.pack(...)
    local entitiesCaught = {}
    for EntityID, ComponentList in pairs(Entities) do
        local hasall = true
        for _, ComponentNeed in ipairs(Componentsrequired) do
            if not ComponentList[ComponentNeed] then
                hasall = false
                break
            end
        end

        if hasall == true then
            table.insert(entitiesCaught, EntityID)
        end
    end
    return entitiesCaught
end

return module