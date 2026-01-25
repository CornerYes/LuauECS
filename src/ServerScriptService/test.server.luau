
local ECS = require(game.ReplicatedStorage.ECS)

local world = ECS.new()

--create a new entity
local entity = world:newEntity()

--register a component
world:registerComponent("Health")

--add that component to an entity
world:addComponent(entity, "Health", {
    Value = 100,
})

--get all entities that has that component
local entities = world:queryentities("Health")

--loop through all entities
for i, EntityID in ipairs(entities) do
    --get the health component so that it can be modified
    local HealthComponent = world:getcomponent(EntityID, "Health")
    if HealthComponent then
        HealthComponent.Value = 0
    end
end
--removes that component from an entity
world:removeComponent(entity, "Health")