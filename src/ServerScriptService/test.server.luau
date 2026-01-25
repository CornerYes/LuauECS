
local ECS = require(game.ReplicatedStorage.ECS)

--create a new entity
local entity = ECS.newEntity()

--register a component
ECS.registerComponent("Health")

--add that component to an entity
ECS.addComponent(entity, "Health", {
    Value = 100,
})

--get all entities that has that component
local entities = ECS.queryentities("Health")

--loop through all entities
for i, EntityID in ipairs(entities) do
    --get the health component so that it can be modified
    local HealthComponent = ECS.getcomponent(EntityID, "Health")
    if HealthComponent then
        HealthComponent.Value = 0
    end
end
--removes that component from an entity
ECS.removeComponent(entity, "Health")