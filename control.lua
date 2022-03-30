local check_offshore_pump = function(entity, player_index)
	local name = nil
	local ghost = false

	name = entity.name
	if name == "entity-ghost" then
		ghost = true
		name = entity.ghost_name
	end

	if name == "offshore-pump" then
		local water_tiles = entity.surface.find_tiles_filtered({area = entity.bounding_box, collision_mask = { "water-tile" }})
		local ground_tiles = entity.surface.find_tiles_filtered({area = entity.bounding_box, collision_mask = { "ground-tile" }})
		local build = true

		for _, tile in pairs(ground_tiles) do
			build = build and tile.name == "landfill"
		end

		build = build or #water_tiles == 2

		if build == false then
			if ghost == true then
				entity.destroy()
			else
				if player_index then
					local player = game.get_player(player_index)
					player.insert({ name = name, count = 1 })
					entity.destroy()
				else
					entity.order_deconstruction(entity.force)
				end
			end
		end
	end
end

script.on_event(defines.events.on_built_entity, function (event) check_offshore_pump(event.created_entity, event.player_index) end)
script.on_event(defines.events.on_robot_built_entity, function (event) check_offshore_pump(event.created_entity, nil) end)
script.on_event(defines.events.on_cancelled_deconstruction, function (event) check_offshore_pump(event.entity, nil) end)
