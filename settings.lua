data:extend({
  {
    type = "bool-setting",
    name = "shipping-containers-enable-belts",
    setting_type = "startup",
    default_value = true,
    order = "b",
  },
  {
    type = "bool-setting",
    name = "shipping-containers-modded-belts",
    setting_type = "startup",
    default_value = true,
    order = "c",
  },
  {
    type = "int-setting",
    name = "shipping-containers-inventory-size",
    setting_type = "startup",
    default_value = 96,
    minimum_value = 1,
    order = "a",
  }
})
