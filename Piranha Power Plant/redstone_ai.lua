local npcAI = {redstone = {}}
local redstone = {}

local expandedDefines = require("expandedDefines")

-- Set this to false and the script will no longer stop NPCs from despawning. This will reduce lag in your level!
npcAI.redstone.disabledespawn = true

-- PISTONS:
-- Determines if a block is immovable by a piston
local immovableblock = table.map({})
npcAI.redstone.blockImmovable = function(b)
  if immovableblock[b.id] then
    return true
  end
end

-- Determines if an NPC is immovable by a piston
npcAI.redstone.npcImmovable = function(n)
  if (n and n.data and n.data.pistImmovable) or n.id == redstone.component.soundblock.id then
    return true
  end
end

npcAI.redstone.playerImmovable = function(p)
  if p:mem(0x4A, FIELD_BOOL) then
    return true
  end
end

-- Determines if a block is intangible
local intangibleBlock = table.map(expandedDefines.BLOCK_SEMISOLID..expandedDefines.BLOCK_SIZEABLE..expandedDefines.BLOCK_NONSOLID)
npcAI.redstone.blockIgnore = function(b)
  if intangibleBlock[b.id] then
    return true
  end
end

-- Determines if an NPC is intangible
npcAI.redstone.npcIgnore = function(n)
  if (n and n.data and n.data.pistIgnore) or n.id == redstone.component.dust.config.id or n:mem(0x12C, FIELD_WORD) ~= 0 then
    return true
  end
end

-- Determines if an player is intangible
npcAI.redstone.playerIgnore = function(p)
  return false
end

-- REAPER BLOCK:

-- Determines if the killed NPC had a soul
local soullessNPC = table.map({}) -- Add IDs of NPCs here to make them soulless!
npcAI.redstone.hasSoul = function(n)
  if not soullessNPC[n.id] then
    return true
  end
end


-- How to add your own NPC AI:

--[[

-- NPC_NAME
npcAI[NPC_ID] = {}
npcAI[NPC_ID].onTick = function(n, data)  -- n is the npc object, data is the n.data field
  -- You AI goes here
  -- data.power indicates if your NPC is powered
  -- use data.observ to interact with observers. If data.observ is true, then an observer will activate for as long as that field is true
  -- use data.observpower to control the power output of the observer. By default its 15
  -- set data.invspace and the NPC will now accept items from hoppers
  -- use data.inv to check the current inventory item
end
npcAI[NPC_ID].prime = function(n, data)  -- n is the npc object, data is the n.data field
  -- gets called the first time the NPC is called. Use to initialize variables for the NPC
  -- If a prime function is not defined, then the default prime function (def_prime) found below is used instead
end
]]



-- Bill Blaster
npcAI[21] = {}
npcAI[21].enabled = true
npcAI[21].onTick = function(n, data)
  if data.power > 0 and (data.powerPrev == 0 or n.ai1 > 25) then
    n.ai1 = 200
  end
  data.powerPrev = data.power
  data.power = 0
end

-- SMB3 Thwomp
npcAI[37] = {}
npcAI[37].enabled = true
npcAI[37].onTick = function(n, data)
  if data.power > 0 and n.ai1 ~= 2 then
    n.ai1 = 1
  end
  data.power = 0
end

-- Brown Donut Block
npcAI[46] = {}
npcAI[46].enabled = true
npcAI[46].onTick = function(n, data)
  if data.power > 0 then
    n.ai1 = 1
    n.ai3 = 30
  end
  data.power = 0
end

-- Green Yoshi
npcAI[95] = {}
npcAI[95].enabled = true
npcAI[95].onTick = function(n, data)
  if data.power > 7 and n.ai1 == 0 then
    n.ai1 = 1
    SFX.play(49)
  elseif data.power > 0 and data.power < 8 and n.ai1 == 1 then
      n.ai1 = 0
      SFX.play(49)
  end
  data.power = 0
end

-- Blue Yoshi
npcAI[98] = npcAI[95]

-- Yellow Yoshi
npcAI[99] = npcAI[95]

-- Red Yoshi
npcAI[100] = npcAI[95]

-- Black Yoshi
npcAI[148] = npcAI[95]

-- Purple Yoshi
npcAI[149] = npcAI[95]

-- Pink Yoshi
npcAI[150] = npcAI[95]

-- Rinka Block
npcAI[211] = {}
npcAI[211].enabled = true
npcAI[211].onTick = function(n, data)
  if data.power > 0 and (data.powerPrev == 0 or (n.ai1 > 25 and n.ai1 < 200)) then
    n.ai1 = 201
  end
  data.powerPrev = data.power
  data.power = 0
end

-- Red Donut Block
npcAI[212] = npcAI[46]

-- Cyan Yoshi
npcAI[228] = npcAI[95]

-- Volcano Lotus
npcAI[275] = {}
npcAI[275].enabled = true
npcAI[275].onTick = function(n, data)
  if data.power > 0 and data.powerPrev == 0 then
    n.ai1 = 1
    n.ai2 = 70
  end
  data.powerPrev = data.power
  data.power = 0
end

-- Bubble
npcAI[283] = {}
npcAI[283].enabled = true
npcAI[283].onTick = function(n, data)
  if data.power > 0 and data.powerPrev == 0 then
    n.ai3 = 1
  end
  data.powerPrev = data.power
  data.power = 0
end

-- Clappin Chuck
npcAI[312] = {}
npcAI[312].enabled = true
npcAI[312].onTick = function(n, data)
  if data.power > 0 and n.ai4 == 0 then
    n.ai4 = 1
    n.ai2 = 5
    n.ai3 = 20

    n.y = n.y - 4
    n.speedY = -math.abs(NPC.config[312].jumpheight)

    data.frame = 1
    SFX.play(24)
  end

  data.power = 0
end

-- Pitchin Chuck
npcAI[313] = {}
npcAI[313].enabled = true
npcAI[313].onTick = function(n, data)
  if data.power > 0 and n.ai2 < NPC.config[313].throwtime then
    n.ai2 = NPC.config[313].throwtime
  end

  data.power = 0
end

-- Diggin Chuck
npcAI[316] = {}
npcAI[316].enabled = true
npcAI[316].onTick = function(n, data)
  local configFile = NPC.config[316]
  if data.power > 0 and n.ai2 < configFile.startwait - 1 then
    n.ai2 = configFile.startwait - 1
  end

  data.power = 0
end

-- Whistlin Chuck
npcAI[317] = {}
npcAI[317].enabled = true
npcAI[317].onTick = function(n, data)
  local configFile = NPC.config[316]
  if data.power > 0 and n.ai2 ~= 1 then
    n.ai2 = 1
  end

  data.power = 0
end

-- Puntin Chuck
npcAI[318] = {}
npcAI[318].enabled = true
npcAI[318].onTick = function(n, data)
  if data.power > 0 and n.ai2 > 20 then
    n.ai2 = 20
  end

  data.power = 0
end

-- Splittin Chuck
npcAI[314] = {}
npcAI[314].enabled = true
npcAI[314].onTick = function(n, data)
  if data.power > 0 and n.ai4 == 0 then
    n.ai3 = 1
  end

  data.power = 0
end

-- Spike
npcAI[365] = {}
npcAI[365].enabled = true
npcAI[365].onTick = function(n, data)
  if data.power > 0 and n.ai2 == 1 then
    n.ai2=2
    n.ai1=60
    n.ai3=0
    n.ai4=0
    SFX.play(23)
  end

  data.power = 0
end

-- Rip Van Fish
npcAI[386] = {}
npcAI[386].enabled = true
npcAI[386].onTick = function(n, data)
if data.power > 0 then
  n.ai1=1
end
end

-- SMW Bob-omb
npcAI[408] = {}
npcAI[408].enabled = true
npcAI[408].onTick = function(n, data)
  if data.power > 0 then
    n:transform(409)
    n.speedX = 0
  end
end

-- Base Arrow Lift
npcAI[419] = {}
npcAI[419].enabled = true
npcAI[419].onTick = function(npc, data)
  if data.power > 0 and data.powerPrev == 0 and data._basegame.type then
    local settings = npc.data._settings
    local config = NPC.config[419]

    if data._basegame.child and data._basegame.child.isValid then
      data._basegame.child:kill()
    end

    local ghost = NPC.spawn(418, npc.x + npc.width*0.5, npc.y - 4, npc.section, false, false)
    data._basegame.child = ghost

    local ghostdata = ghost.data._basegame
    local ghostsettings = ghost.data._settings

    ghostdata.animation = 0
    ghostdata.timer = 0

    if not ghostsettings.override then
      ghostsettings.life = config.life
      ghostsettings.speed = config.speed
    end
    ghost.x = ghost.x - ghost.width*0.5
    ghost.dontMove = npc.dontMove
    ghost.layerName = "Spawned NPCs"
    ghostdata.parent = npc
    ghostsettings.life = settings.life
    ghostsettings.speed = settings.speed
    if settings.type == 0 then
      ghostsettings.type = -1
      ghostsettings.sp = true
    else
      ghostsettings.type = data._basegame.type - 1
      ghostsettings.sp = false
    end
  end

  data.powerPrev = data.power
  data.power = 0
end

-- Megan
npcAI[427] = {}
npcAI[427].enabled = true
npcAI[427].prime = function(n, data)
  data.redarea = data.redarea or redstone.basicRedArea(n)
  data.redhitbox = data.redhitbox or redstone.basicRedHitBox(n)
end

npcAI[427].onTick = function(n, data)
  redstone.updateRedArea(n)
  redstone.updateRedHitBox(n)
  redstone.passEnergy{source = n, power = 15, hitbox = data.redhitbox, area = data.redarea}
end

-- Wiggler
npcAI[446] = {}
npcAI[446].enabled = true
npcAI[446].onTick = function(n, data)
  if data.power > 0 and not data._basegame.isAngry then
    SFX.play(9)
    data._basegame.turningAngry = true
  end
end

-- SMW House Birds
npcAI[501] = {}
npcAI[501].enabled = true
npcAI[501].onTick = function(n, data)
  if data.power > 0 then
    n.id = n.id + 4
    n.speedY = -1
    n.dontMove = false
    n.direction = DIR_LEFT
    data._basegame.moveState = 3
  end
end
npcAI[502] = npcAI[501]
npcAI[503] = npcAI[501]
npcAI[504] = npcAI[501]

-- Tantrunt
npcAI[564] = {}
npcAI[564].enabled = true
npcAI[564].onTick = function(n, data)
  if data.power > 0 and data.powerPrev == 0 and n.ai1 ~= 1 then
    SFX.play(9)
    n.ai1 = 1
    n.ai3 = -30
    n.ai4 = 30
    data._basegame.xAccel = 0
    SFX.play(Misc.resolveFile("sound/extended/pig-squeal.ogg"))
  end
  data.powerPrev = data.power
  data.power = 0
end



local def_prime = function(n, data)
  data.powerPrev = data.powerPrev or 0
end

local keys = table.unmap(npcAI)
for k, v in ipairs(keys) do
  local t = npcAI[v]
  if type(v) == "number" then
    if not t.enabled then
      npcAI[v] = nil
    elseif not t.prime then
      npcAI[v].prime = def_prime
    end
  end
end

function npcAI.registerRedstoneAI(t)
  redstone = t
  for k, v in pairs(npcAI.redstone) do
    t[k] = v
  end
end

return npcAI
