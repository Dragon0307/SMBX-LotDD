local lhp = {}

lhp.iFrames = 25

local harmtypedamage = {

}

local npcdamage = {

}

local npchp = {

}

local harmtypesound = {

}

function lhp.setHarmtypeDamage(HARMTYPE, value)
    harmtypedamage[HARMTYPE] = value
end

function lhp.setHarmtypeSound(HARMTYPE, value)
    harmtypesound[HARMTYPE] = value
end

function lhp.setNPCDamage(NPCID, value)
    npcdamage[NPCID] = value
end

function lhp.setHP(NPCID, value)
    npchp[NPCID] = value
end

function lhp.onInitAPI()
    registerEvent(lhp, "onNPCHarm")
    registerEvent(lhp, "onCameraDraw")
end

function lhp.onNPCHarm(e, v, r, c)
    if (r ~= HARM_TYPE_OFFSCREEN) and npchp[v.id] then
        if v.data.lhphp == nil then
            v.data.lhphp = npchp[v.id]
        end
        local damage = 1
        damage = damage * (harmtypedamage[r] or 1)
        if c and c.__type == "NPC" then
            damage = damage * (npcdamage[c.id] or 1)
        end

        if v.data.iFrames and v.data.iFrames > lunatime.tick() - lhp.iFrames then
            damage = 0
        else
            v.data.iFrames = lunatime.tick()
        end
        v.data.lhphp = math.max(v.data.lhphp - damage, 0)
        if damage ~= 0 and v.data.lhphp > 0 then
            if harmtypesound[r] then
                SFX.play(harmtypesound[r])
            end
        end
        if v.data.lhphp > 0 then
            e.cancelled = true
        end
    end
end

local function drawHPBar(v)
    local x = v.x + 0.5 * v.width
    local y = v.y - 10

    local width = 10 + 5 * math.ceil((npchp[v.id] or 1) * 0.2)
    
    Graphics.drawBox{
        x = x - 0.5 * width,
        width = width,
        y = y - 2,
        height = 4,
        color = Color.red,
        sceneCoords = true,
        priority = -45
    }

    Graphics.drawBox{
        x = x - 0.5 * width,
        width = width * (v.data.lhphp / (npchp[v.id] or 1)),
        y = y - 2,
        height = 4,
        color = Color.green,
        sceneCoords = true,
        priority = -45
    }
end

function lhp.onCameraDraw()
    for k,v in ipairs(NPC.getIntersecting(camera.x, camera.y, camera.x + camera.width, camera.y + camera.height)) do
        if NPC.HITTABLE_MAP[v.id] and v:mem(0x12A, FIELD_WORD) > 0 and not v.friendly then
            if v.data.lhphp then
                drawHPBar(v)
            end
        end
    end
end

return lhp