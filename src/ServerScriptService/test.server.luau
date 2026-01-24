
local ECS = require(game.ReplicatedStorage.ECS)

local tank = ECS.newEntity()

ECS.registerComponent("VehicleMove")
ECS.addComponent(tank, "VehicleMove", {
    MoveSpeed = 1,
})


--get all entities that has this componenet

local Entities = ECS.getAllEntities("VehicleMove")
