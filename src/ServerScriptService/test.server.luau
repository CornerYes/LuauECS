local ECS = require(game.ReplicatedStorage.ECS)

ECS.registerComponent("VehicleMove")

for i = 1, 10 do
    local test = ECS.newEntity()
	if math.random(1, 2) == 1 then
		ECS.addComponent(test, "VehicleMove", {
			MoveSpeed = math.random(1, 67),
		})
	end
end



print(ECS.returncomponent())