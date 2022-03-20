

-- Land-based container
local land_con = table.deepcopy(data.raw.car["car"])
land_con.name = "basic-shipping-container"
land_con.minable.result = land_con.name

land_con.icon = data.raw.container["steel-chest"].icon
land_con.icon_size = data.raw.container["steel-chest"].icon_size
land_con.inventory_size = data.raw.container["steel-chest"].inventory_size*2
land_con.max_health = data.raw.container["steel-chest"].max_health*2
land_con.collision_box = {{-0.95, -0.95}, {0.95, 0.95}}
land_con.selection_box = {{-0.95, -0.95}, {0.95, 0.95}}
land_con.resistances = data.raw.container["steel-chest"].resistances

land_con.animation = {
  layers = {
    {
      direction_count = 1,
      filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
      priority = "extra-high",
      width = 32,
      height = 40,
      scale = 1.5,
      shift = util.by_pixel(0, -0.5),
      hr_version =
      {
        direction_count = 1,
        filename = "__base__/graphics/entity/steel-chest/hr-steel-chest.png",
        priority = "extra-high",
        width = 64,
        height = 80,
        shift = util.by_pixel(-0.25, -0.5),
        scale = 0.75
      }
    },
    {
      direction_count = 1,
      filename = "__base__/graphics/entity/steel-chest/steel-chest-shadow.png",
      priority = "extra-high",
      width = 56,
      height = 22,
      scale = 1.5,
      shift = util.by_pixel(12*1.5, 7.5*1.5),
      draw_as_shadow = true,
      hr_version =
      {
        direction_count = 1,
        filename = "__base__/graphics/entity/steel-chest/hr-steel-chest-shadow.png",
        priority = "extra-high",
        width = 110,
        height = 46,
        shift = util.by_pixel(12.25*1.5, 8*1.5),
        draw_as_shadow = true,
        scale = 0.75
      }
    }
  }
}

land_con.guns = nil
land_con.turret_animation = nil
land_con.turret_return_timeout = nil
land_con.turret_rotation_speed = nil

land_con.energy_source = {type="void"}
land_con.effectivity = 0
land_con.rotation_speed = 0
land_con.has_belt_immunity = false
land_con.light = nil
land_con.light_animation = nil
land_con.weight = 250
land_con.allow_passengers = false
land_con.equipment_grid = nil
--land_con.minimap-representation=

local land_con_item =   {
  type = "item",
  name = land_con.name,
  place_result = land_con.name,
  icon = "__shipping-containers__/graphics/icons/container_small.png",
  icon_size = 64,
  order = "d[shipping-container]",
  stack_size = 10,
  subgroup = "transport",
}

local land_con_recipe = {
  type = "recipe",
  name = land_con_item.name,
  result = land_con_item.name,
  energy_required = 30,
  ingredients = {
    { "steel-plate", 10 },
    { "steel-chest", 2 },
    { "electronic-circuit", 4 },
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
  space_con.minable.result = space_con.name

  space_con.icon = data.raw.container["se-cargo-rocket-cargo-pod"].icon
  space_con.icon_size = data.raw.container["se-cargo-rocket-cargo-pod"].icon_size
  space_con.inventory_size = data.raw.container["steel-chest"].inventory_size*2
  space_con.max_health = data.raw.container["se-cargo-rocket-cargo-pod"].max_health
  space_con.collision_box = {{-0.95, -0.95}, {0.95, 0.95}}
  space_con.selection_box = {{-0.95, -0.95}, {0.95, 0.95}}
  space_con.resistances = data.raw.container["se-cargo-rocket-cargo-pod"].resistances

  space_con.animation = {
    layers = data.raw.container["se-cargo-rocket-cargo-pod"].picture.layers
  }
  for i=1,#space_con.animation.layers do
    space_con.animation.layers[i].direction_count = 1
    if space_con.animation.layers[i].hr_version then
      space_con.animation.layers[i].hr_version.direction_count = 1
    end
  end

  space_con.guns = nil
  space_con.turret_animation = nil
  space_con.turret_return_timeout = nil
  space_con.turret_rotation_speed = nil

  space_con.energy_source = {type="void"}
  space_con.effectivity = 0
  space_con.rotation_speed = 0
  space_con.has_belt_immunity = false
  space_con.light = nil
  space_con.light_animation = nil
  space_con.weight = 250
  space_con.allow_passengers = false
  space_con.equipment_grid = nil
  --space_con.minimap-representation=

  local space_con_item =   {
    type = "item",
    name = space_con.name,
    place_result = space_con.name,
    icon = space_con.icon,
    icon_size = space_con.icon_size,
    order = "d[shipping-container-space]",
    stack_size = 10,
    subgroup = "transport",
  }

  local space_con_recipe = {
    type = "recipe",
    name = space_con.name,
    result = space_con.name,
    energy_required = 30,
    ingredients = {
      { "steel-plate", 6 },
      { "electronic-circuit", 4 },
      { "iron-chest", 4 }
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
