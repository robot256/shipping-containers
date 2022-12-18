
-- Make gates take longer to mine, so you can mine a belt off them
for name,gate in pairs(data.raw.gate) do
  if gate.minable then
    if gate.minable.mining_time < 0.75 then
      gate.minable.mining_time = 0.75
    end
  else
    log("Note: gate entity '"..name.."' is not minable!")
  end
end
