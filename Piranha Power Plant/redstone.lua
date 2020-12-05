local RS = {}

-----------------------
--  Redstone.lua v1.0
--  SetaYoshi
-------------------------

-- Function to register a component
RS.component = {}
function RS.register(module)
  RS.component[module.name] = module
end

-- Defines redstone event order
RS.componentList = {
  "chip",
  "chest",
  "hopper",
  "redblock",
  "button",
  "lever",
  "block",
  "torch",
  "alternator",
  "repeater",
  "capacitor",
  "transmitter",
  "reciever",
  "operator",
  "reaper",
  "spyblock",
  "soundblock",
  "noteblock",
  "broadcaster",
  "note",
  "dropper",
  "flamethrower",
  "flame",
  "sickblock",
  "deadsickblock",
  "tnt",
  "jewel",
  "lectern",
  "reddoor",
  "piston",
  "piston_ehor",
  "piston_ever",
  "commandblock",
  "dust",
  "observer"
}


local npcAI = {}
local function tie(a, b, n)
  if n < a then return b - (a - n) + 1
  elseif n > b then return a + (n - b) - 1 end
  return n
end




-- Helper function
-- Adds energy to a redstone component
RS.setEnergy = function(n, p, d)
  if p > n.data.power then
    n.data.power = p
    d = d or 0
    n.data.dir = tie(0, 3, d + 2)
  end
end

-- Helper function
-- Determines how energy interacts between components
--[[
  n: NPC being powered
  c: compenent providing power
  p: The amount of power being provided
  d: The direction being provided
  hitbox: The hitbox of the power provided
--]]
RS.energyAI = function(n, c, p, d, hitbox)
  n.data.power = n.data.power or 0

  -- Ignore if the component is powering itself
  if n == c then

  -- Energy from broadcasters only goes to standard NPCs
  elseif RS.isBroadcaster(c.id) then
    if table.contains(RS.npcList, n.id) then
      RS.setEnergy(n, p)
    end

  -- Energy from sickblocks only goes to other sickblocks
  elseif RS.isDeadsickblock(c.id) then
    if RS.isDeadsickblock(n.id) then
      RS.energyFilter(n, c, p, d, hitbox)
    end
  elseif RS.isSickblock(c.id) then
    if RS.isSickblock(n.id) then
      if n.data.frameX == 2 then
        if c.data.frameX == 2 then
          return
        end
        n.data.immune = true
      end
      RS.energyFilter(n, c, p, d, hitbox)
    end

  -- Energy from transmitters only goes to recievers
  elseif RS.isTransmitter(c.id) then
    if RS.isReciever(n.id) then
      RS.setEnergy(n, p)
    end

  elseif RS.isReciever(c.id) and RS.isTransmitter(n.id) and d == tie(0, 3, n.data.frameX + 2) then

  -- The specifics AI of the operator block
  elseif RS.isOperator(c.id) then
    local op = RS.component.operator.op
    -- Mouth ouput
    if d == tie(0, 3, c.data.frameX + 2) then
      if RS.isReaper(n.id) and n.data.frameX == tie(0, 3, d + 2) then  -- inverse operation
        RS.energyFilter(n, c, 15 - p, d, hitbox)
        c.data.frameY = 1
      elseif RS.isCapacitor(n.id) and n.data.frameX == d then  -- equal operation
        if p == n.data.maxcapacitance then
          n.data.capacitance = n.data.maxcapacitance + 1
          RS.energyFilter(n, c, p, d, hitbox)
        end
      elseif RS.isAlternator(n.id) then  -- Flip
        RS.energyFilter(n, c, 15, d, hitbox)
      elseif RS.isSpyblock(n.id) and n.data.type == 2 and n.data.frameX == tie(0, 3, d + 2) then  -- general diff tracker
        RS.energyFilter(n, c, op.diff(c), d, hitbox)
      else
        RS.energyFilter(n, c, p, d, hitbox)
      end

    -- Plus output
    elseif d == tie(0, 3, c.data.frameX - 1) then
      if RS.isRepeater(n.id) and n.data.frameX == d and op.gand(c) then  -- and gate
        RS.setEnergy(n, 15)
      end
      if RS.isSpyblock(n.id) and n.data.type == 0 and n.data.frameX == tie(0, 3, d + 2) then  -- max comparator
        RS.setEnergy(n, op.cmax(c))
      end
      if RS.isSpyblock(n.id) and n.data.type == 2 and n.data.frameX == tie(0, 3, d + 2) then  -- plus diff tracker
        RS.setEnergy(n, op.dpos(c))
      end
      if RS.isCapacitor(n.id) and n.data.frameX == d then  -- larger than operation
        if c.data.power > n.data.maxcapacitance then
          n.data.capacitance = n.data.maxcapacitance + 1
          RS.energyFilter(n, c, c.data.power, d, hitbox)
        end
      end

    -- Minus output
    elseif d == tie(0, 3, c.data.frameX + 1) then
      if RS.isRepeater(n.id) and n.data.frameX == d and op.gxor(c) then  -- xor gate
        RS.setEnergy(n, 15)
      end
      if RS.isSpyblock(n.id) and n.data.type == 0 and n.data.frameX == tie(0, 3, d + 2) then  -- min comparator
        RS.setEnergy(n, op.cmin(c))
      end
      if RS.isSpyblock(n.id) and n.data.type == 2 and n.data.frameX == tie(0, 3, d + 2) then  -- negative diff tracker
        RS.setEnergy(n, op.dneg(c))
      end
      if RS.isCapacitor(n.id) and n.data.frameX == d then  -- less than operation
        if c.data.power < n.data.maxcapacitance then
          n.data.capacitance = n.data.maxcapacitance + 1
          RS.energyFilter(n, c, c.data.power, d, hitbox)
        end
      end
    end
  else
    return RS.energyFilter(n, c, p, d, hitbox)
  end
end

RS.energyFilter = function(n, c, p, d, hitbox)
  local component = RS.comList[n.id]
  if component and component.filter then
    return component.filter(n, c, p, d, hitbox)
  else
    RS.setEnergy(n, p)
  end

end


local nofilter = function() return true end

-- Helper function
-- Passes energy to the sorroundings of the NPC in all directions
--[[
  source: The NPC being the source of power
  power: The amount of power being provided
  area: Collider box representing area from where to search NPCs.
  npcList: List of NPCs the power should affect
  hitbox: The list collision box of the power as a box collider {x, y, w, h, direction}
    direction of power (0:left, 1:up, 2:right, 3:down). If left empty then direction is universal
]]
RS.passEnergy = function(args)
  args.npcList = args.npcList or RS.comID
  args.filter = args.filter or nofilter
  local list = Colliders.getColliding{a = args.area, b = args.npcList, btype = Colliders.NPC, filter = args.filter}
  local found = false
  for _, v in ipairs(args.hitbox) do
    for i = #list, 1, -1 do
      local n = list[i]
      if Colliders.collide(v, n) then
        local cancelled = RS.energyAI(n, args.source, args.power, v.direction, v)
        if not cancelled then
          found = true
          table.remove(list, i)
        end
      end
    end
  end
  return found
end

-- Helper function
-- Passes energy in a single direction
--[[
  source: The NPC being the source of power
  power: The amount of power being provided
  npcList: List of NPCs the power should affect
  hitbox: The collision box of the power as a box collider {x, y, w, h, direction}
    direction of power (0:left, 1:up, 2:right, 3:down). If left empty then direction is universal
]]
RS.passDirectionEnergy = function(args)
  local c = args.hitbox
  args.npcList = args.npcList or RS.comID
  local list = Colliders.getColliding{a = c, b = args.npcList, btype = Colliders.NPC, filter = nofilter}
  for _, n in ipairs(list) do
    if Colliders.collide(c, n) then
      RS.energyAI(n, args.source, args.power, c.direction, c)
    end
  end
end

-- Helper function
-- Passes inventory items. Returns true if the pass is successful
--[[
  source: The NPC being the source of the inventory
  inventory: The inventory ID being passed
  npcList: List of NPCs the power should affect
  hitbox: The collision box of the power as a box collider {x, y, w, h}
]]
RS.passInventory = function(args)
  local c = args.hitbox
  args.npcList = args.npcList or RS.comID
  local list = Colliders.getColliding{a = c, b = args.npcList, btype = Colliders.NPC, filter = nofilter}
  for _, n in ipairs(list) do
    if Colliders.collide(c, n) and n.data.invspace then
      n.data.inv = args.inventory
      return true
    end
  end
end






-- Helper function
-- Creates a common area collider
RS.basicRedArea = function(n)
  return Colliders.Box(0, 0, 1.5*n.width, 1.5*n.height)
end

-- Helper function
-- Creates a common list of hitboxes
RS.basicRedHitBox = function(n)
  local list = {
    Colliders.Box(0, 0, 0.25*n.width, 0.9*n.height),
    Colliders.Box(0, 0, 0.9*n.width, 0.25*n.height),
    Colliders.Box(0, 0, 0.25*n.width, 0.9*n.height),
    Colliders.Box(0, 0, 0.9*n.width, 0.25*n.height)
  }

  for i = 1, 4 do
    list[i].direction = i - 1
  end

  return list
end

-- Helper function
-- Updates the common hitbox collision for a single direction
RS.basicDirectionalRedHitBox = function(n, d)
  local c
  if d == 0 then
    c = Colliders.Box(0, 0, 0.25*n.width, 0.9*n.height)
  elseif d == 1 then
    c = Colliders.Box(0, 0, 0.9*n.width, 0.25*n.height)
  elseif d == 2 then
    c = Colliders.Box(0, 0, 0.25*n.width, 0.9*n.height)
  elseif d == 3 then
    c = Colliders.Box(0, 0, 0.9*n.width, 0.25*n.height)
  end

  c.direction = d

  return c
end

-- Helper function
-- Updates the position of the collider
RS.updateRedArea = function(n)
  n.data.redarea.x = n.x - 0.25*n.width
  n.data.redarea.y = n.y - 0.25*n.height
end

-- Helper function
-- Updates the position of the collider
RS.updateRedHitBox = function(n)
  local list = n.data.redhitbox
  list[1].x, list[1].y = n.x - 0.25*n.width, n.y + 0.05*n.height
  list[2].x, list[2].y = n.x + 0.05*n.width, n.y - 0.25*n.height
  list[3].x, list[3].y = n.x + n.width, n.y + 0.05*n.height
  list[4].x, list[4].y = n.x + 0.05*n.width, n.y + n.height
end

-- Helper function
-- Updates the position of the collider
RS.updateDirectionalRedHitBox = function(n, d)
  local c = n.data.redhitbox
  if d == 0 then
    c.x, c.y = n.x - 0.5*n.width, n.y + 0.05*n.height
  elseif d == 1 then
    c.x, c.y = n.x + 0.05*n.width, n.y - 0.5*n.height
  elseif d == 2 then
    c.x, c.y = n.x + n.width, n.y + 0.05*n.height
  elseif d == 3 then
    c.x, c.y = n.x + 0.05*n.width, n.y + n.height
  end
end

-- Helper function
RS.collisionBox = function(n, d)
  if d == 0 then
    return n.x - 2, n.y, 2, n.height
  elseif d == 1 then
    return n.x, n.y - 2, n.width, 2
  elseif d == 2 then
    return n.x + n.width, n.y, 2, n.height
  else
    return n.x, n.y + n.height, n.width, 2
  end
end

-- Helper function
RS.inputHitBox = function(n, d)
  if d == 0 then
    return n.x + n.width, n.y + n.height*0.05, n.width*0.5, n.height*0.9, 2
  elseif d == 1 then
    return n.x + n.width*0.05, n.y + n.height, n.width*0.9, n.height*0.5, 3
  elseif d == 2 then
    return n.x - n.width*0.5, n.y + n.height*0.05, n.width*0.5, n.height*0.9, 0
  else
    return n.x + n.width*0.05, n.y - n.height*0.5, n.width*0.9, n.height*0.5, 1
  end
end

-- Helper function
RS.facingHitBox = function(n, d)
  if d == 0 then
    return n.x - n.width*0.5, n.y + n.height*0.05, n.width*0.5, n.height*0.9
  elseif d == 1 then
    return n.x + n.width*0.05, n.y - n.height*0.5, n.width*0.9, n.height*0.5
  elseif d == 2 then
    return n.x + n.width, n.y + n.height*0.05, n.width*0.5, n.height*0.9
  else
    return n.x + n.width*0.05, n.y + n.height, n.width*0.9, n.height*0.5
  end
end

-- Helper function
-- Updates the custom draw timers that most components use
RS.updateDraw = function(n, data)
  local config = NPC.config[n.id]

  data.animTimer = data.animTimer + 1
  if data.animTimer >= config.frameSpeed then
    data.animTimer = 0
    data.animFrame = data.animFrame + 1
    if data.animFrame >= config.frames then
      data.animFrame = 0
    end
  end
end


RS.onScreenSound = function(n)
  return (n.x < camera.x + camera.width  + 100 and n.x + n.width > camera.x - 100) and (n.y < camera.y + camera.height + 100 and n.y + n.height > camera.y - 100)
end


-- Helper function
-- Draws the custom npc that most components use
RS.drawNPC = function(n)
  local config = NPC.config[n.id]
  n.animationFrame = -1
  if config.invisible then return end
  local z = n.data.priority or -45
  if config.foreground then
    z = -15
  elseif n:mem(0x12C, FIELD_WORD) > 0 then
    z = -30
  elseif n:mem(0x138, FIELD_WORD) > 0 then
    z = -75
  end
  Graphics.draw{
    type = RTYPE_IMAGE,
    isSceneCoordinates = true,
    image = Graphics.sprites.npc[n.id].img,
    x = n.x,-- + n.width*0.5 - config.gfxwidth*0.5 + config.gfxoffsetx,
    y = n.y,-- + n.height- config.gfxheight + config.gfxoffsety,
    sourceX = n.data.frameX*config.gfxwidth,
    sourceY = (n.data.frameY*config.frames + n.data.animFrame)*config.gfxheight,
    sourceWidth = config.gfxwidth,
    sourceHeight = config.gfxheight,
    priority = z,
    opacity = n.opacity
  }
end

-- Helper function
-- Checks if the NPC is valid
local function validCheck(v)
  if v.isHidden or v:mem(0x12A, FIELD_WORD) <= 0 or v:mem(0x124, FIELD_WORD) == 0 then
    return false
  end
  return true
end


-- Helper function
-- Passes a function to all NPCs of all component types
--[[
  I know the profiler took you here, but I can explain
  In order for the system to work, there has to be some type of order in which the NPCs are called
  so for example, chest are the first to execute its AI, then hoppers, and at the end, dust and observers

  This order ensures that energy is being passed correctly and that the NPCs interact with each other correctly
  so because of this, I cannot use onTickNPC, Im sure if the system was built differently at its foundation it might be possible...
  but this wasnt made this way and Im not to sure how to change the approach at this point.

  So, all NPC AI goes through this function, this is why the profiler takes you here. This is incharge of passing the AI in order
  Can there be improvememnts to this function? Maybe, but this is the best I got

  Also, dust is laggy, if you have a lot of it, try using the basicdust flag and see if that doesnt break your stuff (it probably wont break anything and it will save you from a LOT of lag)
]]
local redstoneLogic = function(func, forceStart)
  local l = NPC.get(RS.comID, RS.ps)
  local sort = {}

  for i = #l, 1, -1 do
    local n = l[i]
    local order = RS.comOrder[n.id]
    sort[order] = sort[order] or {}
    if validCheck(n) then
      table.insert(sort[order], n)
    else
      n.animationFrame = -1
      if forceStart then table.insert(sort[order], n) end
    end
  end
  for i = 1, #RS.comID do
    if sort[i] then
      for _, n in ipairs(sort[i]) do
        func(RS.comList[n.id], n)
      end
    end
  end

  -- for k, com in ipairs(RS.comList) do
  --   for i = #l, 1, -1 do
  --     local n = l[i]
  --     if n.id == com.id then
  --       table.remove(l, i)
  --       if validCheck(n) then
  --         func(com, n)
  --       else
  --         n.animationFrame = -1
  --       end
  --     end
  --   end
  -- end

  -- for k, v in ipairs(RS.componentList) do
  --   local com = RS.component[v]
  --   for _, n in ipairs(NPC.get(com.id, RS.ps)) do
  --     if validCheck(n) then
  --       func(com, n)
  --     else
  --       n.animationFrame = -1
  --     end
  --   end
  -- end

  -- for _, n in ipairs(NPC.get(RS.comID, RS.ps)) do
  --   local com = RS.component[RS.id2name[n.id]]
  --   if validCheck(n) then
  --     func(com, n)
  --   else
  --     n.animationFrame = -1
  --   end
  -- end
end

-- List of important per-NPC variables
local function primechecker(n)
  local data = n.data
  data.prime = true

  -- Power of the NPC, ranges from 0 to 15
  data.power = data.power or 0

  -- When true, an observer facing this NPC gets powered
  data.observ = data.observ or false

  -- The power level the observer will output when data.observ is true
  data.observpower = data.observpower or 15

  -- The current inventory slot of the NPC, 0 is empty
  data.inv = data.inv or 0

  -- If true, the inventory slot can be filled
  data.invspace = data.invspace or false
end

local function tickLogic(com, n)
  if not n.data.prime then
    primechecker(n)
    com.prime(n)
  end
  -- Copied from spawnzones.lua by Enjl
  if RS.disabledespawn and not n.isHidden and not n.data.disabledespawn then
    if n:mem(0x124,FIELD_BOOL) then
      n:mem(0x12A, FIELD_WORD, 180)
    elseif n:mem(0x12A, FIELD_WORD) == -1 then
      if n.x + n.width < camera.x or n.x > camera.x + camera.width then
        n:mem(0x124,FIELD_BOOL, true)
        n:mem(0x12A, FIELD_WORD, 180)
      end
    end
    n:mem(0x74, FIELD_BOOL, true)
  end
  com.onTick(n)
end

local function tickendLogic(com, n)
  if com.onTickEnd then
    com.onTickEnd(n)
  end
  if n.data.animTimer then
    RS.updateDraw(n, n.data)
  end
end

local function drawLogic(com, n)
  if not n.data.prime then
    primechecker(n)
    com.prime(n)
  end
  if com.onDraw then
    com.onDraw(n)
  end
end

RS.ps = {}
function RS.onStart()
  -- Adds a check for each component. e.g. RS.isDust()
  RS.comID = {}
  RS.comOrder = {}
  RS.comList = {}
  for k, v in ipairs(RS.componentList) do
    local com = RS.component[v]
    local testname, func = com.test()
    RS[testname] = func
    table.insert(RS.comID, com.id)
    RS.comList[com.id] = com
    RS.comOrder[com.id] = k
  end


  RS.ps = -1
  redstoneLogic(function(com, n)
    if not n.data.prime then
      primechecker(n)
      com.prime(n)
    end
  end, true)
  RS.ps = {}
end

function RS.onTick()
  RS.ps[1] = player.section
  if player2 then RS.ps[2] = player2.section end

  -- component onTick
  redstoneLogic(tickLogic)

  -- Regular NPCs AI for broadcaster component
  for _, n in ipairs(NPC.get(RS.npcList, RS.ps)) do
    if n.data and validCheck(n) then
      local dat = npcAI[n.id]
      if not n.data.prime then
        primechecker(n)
        dat.prime(n, n.data)
      end
      dat.onTick(n, n.data)
    end
  end
end


function RS.onTickEnd()
  redstoneLogic(tickendLogic)

  -- Observers need this special case to work properly
  for _, n in ipairs(NPC.get(RS.component.observer.id, RS.ps)) do
    if n.data and validCheck(n) then
      RS.component.observer.onTickObserver(n, RS)
    end
  end
end

function RS.onDraw()
  redstoneLogic(drawLogic)
end

-- Fix for Grabable NPCs that die when thrown into a wall
function RS.onNPCKill(event, n, reason, culprit)
  if reason == 3 and (RS.isRedblock(n.id) or RS.isChest(n.id)) then
     event.cancelled = true
  end
end


-- NPC AI, a file meant to be edited by the level author
RS.npcAI = require("redstone_ai")
npcAI = RS.npcAI
npcAI.registerRedstoneAI(RS)
RS.npcList = {}
for k in pairs(npcAI) do
  table.insert(RS.npcList, k)
end


function RS.onInitAPI()
	registerEvent(RS, "onStart", "onStart")
	registerEvent(RS, "onTick", "onTick")
  registerEvent(RS, "onTickEnd", "onTickEnd")
	registerEvent(RS, "onDraw", "onDraw")
	registerEvent(RS, "onNPCKill", "onNPCKill")
end

return RS
