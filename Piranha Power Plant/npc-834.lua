local door = {}

local redstone = require("redstone")
local npcManager = require("npcManager")

door.name = "reddoor"
door.id = NPC_ID

door.test = function()
  return "isRedDoor", function(x)
    return (x == door.name or x == door.id)
  end
end

door.config = npcManager.setNpcSettings({
	id = door.id,

	gfxwidth = 32,
	gfxheight = 64,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  invisible = false,

	frames = 1,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 64,

  nogravity = true,
  noblockcollision = true,
  notcointransformable = true,
	jumphurt = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = false,
  playerblock = false,
  playerblocktop = false,
  npcblock = false
})

function door.prime(n)
  local data = n.data

  data.frameX = data.frameX or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0
  data.priority = -75

  data.powerPrev = data.powerPrev or 0
  data.doorTimer = data.doorTimer or 0

  for k, v in ipairs(Warp.get()) do
    local c = Colliders.Box(v.entranceX, v.entranceY, v.entranceWidth, v.entranceHeight)
    if Colliders.collide(n, c) then
      data.warp = v
    end
  end
end

function door.onTick(n)
  local data = n.data
  data.observ = false


  if (data.power ~= 0 and data.powerPrev == 0) or (data.power == 0 and data.powerPrev ~= 0) then
    local e = Animation.spawn(10, n.x + 0.5*n.width, n.y + 0.5*n.height)
    e.x, e.y = e.x - e.width*0.5, e.y - e.height*0.5
  end

  if data.warp then
    data.warp:mem(0x0C, FIELD_BOOL, data.power == 0)
    if data.power > 0 then
      for k, p in ipairs(Player.get()) do
        if p.forcedState == FORCEDSTATE_DOOR and p.forcedTimer == 1 and Colliders.collide(n, p) then
          data.doorTimer = 5*8 -- 5 frames, 8 animation speed
          break
        end
      end
    end
  end

  if data.power ~= data.powerPrev then
    data.observ = true
  end

  if data.power == 0 then
    data.frameY = 0
    data.doorTimer = 0
  elseif data.doorTimer > 0 then
    data.frameY = 2 + math.floor(((5*8) - data.doorTimer)/8)
    data.doorTimer = data.doorTimer - 1
  else
    data.frameY = 1
  end

  data.powerPrev = data.power
  data.power = 0
end

function door.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(door)

return door
