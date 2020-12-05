--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local blueElite = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local blueEliteSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 58,
	gfxwidth = 32,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 32,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 2,
	framestyle = 1,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 1.5,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=false,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi= false,
	nowaterphysics = false,
	cliffturn = true,
	--Various interactions
	jumphurt = false, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	--Identity-related flags. Apply various vanilla AI based on the flag:
	iswalker = true,
	--isbot = false,
	--isvegetable = false,
	--isshoe = false,
	--isyoshi = false,
	--isinteractable = false,
	--iscoin = false,
	--isvine = false,
	--iscollectablegoal = false,
	--isflying = false,
	--iswaternpc = false,
	--isshell = false,

	--Emits light if the Darkness feature is active:
	--lightradius = 100,
	--lightbrightness = 1,
	--lightoffsetx = 0,
	--lightoffsety = 0,
	--lightcolor = Color.white,

	--Define custom properties below
}

--Applies NPC settings
npcManager.setNpcSettings(blueEliteSettings)

--Registers the category of the NPC. Options include HITTABLE, UNHITTABLE, POWERUP, COLLECTIBLE, SHELL. For more options, check expandedDefines.lua
npcManager.registerDefines(npcID, {NPC.HITTABLE})

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		--[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below


--Register events
function blueElite.onInitAPI()
	--npcManager.registerEvent(npcID, blueElite, "onTickNPC")
	npcManager.registerEvent(npcID, blueElite, "onTickEndNPC")
	--npcManager.registerEvent(npcID, blueElite, "onDrawNPC")
	--registerEvent(blueElite, "onNPCKill")
end

function blueElite.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if data.sTimer == nil then
		data.sTimer = 0
	end
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	--Execute main AI. This template just jumps when it touches the ground.
	if not v:mem(0x128,FIELD_BOOL) then
		data.sTimer = data.sTimer + 1
		if data.sTimer >= 64 and data.sTimer < 96 then
			v.dontMove = true
			if player.x < v.x then
				v.direction = -1
			else
				v.direction = 1
			end
			if v.direction == -1 then
				v.animationFrame = 4
			else
				v.animationFrame = 6
			end
		elseif data.sTimer >= 96 and data.sTimer < 108 then
			if v.direction == -1 then
				v.animationFrame = 5
			else
				v.animationFrame = 7
			end
			if data.sTimer == 104 then
				v.friendly = true
				local blueShell = NPC.spawn(115,v.x,v.y-16,player.section)
				blueShell.speedX = v.direction*7
				blueShell.speedY = -7
				Animation.spawn(75,v.x,v.y-16)
				SFX.play(9)
			end
		elseif data.sTimer == 108 then
			v.friendly = false
			v.dontMove = false
			v:transform(119)
		end
	end
end

--Gotta return the library table!
return blueElite