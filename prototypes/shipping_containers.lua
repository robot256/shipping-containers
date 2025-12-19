
local container_minimap = {
  filename = "__shipping-containers__/graphics/entity/container-minimap-representation.png",
  size = 26,
  scale = 0.4,
}
local container_selected_minimap = {
  filename = "__shipping-containers__/graphics/entity/container-selected-minimap-representation.png",
  size = 26,
  scale = 0.4,
}

local function copy_icons(source, target)
  if source.icons then
    target.icons = table.deepcopy(source.icons)
    target.icon = nil
    target.icon_size = source.icon_size
  elseif source.icon then
    target.icons = nil
    target.icon = source.icon
    target.icon_size = source.icon_size
  else
    error("Why no icons in "..source.name.."?")
  end
end

-- Item subgroup for shipping-containers
data:extend{
  {
    type = "item-subgroup",
    name = "shipping-container",
    group = "logistics",
    order = "f[shipping-container]"
  },
}

-- Land-based container
local land_con = table.deepcopy(data.raw.car["car"])
land_con.name = "basic-shipping-container"
land_con.minable = {result=land_con.name, mining_time=1}
land_con.icons = {{icon="__shipping-containers__/graphics/icons/container_small.png", icon_size = 64}}
land_con.icon = nil
land_con.icon_size = nil
land_con.inventory_size = settings.startup["shipping-containers-inventory-size"].value
land_con.max_health = data.raw.container["steel-chest"].max_health*2
land_con.collision_box = {{-0.75, -0.75}, {0.75, 0.75}}
land_con.selection_box = {{-0.95, -0.95}, {0.95, 0.95}}
land_con.resistances = data.raw.container["steel-chest"].resistances

land_con.animation = {
  layers = {
    {
      direction_count = 1,
      filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
      priority = "extra-high",
      width = 64,
      height = 80,
      shift = util.by_pixel(-0.1875, 2),
      scale = 0.75
    },
    {
      direction_count = 1,
      filename = "__base__/graphics/entity/steel-chest/steel-chest-shadow.png",
      priority = "extra-high",
      width = 110,
      height = 46,
      shift = util.by_pixel(18.5, 13),
      draw_as_shadow = true,
      scale = 0.75
    }
  }
}

land_con.guns = nil
land_con.turret_animation = nil
land_con.turret_return_timeout = nil
land_con.turret_rotation_speed = nil

land_con.energy_source = {type="void"}
land_con.effectivity = 0
land_con.consumption = "0W"   --- Set to zero so the AAI Programmable Vehicles ignores shipping container weapons
land_con.rotation_speed = 0
land_con.has_belt_immunity = false
land_con.light = nil
land_con.light_animation = nil
land_con.weight = 100
land_con.allow_passengers = false
land_con.equipment_grid = nil
land_con.minimap_representation = container_minimap
land_con.selected_minimap_representation = container_selected_minimap
land_con.sound_no_fuel = nil
land_con.working_sound = nil

local land_con_item = {
  type = "item",
  name = land_con.name,
  place_result = land_con.name,
  icons = {{icon="__shipping-containers__/graphics/icons/container_small.png", icon_size = 64}},
  order = "d[basic-shipping-container]",
  stack_size = 10,
  subgroup = "shipping-container",
}

local land_con_recipe = {
  type = "recipe",
  name = land_con_item.name,
  results = {{type="item", name=land_con_item.name, amount=1}},
  energy_required = 30,
  ingredients = {
    { type="item", name="steel-plate", amount=10 },
    { type="item", name="steel-chest", amount=2 },
    { type="item", name="electronic-circuit", amount=4 },
  },
  requester_paste_multiplier = 2,
  enabled = false,
  always_show_made_in = true,
}

data:extend{land_con, land_con_item, land_con_recipe}


-- Technology to unlock stuff (all mixed together right now)
local con_tech = {
  type = "technology",
  name = "shipping-containers",
  effects = {
    { type = "unlock-recipe", recipe = land_con_recipe.name },
  },
  icon = "__shipping-containers__/graphics/icons/container.png",
  icon_size = 256,
  icon_mipmaps=1,
  order = "xz",
  prerequisites = { "steel-processing" },
  unit = {
    count = 50,
    time = 20,
    ingredients = {
      { "automation-science-pack", 1 },
      { "logistic-science-pack", 1 },
    }
  }
}
data:extend{con_tech}


if data.raw.container["se-cargo-rocket-cargo-pod"] then

  -- Space-compatible container
  local space_con = table.deepcopy(data.raw.car["car"])
  space_con.name = "se-space-shipping-container"
  space_con.minable = {result=space_con.name, mining_time=1}
  copy_icons(data.raw.container["se-cargo-rocket-cargo-pod"], space_con)
  space_con.inventory_size = settings.startup["shipping-containers-inventory-size"].value
  space_con.max_health = data.raw.container["se-cargo-rocket-cargo-pod"].max_health
  space_con.collision_box = {{-0.75, -0.75}, {0.75, 0.75}}
  space_con.selection_box = {{-0.95, -0.95}, {0.95, 0.95}}
  space_con.resistances = data.raw.container["se-cargo-rocket-cargo-pod"].resistances

  space_con.animation = {
    layers = data.raw.container["se-cargo-rocket-cargo-pod"].picture.layers
  }
  for i=1,#space_con.animation.layers do
    space_con.animation.layers[i].direction_count = 1
  end

  space_con.guns = nil
  space_con.turret_animation = nil
  space_con.turret_return_timeout = nil
  space_con.turret_rotation_speed = nil

  space_con.energy_source = {type="void"}
  space_con.effectivity = 0
  space_con.consumption = "0W"   --- Set to zero so the AAI Programmable Vehicles ignores shipping container weapons
  space_con.rotation_speed = 0
  space_con.has_belt_immunity = false
  space_con.light = nil
  space_con.light_animation = nil
  space_con.weight = 150
  space_con.allow_passengers = false
  space_con.equipment_grid = nil
  space_con.minimap_representation = container_minimap
  space_con.selected_minimap_representation = container_selected_minimap
  space_con.sound_no_fuel = nil
  space_con.working_sound = nil


  local space_con_item =   {
    type = "item",
    name = space_con.name,
    place_result = space_con.name,
    icon = space_con.icon,
    icon_size = space_con.icon_size,
    order = "e[se-space-shipping-container]",
    stack_size = 10,
    subgroup = "shipping-container",
  }

  local space_con_recipe = {
    type = "recipe",
    name = space_con.name,
    results = {{type="item", name=space_con.name, amount=1}},
    energy_required = 30,
    ingredients = {
      { type="item", name="steel-plate", amount=10 },
      { type="item", name="electronic-circuit", amount=6 },
      { type="item", name="low-density-structure", amount=10 },
    },
    requester_paste_multiplier = 2,
    enabled = false,
    always_show_made_in = true,
  }

  data:extend{space_con, space_con_item, space_con_recipe}
  
  local space_con_tech = {
    type = "technology",
    name = "space-shipping-containers",
    effects = {
      { type = "unlock-recipe", recipe = space_con_recipe.name },
    },
    icons = {
      {
        icon = "__shipping-containers__/graphics/icons/container.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
      {
        icon = "__space-exploration-graphics__/graphics/technology/rocket-cargo-safety.png",
        icon_size = 128,
        scale = 1.25,
        shift = {48, 40},
        icon_mipmaps = 1,
      },
    },
    order = "xz",
    prerequisites = { "shipping-containers",
                      "se-rocket-launch-pad" },
    unit = {
      count = 50,
      time = 20,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
      }
    }
  }
  data:extend{space_con_tech}
  
end
