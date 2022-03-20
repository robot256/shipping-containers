
require("util")

local function isGateBeltValid(entity)
  -- If marked for deconstruction, don't worry
  if not entity.to_be_deconstructed() then
    -- Check if a gate is already there
    local nearby = entity.surface.find_entities_filtered{position=entity.position, type="gate"}
    if not next(nearby) then
      -- Check if a gate ghost is waiting to be built
      local nearby_ghost = entity.surface.find_entities_filtered{position=entity.position, ghost_type="gate"}
      if not next(nearby_ghost) then
        -- This gate belt is orphaned!
        return false
      end
    end
  end
  return true
end


----------
-- Make sure gate-belt is only built on top of existing gate or gate ghost
local function OnBuilt(event)
  local entity = event.created_entity or event.entity or event.destination
  
  -- Check if a gate is already there
  local nearby = entity.surface.find_entities_filtered{position=entity.position, type="gate"}
  if not next(nearby) then
    -- Check if a gate ghost is waiting to be built
    local nearby_ghost = entity.surface.find_entities_filtered{position=entity.position, ghost_type="gate"}
    if not next(nearby_ghost) then
      remote.call("space-exploration", "cancel_entity_creation", {entity=entity, player_index=event.player_index, message={"shipping-container.gate-belt-cancel-placement"}}, event)
    end
  end
end


-- When gate gets mined, make sure belt under it is also mined, marked for deconstruction or spilled onto ground
local function OnMined(event)
  game.print(event.name)
  local entity = event.entity or event.ghost
  local surface = entity.surface
  local position = entity.position
  
  local belts = surface.find_entities_filtered{position=entity.position, type="transport-belt"}
  if belts and belts[1] and global.gateBeltTypes[belts[1].name] then
    local belt = belts[1]
    if not belt.to_be_deconstructed() then
      if event.player_index then
        -- Gate was mined by player. Try to give back to player.
        remote.call("space-exploration", "cancel_entity_creation", {entity=belt, player_index=event.player_index, message={"shipping-container.gate-belt-also-mined", belt.localised_name}}, event)
      elseif event.robot then
        -- Gate was mined by robot. Mark belt for deconstruction by same force.
        belt.order_deconstruction(event.robot.force)
      elseif belt.prototype.items_to_place_this and belt.prototype.items_to_place_this[1] then
        -- Neither player nor robot mined, so this is weird. Spill stack.
        surface.spill_item_stack(
            position, 
            {name=belt.prototype.items_to_place_this and belt.prototype.items_to_place_this[1], count=1},
            true,  -- loot
            nil,   -- no deconstruction
            false  -- no items on belts
          )
      end
    end
  end
  
end

-- When gate is destroyed (not mined), destroy belt underneath it.
local function OnDestroyed(event)
  local entity = event.entity
  local surface = entity.surface
  local position = entity.position
    
  local found = surface.find_entities_filtered{position=entity.position, type="transport-belt"}
  if found and found[1] and global.gateBeltTypes[found[1].name] then
    local belt = found[1]
    if not belt.to_be_deconstructed() then
      surface.create_entity{
        name = "flying-text",
        position = position,
        text = {"shipping-container.gate-belt-destroyed", belt.localised_name},
      }
      belt.destroy()
    end
  end
end


-- When gate is marked for deconstruction, also mark belt
local function OnMarked(event)
  local found = event.entity.surface.find_entities_filtered{position=event.entity.position, type="transport-belt"}
  if found and found[1] and global.gateBeltTypes[found[1].name] then
    local belt = found[1]
    if event.player_index then
      local player = game.players[event.player_index]
      belt.order_deconstruction(player.force, player)
    else
      -- Find what force deconstructed the gate
      for _,force in pairs(game.forces) do
        if belt.is_registered_for_deconstruction(force) then
          belt.order_deconstruction(force)
          break
        end
      end
      -- Force unknown, assume the owner of the belt
      if not belt.to_be_deconstructed() then
        belt.order_deconstruction(belt.force)
      end
    end
  end
end

-- When deconstruction of belt or gate is cancelled, spill belt item if no gate
local function OnCancelled(event)
  local entity = event.entity
  local surface = entity.surface
  local force = (event.player_index and game.players[event.player_index].force)
          
  if entity.type == "gate" then
    -- gate deconstruction was cancelled
    -- cancel deconstruction of belt underneath
    local found = surface.find_entities_filtered{position=entity.position, type="transport-belt"}
    if found and found[1] and global.gateBeltTypes[found[1].name] then
      local belt = found[1]
      if belt.to_be_deconstructed() then
        belt.cancel_deconstruction()
      end
    end
  elseif global.gateBeltTypes[entity.name] then
    -- belt deconstruction cancelled
    -- cancel gate deconstruction
    local found = surface.find_entities_filtered{position=entity.position, type="gate"}
    if found and found[1] then
      local gate = found[1]
      if gate.to_be_deconstructed() then
        gate.cancel_deconstruction(force or gate.force)
      end
    else
      -- No gate at all, see if there is a gate ghost
      local ghosts = surface.find_entities_filtered{position=entity.position, ghost_type="gate"}
      if not ghosts or not ghosts[1] then
        local belt = entity
        -- no gate ghost
        local spilled
        if belt.prototype.items_to_place_this and belt.prototype.items_to_place_this[1] then
          spilled = surface.spill_item_stack(
              position, 
              {name=belt.prototype.items_to_place_this and belt.prototype.items_to_place_this[1], count=1},
              true,  -- loot
              force,
              false  -- no items on belts
            )
        end
        if not spilled or not next(spilled) then
          -- could not spill item
          surface.create_entity{
            name = "flying-text",
            position = position,
            text = {"shipping-container.gate-belt-destroyed", belt.localised_name},
          }
        end
        belt.destroy()
        
      end
    end
  end
end


--[[
-- Blueprint the doors correctly:
--   BELT is properly converted to PLACE.  Need to delete GATE from on top of it.

function FixBlueprints(e)
  -- Handle both Copy and Blueprint operations
  local player = game.get_player(e.player_index)
  local stack = player.blueprint_to_setup
  if not (stack and stack.valid_for_read) then
    stack = player.cursor_stack
    if not (stack and stack.valid_for_read and stack.is_blueprint) then
      return
    end
  end

  -- Find all the loading-belt entities and change them to loading-doors
  local bp_entities = stack.get_blueprint_entities()
  local doors = {}
  if bp_entities and next(bp_entities) then
    local changed = false
    for _, bp_entity in pairs(bp_entities) do
      if bp_entity.name == BELT_NAME then
        bp_entity.name = PLACE_NAME
        table.insert(doors, bp_entity.position)
        changed = true
      end
    end
    game.print("Found doors at positions: "..serpent.block(doors))
    
    if(changed) then
      -- Remove all the gates placed above the loading-belts
      for i, bp_entity in pairs(bp_entities) do
        if bp_entity.name == GATE_NAME then
          for k, door_pos in pairs(doors) do
            if door_pos.x == bp_entity.position.x and door_pos.y == bp_entity.position.y then
              game.print("Removing gate at "..tostring(door_pos.x)..","..tostring(door_pos.y))
              bp_entities[i] = nil
              doors[k] = nil
              break
            end
          end
        end
      end
      stack.set_blueprint_entities(bp_entities)
    end
  end
end

script.on_event(defines.events.on_player_configured_blueprint, FixBlueprints)
script.on_event(defines.events.on_player_setup_blueprint, FixBlueprints)
--]]

-----------
-- Initialization
-----------
local function InitEvents()
  log("Entering InitEvents")
  if not global.gateBeltTypes then
    log("No globals")
    return
  end
  local belt_filters = {}
  for name,_ in pairs(global.gateBeltTypes) do
    table.insert(belt_filters, {filter="name", name=name, mode="or"})
  end
  script.on_event(defines.events.on_built_entity, OnBuilt, belt_filters)
  script.on_event(defines.events.on_robot_built_entity, OnBuilt, belt_filters)
  script.on_event(defines.events.on_entity_cloned, OnBuilt, belt_filters)
  script.on_event(defines.events.script_raised_built, OnBuilt, belt_filters)
  script.on_event(defines.events.script_raised_revive, OnBuilt, belt_filters)


  local gate_filters = {
      {filter="type", type="gate"},
      {filter="ghost_type", type="gate", mode="or"}
    }
  script.on_event(defines.events.on_player_mined_entity, OnMined, gate_filters)
  script.on_event(defines.events.on_robot_mined_entity, OnMined, gate_filters)
  script.on_event(defines.events.on_entity_died, OnDestroyed, gate_filters)
  script.on_event(defines.events.script_raised_destroy, OnDestroyed, gate_filters)
  script.on_event(defines.events.on_pre_ghost_deconstructed, OnMined, gate_filters)
  
  script.on_event(defines.events.on_marked_for_deconstruction, OnMarked, gate_filters)
  
  local gate_belt_filters = util.table.deepcopy(belt_filters)
  table.insert(gate_belt_filters, {filter="type", type="gate", mode="or"})
  script.on_event(defines.events.on_cancelled_deconstruction, OnCancelled, gate_belt_filters)
  
end

local function InitGlobalsAndEvents()
  log("Entering InitGlobals")
  global.gateBeltTypes = {}
  
  for name,belt in pairs(game.get_filtered_entity_prototypes{{filter="type", type="transport-belt"}}) do
    if name:match("gate%-belt") then
      log("Found Gate Belt '"..name.."'")
      global.gateBeltTypes[name] = true
    end
  end
  
  InitEvents()

end

script.on_load(InitEvents)
script.on_init(InitGlobalsAndEvents)
script.on_configuration_changed(InitGlobalsAndEvents)
