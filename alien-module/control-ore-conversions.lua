-- Runtime ore conversion recipe management for configuration changes
local ore_conversions = {}

-- Ore categorization data
ore_conversions.nauvis_ores = {
    ["iron-ore"] = true,
    ["copper-ore"] = true,
    ["stone"] = true,
    ["coal"] = true,
    ["uranium-ore"] = true
}

ore_conversions.vulcanus_ores = {
    ["calcite"] = true,
    ["tungsten-ore"] = true
}

ore_conversions.fulgora_scrap_ores = {
    ["scrap"] = true
}

-- Function to update ore conversion recipe states based on current settings
function ore_conversions.update_recipes(event)
	-- Only process if startup settings have changed
	if not event or not event.mod_changes then
		return
	end

	-- Check each force and update their recipes
	for _, force in pairs(game.forces) do
		-- Find all ore conversion recipes for this force
		for recipe_name, recipe in pairs(force.recipes) do
			if string.match(recipe_name, "^alien%-ore%-to%-") then
				local ore_name = string.match(recipe_name, "^alien%-ore%-to%-(.+)$")
				if ore_name then
					local setting_name
					if ore_conversions.nauvis_ores[ore_name] then
						setting_name = "alien-module-nauvis-ore-conversion"
					elseif ore_conversions.vulcanus_ores[ore_name] then
						setting_name = "alien-module-vulcanus-ore-conversion"
					elseif ore_conversions.fulgora_scrap_ores[ore_name] then
						setting_name = "alien-module-fulgora-scrap-conversion"
					elseif string.find(string.lower(ore_name), "scrap") then
						setting_name = "alien-module-modded-scrap-conversion"
					else
						setting_name = "alien-module-modded-ore-conversion"
					end
					local should_be_enabled = settings.startup[setting_name] and settings.startup[setting_name].value

					if should_be_enabled ~= recipe.enabled then
						recipe.enabled = should_be_enabled
					end
				end
			end
		end
	end
end

return ore_conversions