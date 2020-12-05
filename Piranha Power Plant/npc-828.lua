local commandblock = {}

local redstone = require("redstone")
local npcManager = require("npcManager")
local repl = require("base/game/repl")

commandblock.name = "commandblock"
commandblock.id = NPC_ID

commandblock.test = function()
  return "isCommandblock", function(x)
    return (x == commandblock.name or x == commandblock.id)
  end
end

commandblock.filter = function(n, c, p, d, hitbox)
  redstone.setEnergy(n, p, d)
end

commandblock.config = npcManager.setNpcSettings({
	id = commandblock.id,

	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
  invisible = false,

	frames = 1,
	framespeed = 8,
	framestyle = 0,

	width = 32,
	height = 32,

  nogravity = true,
  notcointransformable = true,
	jumphurt = true,
  noblockcollision = true,
	nohurt = true,
	noyoshi = true,
  blocknpc = true,
  playerblock = true,
  playerblocktop = true,
  npcblock = true
})

-- Based off repl.lua

local unpack = _G.unpack or table.unpack
local memo_mt = {__mode = "k"} --recommended by Rednaxela
-- Memoize a function with one argument.
local function memoize(func)
	local t = {}
	setmetatable(t, memo_mt)
	return function(x, e)
		if t[x] then
			return unpack(t[x])
		else
			local ret = {func(x, e)}
			t[x] = ret
			return unpack(ret)
		end
	end
end

local function printConsole(str)
  if type(str) == "string" then
  table.insert(repl.log, str)
else
  Misc.dialog("???")
  Misc.dialog(str)
end
end


local function printError(err)
	printConsole("error: " .. err:gsub("%[?.*%]?:%d+: ", "", 1))
end

local function printValues(vals)
	if next(vals, nil) == nil then
		return
	end
	local t = {}
	local multiline = false
	local maxIdx = 0
	for k,v in pairs(vals) do
		maxIdx = math.max(maxIdx, k)
		t[k] = inspect(v)
		if t[k]:find("\n") then
			multiline = true
		end
	end
	if multiline then
		for i = 1, maxIdx do
			printConsole(t[i] or "nil")
		end
	else
		local s = ""
		for i = 1, maxIdx do
			if s ~= "" then
				s = s .. " "
			end
			s = s .. (t[i] or "nil")
		end
		printConsole(s)
	end
end

-- Create a shallow copy of a list, missing the first entry.
local function trim(t)
	local ret = {}
	for k,v in ipairs(t) do
		if k ~= 1 then
			ret[k - 1] = v
		end
	end
	return ret
end

local cenv = Misc.getCustomEnvironment()
local function getEnv(env)
  local t = cenv
  for k, v in pairs(env) do
    t[k] = v
  end
  return t
end


local rawload = load
local function load(str, env)
	return rawload(str, str, "t", env)
end
load = memoize(load)

-- Check whether a string is syntactically valid Lua.
local function isValid(str, env)
	return not not load(str, env)
end
isValid = memoize(isValid)

-- Check whether a string is a valid Lua expression.
local function isExpression(str, env)
	return isValid("return " .. str .. ";", env)
end
isExpression = memoize(isExpression)

-- Check whether a string is a valid Lua function call.
-- Anything that's both an expression and a chunk is a function call.
local function isFunctionCall(str, env)
	return isExpression(str, env) and isValid(str, env)
end
isFunctionCall = memoize(isFunctionCall)

local function exec(block, env, showErr)
	local chunk = load(block, env)
	local x = {pcall(chunk)}
	local success = x[1]
	local vals = trim(x)
	if success then
		printValues(vals)
	else
    if showErr then
		  printError(vals[1])
    end
	end
end

local function eval(expr, env, showErr)
	local chunk = load("return " .. expr .. ";", env)
	local x = {pcall(chunk)}
	local success = x[1]
	local vals = trim(x)
	if success then
		printValues(vals)
		if next(vals, nil) == nil and not isFunctionCall(expr, env) then
			printConsole("nil")
		end
	else
    if showErr then
		  printError(vals[1])
    end
	end
end

local function script_run(str, env, showErr)
  if isExpression(str, env) then
		eval(str, env, showErr)
	elseif isValid(str, env) then
		exec(str, env, showErr)
	else
    if showErr then
      printError(select(2, load(str, env)))
    end
	end
end

function commandblock.prime(n)
  local data = n.data

  data.frameX = data._settings.type or 0
  data.frameY = data.frameY or 0
  data.animFrame = data.animFrame or 0
  data.animTimer = data.animTimer or 0

  data.script = data._settings.script or ""
  data.rotutine = false
  data.powerPrev = 0
end

function commandblock.onTick(n)
  local data = n.data
  data.observ = false


  if data.power > 0 then
    data.frameY = 1
    if (data.frameX == 1) or (data.frameX == 0 and data.powerPrev == 0 and not (data.routine and data.routine.isValid)) then
      local env = {commandBlock = n, powerLevel = data.power, powerDirection = data.dir, powerLevelPrevious = data.powerPrev, script = data.script}

      if data.powerPrev == 0 then
        table.insert(repl.log, "[COMMAND BLOCK] "..n.x..", "..n.y)
        table.insert(repl.log, data.script)
        table.insert(repl.history, data.script)
      end
      if data.frameX == 0 then
        data.routine = Routine.run(script_run, data.script, getEnv(env), true)
      else
        script_run(data.script, getEnv(env), data.powerPrev == 0)
      end

    end
  else
    data.frameY = 0
  end

  if data.frameX == 0 and ((data.routine and data.routine.isValid) or (data.routine and not data.routine.isValid and data.power ~= 0 and data.powerPrev == 0)) then
    data.observ = true
  elseif data.frameX == 1 and data.power ~= 0 then
    data.observ = true
  end


  data.powerPrev = data.power
  data.power = 0
end

function commandblock.onDraw(n)
  redstone.drawNPC(n)
end

redstone.register(commandblock)

return commandblock
