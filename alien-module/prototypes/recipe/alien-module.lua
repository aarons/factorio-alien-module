-- make alien plate from alien ore --
data:extend({
	{
		type = "recipe",
		name = "alien-plate",
		category = "smelting",
		enabled = false,
		energy_required = 10,
		ingredients = { { type = "item", name = "artifact-ore", amount = 1 } },
		results = { { type = "item", name = "alien-plate", amount = 1 } },
		allowed_module_categories = { "productivity", "efficiency", "speed" },
		allow_productivity = true,
		allow_quality = true
	}
})


data:extend({
	{
		type = "recipe",
		name = "alien-accumulator",
		energy_required = 10,
		enabled = false,
		ingredients = {
			{ type = "item", name = "alien-plate", amount = 5 },
			{ type = "item", name = "battery", amount = 10 }
		},
		results = { { type = "item", name = "alien-accumulator", amount = 1 } }
	}
})

data:extend({
	{
		type = "recipe",
		name = "alien-solarpanel",
		enabled = false,
		energy_required = 8,
		ingredients = { { type = "item", name = "alien-plate", amount = 10 }, { type = "item", name = "electronic-circuit", amount = 10 }, { type = "item", name = "steel-plate", amount = 5 } },
		results = { { type = "item", name = "alien-solarpanel", amount = 1 } }
	}
})

data:extend({
	{
		type = "recipe",
		name = "alien-mining-drill",
		enabled = true,
		energy_required = 8,
		ingredients = { { type = "item", name = "alien-plate", amount = 50 }, { type = "item", name = "electronic-circuit", amount = 10 }, { type = "item", name = "iron-gear-wheel", amount = 10 } },
		results = { { type = "item", name = "alien-mining-drill", amount = 1 } }
	}
})

-- alien-module-1 from alien-plate --
data:extend({
	{
		type = "recipe",
		name = "alien-module-1",
		enabled = false,
		energy_required = 20,
		results = { { type = "item", name = "alien-module-1", amount = 1 } },
		ingredients = {
			{ type = "item", name = "alien-plate", amount = 50 }
		},
		allow_productivity = true,
		allow_quality = true
	},
})

-- alien-fuel --

data:extend({
	{
		type = "recipe",
		name = "alien-fuel",
		enabled = false,
		energy_required = 5,
		results = { { type = "item", name = "alien-fuel", amount = 1 } },
		ingredients = {
			{ type = "item", name = "artifact-ore", amount = 2 },
			{ type = "item", name = "coal", amount = 10 }
		},
		allow_productivity = true,
		allow_quality = true
	},
})

for i = 1, 100, 1 do
	data:extend({
		{
			type = "recipe",
			name = "alien-hyper-module-" .. i,
			enabled = false,
			hidden_in_factoriopedia = true,
			energy_required = i,
			results = { { type = "item", name = "alien-hyper-module-" .. i, amount = 1 } },
			ingredients = {
				{ type = "item", name = "alien-plate", amount = 20 * i }
			},
			allowed_module_categories = { "productivity", "efficiency", "speed" },
			allow_productivity = true,
			allow_quality = true
		},
	})

	--adds the electronics catagory to modules if spaceage is installed
	if mods["space-age"] then
		data.raw["recipe"]["alien-hyper-module-" .. i].category = "electronics"
	end

	-- allows quality modules if quality is installed
	if mods["quality"] then
		data.raw["recipe"]["alien-hyper-module-" .. i].allowed_module_categories = { "productivity", "efficiency", "speed", "quality", "alien-module" }
		data.raw["recipe"]["alien-plate"].allowed_module_categories = { "productivity", "efficiency", "speed", "quality", "alien-module" }
	end
end
