local ECS = require(game.ReplicatedStorage.ECS)

ECS.registerComponent("VehicleMove")

for i = 1, 10 do
    local test = ECS.newEntity()
	if math.random(1, 2) == math.random(1, 2) then
        local speed = math.random(1, 67)
        print(test)
		ECS.addComponent(test, "VehicleMove", {
			MoveSpeed = speed,
		})
	end
end




print(ECS.queryentities("VehicleMove"))