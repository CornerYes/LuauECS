local ECS = require(game.ReplicatedStorage.ECS)

local world = ECS.new()
local entity = world:newEntity()

world.Events.ComponentAdded.Event:Connect(function(entity, ComponentType)  
    print(world.Components[ComponentType])
end)

world.Events.ComponentRemoved.Event:Connect(function(entity, ComponentType)  
    print(world.Components[ComponentType])
end)

world:registerComponent("Health")

world:addComponent(entity, "Health", {
    Value = 100,
})

world:foreach({"Health"}, function(entityID)  
    print(entityID)
end)


