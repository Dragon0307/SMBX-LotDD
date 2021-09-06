--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

--Create the library table
local redElite = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID
--Defines NPC config for our NPC. You can remove superfluous definitions.
local redEliteSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 54,
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
npcManager.setNpcSettings(redEliteSettings)

--Registers the category of the NPC. Options include HITTABLE, UNHITTABLE, POWERUP, COLLECTIBLE, SHELL. For more options, check expandedDefines.lua
npcManager.registerDefines(npcID, {NPC.HITTABLE})

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
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
function redElite.onInitAPI()
	--npcManager.registerEvent(npcID, redElite, "onTickNPC")
	npcManager.registerEvent(npcID, redElite, "onTickEndNPC")
	--npcManager.registerEvent(npcID, redElite, "onDrawNPC")
	registerEvent(redElite, "onNPCHarm")
end

function redElite.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if data.ftimer == nil then
		data.ftimer = 0
	end
	if data.pdtimer == nil then --play dead timer
		data.pdtimer = 0
	end
	if data.pd == nil then --play dead
		data.pd = false
	end
	if data.health == nil then
		data.health = 3
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
	
	--Execute main AI.
	if not v:mem(0x128,FIELD_BOOL) and not data.pd then
		data.ftimer = data.ftimer + 1
		if data.ftimer >= 96 and data.ftimer < 108 then
			v.dontMove = true
			if v.direction == -1 then
				v.animationFrame = 4
			else
				v.animationFrame = 6
			end
		elseif data.ftimer >= 108 and data.ftimer < 124 then
			if v.direction == -1 then
				v.animationFrame = 5
			else
				v.animationFrame = 7
			end
			if data.ftimer == 112 or data.ftimer == 120 then
				SFX.play(18)
				local fire = NPC.spawn(755,v.x+8+(16*v.direction),v.y-8,player.section)
				fire.speedY = -7
				fire.speedX = v.direction*7
			end
		elseif data.ftimer == 124 then
			v.dontMove = false
			data.ftimer = 0
		end
	end
	if data.pd then
		v.animationFrame = 8
		v.dontMove = true
		v.friendly = true
		data.pdtimer = data.pdtimer + 1
	end
	if data.pdtimer == 80 then
		v.dontMove = false
		v.friendly = false
		v.speedY = -7.5
		data.pd = false
		SFX.play(35)
		data.pdtimer = 0
	end
	if data.health == 0 then
		v:kill(9)
		Animation.spawn(62,v.x,v.y,3)
	end
end
function redElite.onNPCHarm(eventObj, v, killReason, culprit)
	if v.id ~= npcID then return end
	if killReason ~= HARM_TYPE_JUMP and killReason ~= HARM_TYPE_FROMBELOW and killReason ~= HARM_TYPE_SPINJUMP and killReason ~= HARM_TYPE_SWORD then return end
	
	local data = v.data
	data.pd = true
	data.health = data.health - 1
	if health ~= 0 then
		eventObj.cancelled = true
	end
	SFX.play(2)
end

--Gotta return the library table!
return redElite