if settings.startup["shipping-containers-enable-belts"].value
  local TECH_NAME = "gate-belts"
  local VANILLA_BELTS = {"transport-belt", "fast-transport-belt", "express-transport-belt", "se-space-transport-belt"}

  -- Technology to unlock stuff (all mixed together right now)
  local belt_tech = {
      type = "technology",
      name = TECH_NAME,
      effects = {
      },
      icons = {
        {
          icon = "__base__/graphics/icons/transport-belt.png",
          icon_size = 64,
          scale = 1.5,
          tint = {a=1, b=0.5, g=0.5, r=0.5},
          icon_mipmaps = 4,
        },
        {
          icon = "__base__/graphics/icons/gate.png",
          icon_size = 64,
          scale = 1.0,
          shift = {0, -24},
          tint = {a=1, b=0.2, g=1, r=1},
          icon_mipmaps = 4,
        }
      },
      order = "zz",
      prerequisites = { "logistics-2", "gate" },
      unit = {
        count = 100,
        time = 20,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack", 1 },
        }
      },
    }
  data:extend{belt_tech}

  -- Item subgroup for gate-belts
  data:extend{
    {
      type = "item-subgroup",
      name = "gate-belt",
      group = "logistics",
      order = "b[belt]-g"
    },
  }

  local function applyGateBeltIcon(belt, gate)
    if belt.icons then
      local gate_scale = (gate.icon_size/belt.icons[1].icon_size)*0.5*(belt.icons[1].scale or 32/belt.icons[1].icon_size)
      table.insert(belt.icons, {
          icon = gate.icon,
          icon_size = gate.icon_size,
          icon_mipmaps = gate.icon_mipmaps,
          scale = gate_scale,
          shift = {gate.icon_size*gate_scale*0.5, -gate.icon_size*gate_scale*0.5}
        })
    else
      local gate_scale = (gate.icon_size/belt.icon_size)*0.5*(32/belt.icon_size)
      belt.icons = {
        {
          icon = belt.icon,
          icon_size = belt.icon_size,
          icon_mipmaps = belt.icon_mipmaps,
          scale = 32/belt.icon_size
        },
        {
          icon = gate.icon,
          icon_size = gate.icon_size,
          icon_mipmaps = gate.icon_mipmaps,
          scale = gate_scale,
          shift = {gate.icon_size*gate_scale*0.5, -gate.icon_size*gate_scale*0.5}
        },
      }
      belt.icon = nil
      belt.icon_size = nil
      belt.icon_mipmaps = nil
    end
  end

  local function makeGateBelt(new_name, source_name)
    local belt = table.deepcopy(data.raw["transport-belt"][source_name])
    if not belt then
      log("ERROR: Could not find transport-belt:"..source_name)
      return
    end
    log("Creating gate-crossing belt '"..new_name.."' based on '"..source_name.."'.")
    belt.name = new_name
    belt.localised_name = {"shipping-container.gate-belt-name", "__ENTITY__"..source_name.."__"}
    belt.localised_description = {"shipping-container.gate-belt-description"}
    belt.minable.result = belt.name
    belt.selection_priority = 55
    belt.collision_mask = {"transport-belt-layer"}
    belt.next_upgrade = nil
    belt.fast_replaceable_group = "gate-belt"

    local belt_item = table.deepcopy(data.raw.item[source_name])
    belt_item.name = belt.name
    belt_item.place_result = belt.name
    belt_item.localised_name = belt.localised_name
    belt_item.localised_description = belt.localised_description
    belt_item.subgroup = "gate-belt"

    local belt_recipe = {
      type = "recipe",
      name = belt.name,
      category = "crafting",
      result = belt.name,
      energy_required = 10,
      result_count = 1,
      enabled = false,
      always_show_made_in = true,
    }
    if belt.related_underground_belt then
      belt_recipe.ingredients = {
        { name = belt.related_underground_belt, amount = 2 },
        { name = "advanced-circuit", amount = 2 },
      }
      belt.related_underground_belt = nil
    else
      belt_recipe.ingredients = {
        { name = source_name, amount = 2 },
        { name = "iron-gear-wheel", amount = 10 },
        { name = "advanced-circuit", amount = 2 },
      }
    end

    applyGateBeltIcon(belt, data.raw.gate["gate"])
    applyGateBeltIcon(belt_item, data.raw.gate["gate"])

    data:extend{belt, belt_item, belt_recipe}
    -- Add all belts to the same technology (eventually make this a script unlock?)
    table.insert(data.raw.technology[TECH_NAME].effects, {type="unlock-recipe", recipe=belt_recipe.name})

  end


  -- Make a gate-crossing variant for every transport belt
  local belts = {}
  for name,belt in pairs(data.raw["transport-belt"]) do
    if settings.startup["shipping-containers-modded-belts"].value or VANILLA_BELTS[name] then
      belts[#belts+1] = name
    end
  end
  for i=1,#belts do
    local found = 0
    local new_name, found = string.gsub(belts[i], "transport%-belt", "gate-belt")
    if found > 0 then
      makeGateBelt(new_name, belts[i])
    end
  end

end
