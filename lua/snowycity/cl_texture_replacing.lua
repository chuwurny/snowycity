xorlib.Dependency("snowycity", "cl_base.lua")
xorlib.Dependency("snowycity", "cl_config.lua")
xorlib.Dependency("snowycity", "sh_map_config_loader.lua")

x.Assert(ChuSnowflakes.MapTextureReplaceList,
         "Forgot to create ChuSnowflakes.MapTextureReplaceList?")

local TEXTURE_TO_REPLACED = {}

for replaceFrom, replaceTo in pairs(ChuSnowflakes.MapTextureReplaceList) do
    TEXTURE_TO_REPLACED[replaceFrom] = replaceTo
end

ChuSnowflakes.OriginalMaterials = ChuSnowflakes.OriginalMaterials or {}
local oMaterials = ChuSnowflakes.OriginalMaterials

local cfg = ChuSnowflakes.Config

function ChuSnowflakes.ReplaceTextures()
    for replaceFrom, replaceTo in pairs(ChuSnowflakes.MapTextureReplaceList) do
        local replaceFromMaterial = Material(replaceFrom)

        if replaceFromMaterial:IsError() then
            x.Warn("Replace material \"%s\" is invalid", replaceFrom)
        end

        oMaterials[replaceFrom] = oMaterials[replaceFrom] or
                                  replaceFromMaterial:GetTexture("$basetexture")
                                                     :GetName()

        replaceFromMaterial:SetTexture("$basetexture", replaceTo)
    end
end

function ChuSnowflakes.RestoreTextures()
    for replaceFrom, _ in pairs(ChuSnowflakes.MapTextureReplaceList) do
        local original = oMaterials[replaceFrom]

        if original then
            Material(replaceFrom):SetTexture("$basetexture", original)
        end
    end
end

local TRACE_DIR = Vector(0, 0, -100)

hook.Add("PlayerFootstep", "snowycity sounds", function(ply, pos, _, _,
                                                        volume, _)
    local tr = util.QuickTrace(pos, TRACE_DIR, ply)
    if not tr.Hit then return end

    local texture = TEXTURE_TO_REPLACED[tr.HitTexture]
    if not texture then return end

    local soundGetter = cfg.FOOTSTEP_REPLACE_DATA[texture]
    if not soundGetter then return end

    local sound = soundGetter()

    EmitSound(sound, pos, ply:EntIndex(), CHAN_AUTO, volume)

    return true
end, HOOK_MONITOR_LOW)
