local chip = {}

local redstone = require("redstone")
local npcManager = require("npcManager")
local repl = require("base/game/repl")

chip.name = "chip"
chip.id = NPC_ID

chip.test = function()
  return "isChip", function(x)
    return (x == chip.name or x == chip.id)
  end
end

chip.config = npcManager.setNpcSettings({
	id = chip.id,

	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  foreground = true,
  invisible = true,

	frames = 1,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 32,

	jumphurt = true,
  noblockcollision = true,
  nogravity = true,
  notcointransformable = true,
	nohurt = true,
	noyoshi = true
})


local proxytbl = {
	rng = RNG,
	lunatime = lunatime,
	e = 2.718281828459,
	toBlocks = function(pixels)
		return pixels / 32
	end,
	toPixels = function(blocks)
		return blocks * 32
	end
}

local proxymt = {
	__index = function(t, k)
		return lunatime[k] or RNG[k] or math[k] or _G[k]
	end,
	__newindex = function() end
}
setmetatable(proxytbl, proxymt)

local funcCache = {}
local parse -- Local outside for recursion
function parse(msg, recurse)
	if funcCache[msg] then
		return funcCache[msg]
	end
	local str = "return function(timer, npc, powerLevel) "..msg.." return {timer = timer, powerLevel = powerLevel} end"
	local chunk, err = load(str, str, "t", proxytbl)
	if chunk then
		local func = chunk()
		funcCache[msg] = func
		return func
	elseif not recurse then
		return parse(msg:gsub("\r?\n", ";\n"), true)
	else
		return nil, err
	end
end

local function call(npc)
	local data = npc.data
	local t = data.func(data.timer, data.attachedNPC, data.power)

	data.timer = t.timer or data.timer
  data.power = t.powerLevel or data.power
end

function chip.prime(n)
  local data = n.data

  data.frameX = data._settings.type or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.timer = 0
  if data._settings.advanced then
    data.func = data._settings.func
  else
    data._settings.onTime = data._settings.onTime or 200
    data._settings.offTime = data._settings.offTime or 200
    data._settings.powerlevel = data._settings.powerlevel or 15
    data.func = "if timer <= "..data._settings.onTime.." then powerLevel = "..data._settings.powerlevel.." else powerLevel = 0 end if timer >= "..(data._settings.offTime + data._settings.onTime).." then timer = 0 end"
    if not data._settings.active then
      data.timer = data._settings.ontime or 200
    end
  end

  local func, err = parse(data.func or "")
  if err then
    table.insert(repl.log, "[CONTROL CHIP] "..n.x..", "..n.y)
    table.insert(repl.log, err)
    n:kill()
  else
    data.func = func
  end

end

function chip.onTick(n)
  local data = n.data
  if data.attached then
    data.timer = data.timer + 1
    if not data.attachedNPC.isValid then
      n:kill() return
    end
    local npc = data.attachedNPC
    n.x, n.y = npc.x, npc.y
    call(n)
    if data.power > 0 then
      if redstone.isDust(npc.id) or redstone.isDeadsickblock(npc.id) then
        redstone.energyFilter(npc, n, data.power, 1, npc)
      else
        npc.data.power = data.power
      end
      data.frameY = 1
    else
      data.frameY = 0
    end
  else
    local npc = Colliders.getColliding{a = n, b = NPC.ALL, atype = Colliders.NPC, btype = Colliders.NPC, filter = function(npc) return npc.isValid and not npc.isHidden and n ~= npc end}
    if npc[1] then
      data.attached = true
      data.attachedNPC = npc[1]
    end
  end
end

function chip.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(chip)

return chip
