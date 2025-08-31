-- Ore conversion recipe management for runtime configuration changes
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

-- Function to create conversion recipe for Space Age ores
local function create_space_age_ore_recipe(ore_name)
    local recipe_name = "alien-ore-to-" .. ore_name
    -- Skip if recipe already exists
    if data.raw.recipe[recipe_name] then
        return
    end

    data:extend({
        {
            type = "recipe",
            name = recipe_name,
            enabled = true,
            energy_required = 20,
            ingredients = { { type = "item", name = "artifact-ore", amount = 2 } },
            results = { { type = "item", name = ore_name, amount = 1 } },
            auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value,
            localised_name = {
                "?",  -- fallback option
                {"recipe-name.alien-ore-conversion-template", {"item-name." .. ore_name}},
                {"recipe-name.alien-ore-conversion-template", ore_name}
            }
        }
    })
end

-- Function to create Space Age ore conversion recipes based on settings
local function create_space_age_ore_recipes()
    -- Vulcanus ores
    if settings.startup["alien-module-vulcanus-ore-conversion"].value then
        for ore_name, _ in pairs(ore_conversions.vulcanus_ores) do
            if data.raw.item[ore_name] then
                create_space_age_ore_recipe(ore_name)
            end
        end
    end

    -- Fulgora scrap
    if settings.startup["alien-module-fulgora-scrap-conversion"].value then
        for ore_name, _ in pairs(ore_conversions.fulgora_scrap_ores) do
            if data.raw.item[ore_name] then
                create_space_age_ore_recipe(ore_name)
            end
        end
    end
end

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

-- Ore conversion recipe definitions
if (settings.startup["alien-module-nauvis-ore-conversion"].value) then
	-- make iron ore from alien ore --
	data:extend({
		{
			type = "recipe",
			name = "alien-ore-to-iron-ore",
			enabled = true,
			energy_required = 10,
			ingredients = { { type = "item", name = "artifact-ore", amount = 1 } },
			results = { { type = "item", name = "iron-ore", amount = 5 } },
			auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value
		}
	})

	-- make copper ore from alien ore --
	data:extend({
		{
			type = "recipe",
			name = "alien-ore-to-copper-ore",
			enabled = true,
			energy_required = 10,
			ingredients = { { type = "item", name = "artifact-ore", amount = 1 } },
			results = { { type = "item", name = "copper-ore", amount = 5 } },
			auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value
		}
	})

	-- make stone ore from alien ore --
	data:extend({
		{
			type = "recipe",
			name = "alien-ore-to-stone",
			enabled = true,
			energy_required = 10,
			ingredients = { { type = "item", name = "artifact-ore", amount = 1 } },
			results = { { type = "item", name = "stone", amount = 5 } },
			auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value
		}
	})

	-- make uranium ore from alien ore --
	data:extend({
		{
			type = "recipe",
			name = "alien-ore-to-uranium-ore",
			enabled = true,
			energy_required = 20,
			ingredients = { { type = "item", name = "artifact-ore", amount = 2 } },
			results = { { type = "item", name = "uranium-ore", amount = 1 } },
			auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value
		}
	})

	-- make coal from alien ore --
	data:extend({
		{
			type = "recipe",
			name = "alien-ore-to-coal",
			enabled = true,
			energy_required = 10,
			ingredients = { { type = "item", name = "artifact-ore", amount = 1 } },
			results = { { type = "item", name = "coal", amount = 5 } },
			auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value
		}
	})
end

-- if bobs enemies is enabled, make conversion of alien artifacts possible
if data.raw["item"]["alien-artifact"] ~= nil then
	data:extend({
		{
			type = "recipe",
			name = "alien-artifact-to-ore",
			enabled = true,
			energy_required = 25,
			ingredients = { { type = "item", name = "alien-artifact", amount = 1 }, { type = "item", name = "stone", amount = 5 }, { type = "item", name = "iron-ore", amount = 5 } },
			results = { { type = "item", name = "artifact-ore", amount = 5 } }
		}
	})
end

-- Create Space Age ore recipes
create_space_age_ore_recipes()

-- Expose the creation function for external use
ore_conversions.create_space_age_ore_recipe = create_space_age_ore_recipe

return ore_conversions