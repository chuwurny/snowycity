xorlib.Dependency("snowycity", "cl_base.lua")
xorlib.Dependency("snowycity", "cl_config.lua")
xorlib.Dependency("snowycity", "cl_texture_replacing.lua")

local cfg = ChuSnowflakes.Config

local Vector          = Vector
local VectorRand      = VectorRand
local ParticleEmitter = ParticleEmitter
local SysTime         = SysTime

local random          = math.random
local traceLine       = util.TraceLine

local pos
local shootPos
local aimVector

local VECTOR_ZERO     = vector_origin or Vector()
local MASK_OPAQUE     = MASK_OPAQUE
local MASK_SHOT       = MASK_SHOT

local localPlayer

local TIMER = "snowycity snowflakes"

function ChuSnowflakes.SetPaused(pause)
    if pause then
        timer.Pause(TIMER)
    else
        timer.UnPause(TIMER)
    end
end

function ChuSnowflakes.IsPaused()
    return timer.TimeLeft(TIMER) < 0
end

function ChuSnowflakes.ShouldCreateSnowflakes()
    local tr = traceLine({
        start  = shootPos(),
        endpos = shootPos() + (aimVector() * 50000),
        filter = localPlayer,
        mask   = MASK_OPAQUE
    })

    if tr.Fraction < 0.004 then
        return false -- hitting wall
    end

    local startPos = pos() + (tr.Normal * cfg.TRACE_CHECK_EYE_NORMAL_MUL)

    return traceLine({
        start  = startPos,
        endpos = startPos + cfg.SKY_DIRECTION,
        filter = localPlayer,
        mask   = MASK_SHOT
    }).HitSky
end

function ChuSnowflakes.Think()
    local startTime = SysTime()

    if not ChuSnowflakes.ShouldCreateSnowflakes() then return end

    local emitter = ParticleEmitter(VECTOR_ZERO)
    local initPos = pos() + cfg.EMITTER_SPAWN_OFFSET +
                    (aimVector() * cfg.SNOWFLAKES_EYE_NORMAL_MUL)

    for i = 1, cfg.SNOWFLAKES_COUNT do
        if SysTime() - startTime > cfg.PERFORMANCE_MAX_TIME then
            x.Warn("Performance warning! Not creating snowflakes anymore. " ..
                   "Created: %d/%d",
                   i,
                   cfg.SNOWFLAKES_COUNT)

            break
        end

        local offset = VectorRand(-cfg.SNOWFLAKES_RANGE, cfg.SNOWFLAKES_RANGE)

        offset.z = cfg.SNOWFLAKES_HEIGHT_ADD + offset.z %
                   cfg.SNOWFLAKES_HEIGHT_MAX

        local part = emitter:Add("sprites/light_glow02_add", initPos + offset)

        if part then
            part:SetDieTime(10)

            part:SetStartAlpha(100)
            part:SetEndAlpha(255)

            part:SetStartSize(2)
            part:SetEndSize(5)

            part:SetCollide(true)

            part:SetAirResistance(random(cfg.AIR_RESISTANCE_MIN,
                                         cfg.AIR_RESISTANCE_MAX))

            part:SetGravity(cfg.PARTICLE_GRAVITY)
            part:SetVelocity(cfg.PARTICLE_INIT_VELOCITY)
        end
    end

    emitter:Finish()
end

do
    local chusnowflakes_enable = CreateClientConVar("chusnowflakes_enable", "1")

    local function updateSnowflakesEnableState()
        local pause = not chusnowflakes_enable:GetBool()

        x.Print("Snowflakes are %s", pause and "paused" or "resumed")

        ChuSnowflakes.SetPaused(pause)
    end

    x.EnsureHasLocalPlayer(function(lp)
        localPlayer = lp

        pos       = x.BindMeta("Entity", "GetPos",       lp)
        shootPos  = x.BindMeta("Player", "GetShootPos",  lp)
        aimVector = x.BindMeta("Player", "GetAimVector", lp)

        timer.Create(TIMER, 1, 0, function()
            xpcall(ChuSnowflakes.Think, x.ErrorNoHaltWithStack)
        end)

        updateSnowflakesEnableState()

        ChuSnowflakes.ReplaceTextures()
    end)

    hook.Add("Shutdown", "revert snowycity", ChuSnowflakes.RestoreTextures)

    concommand.Add("chusnowycity_replace", ChuSnowflakes.ReplaceTextures)
    concommand.Add("chusnowycity_restore", ChuSnowflakes.RestoreTextures)

    cvars.AddChangeCallback(chusnowflakes_enable:GetName(),
                            updateSnowflakesEnableState,
                            "")
end

