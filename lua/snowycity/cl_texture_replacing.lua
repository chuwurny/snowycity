xorlib.Dependency("snowycity", "cl_base.lua")
xorlib.Dependency("snowycity", "cl_config.lua")

local MAP_CONFIG_FOUND = xorlib.Dependency("snowycity/map_config",
                                           game.GetMap() .. ".lua")

x.Assert(MAP_CONFIG_FOUND, "No config found for map %s", game.GetMap())

x.Assert(ChuSnowflakes.MapTextureReplaceList,
         "Forgot to create ChuSnowflakes.MapTextureReplaceList?")

local TEXTURE_TO_REPLACED = {}

for _, data in ipairs(ChuSnowflakes.MapTextureReplaceList) do
    local replaceFrom = data[1]
    local replaceTo   = data[2]

    TEXTURE_TO_REPLACED[replaceFrom] = replaceTo
end

ChuSnowflakes.OriginalMaterials = ChuSnowflakes.OriginalMaterials or {}
local oMaterials = ChuSnowflakes.OriginalMaterials

local cfg = ChuSnowflakes.Config

function ChuSnowflakes.ReplaceTextures()
	for _, data in ipairs(ChuSnowflakes.MapTextureReplaceList) do
		local replaceFrom = data[1]
		local replaceTo   = data[2]

		local replaceFromMaterial = Material(replaceFrom)

		oMaterials[replaceFrom] = oMaterials[replaceFrom] or
                                  replaceFromMaterial:GetTexture("$basetexture")
                                                     :GetName()

		replaceFromMaterial:SetTexture("$basetexture", replaceTo)
	end
end

function ChuSnowflakes.RestoreTextures()
	for _, data in ipairs(ChuSnowflakes.MapTextureReplaceList) do
		local replaceFrom = data[1]
		local original    = oMaterials[replaceFrom]

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
