if settings.startup["shipping-containers-enable-belts"].value then
  local TECH_NAME = "gate-belts"
  local VANILLA_BELTS = {
    ["transport-belt"]=true,
    ["fast-transport-belt"]=true,
    ["express-transport-belt"]=true,
    ["turbo-transport-belt"]=true,
    ["se-space-transport-belt"]=true,
  }

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
        },
        {
          icon = "__base__/graphics/icons/gate.png",
          icon_size = 64,
          scale = 1.0,
          shift = {0, -24},
          tint = {a=1, b=0.2, g=1, r=1},
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
    belt.collision_mask = {layers={transport_belt=true}}
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
      results = {{type="item", name=belt.name, amount=1}},
      energy_required = 10,
      enabled = false,
      always_show_made_in = true,
    }
    if belt.related_underground_belt then
      belt_recipe.ingredients = {
        { type="item", name = belt.related_underground_belt, amount = 2 },
        { type="item", name = "advanced-circuit", amount = 2 },
      }
      belt.related_underground_belt = nil
    else
      belt_recipe.ingredients = {
        { type="item", name = source_name, amount = 2 },
        { type="item", name = "iron-gear-wheel", amount = 10 },
        { type="item", name = "advanced-circuit", amount = 2 },
      }
    end
    if not belt.icons then
      belt.icons = {{icon=belt.icon, icon_size=belt.icon_size}}
      belt.icon = nil
      belt.icon_size = nil
    end
    if not belt_item.icons then
      belt_item.icons = {{icon=belt_item.icon, icon_size=belt_item.icon_size}}
      belt_item.icon = nil
      belt_item.icon_size = nil
    end
    local gate_icon = data.raw.gate["gate"].icons or {{icon=data.raw.gate["gate"].icon, icon_size=data.raw.gate["gate"].icon_size or 64}}
    
    --log(serpent.line(belt_item.icons))
    --log(serpent.line(belt.icons))
    --log(serpent.line(gate_icon))
    belt.icons = util.combine_icons(belt.icons, gate_icon, {tint={1,1,1,1}, scale=0.6, shift={7,-7}}, 64)
    belt_item.icons = util.combine_icons(belt_item.icons, gate_icon, {tint={1,1,1,1}, scale=0.6, shift={7,-7}}, 64)

    data:extend{belt, belt_item, belt_recipe}
    -- Add all belts to the same technology (eventually make this a script unlock?)
    table.insert(data.raw.technology[TECH_NAME].effects, {type="unlock-recipe", recipe=belt_recipe.name})

  end


  -- Make a gate-crossing variant for every transport belt
  local belts = {}
  for name,belt in pairs(data.raw["transport-belt"]) do
    if (settings.startup["shipping-containers-modded-belts"].value or VANILLA_BELTS[name]) and belt.minable and not belt.hidden then
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
