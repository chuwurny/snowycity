xorlib.Dependency("snowycity", "cl_base.lua")

ChuSnowflakes.Config = ChuSnowflakes.Config or {}

local cfg = ChuSnowflakes.Config

cfg.FOOTSTEP_SOUND_GETTERS     = {
    Snow = function()
        return string.format("player/footsteps/snow%d.wav", math.random(1, 6))
    end,

    -- TF2 only :(
--  Ice = function()
--      return string.format("player/footsteps/ice%d.wav", math.random(1, 4))
--  end,
}

cfg.FOOTSTEP_REPLACE_DATA      = {
    ["nature/snowfloor001a"] = cfg.FOOTSTEP_SOUND_GETTERS.Snow,
    ["nature/snowfloor002a"] = cfg.FOOTSTEP_SOUND_GETTERS.Snow,
    ["nature/snowwall004a"]  = cfg.FOOTSTEP_SOUND_GETTERS.Snow,
    ["nature/snowwall001a"]  = cfg.FOOTSTEP_SOUND_GETTERS.Snow
}

cfg.EMITTER_SPAWN_OFFSET       = Vector(0, 0, 200)

cfg.PARTICLE_GRAVITY           = Vector(0, 200, -300)
cfg.PARTICLE_INIT_VELOCITY     = cfg.PARTICLE_GRAVITY * 2 -- Vector(0, 100, -200)

cfg.SKY_DIRECTION              = Vector(0, 0, 50000)

cfg.SNOWFLAKES_COUNT           = 200
cfg.SNOWFLAKES_RANGE           = 1000
cfg.SNOWFLAKES_HEIGHT_ADD      = 500
cfg.SNOWFLAKES_HEIGHT_MAX      = 700
cfg.SNOWFLAKES_EYE_NORMAL_MUL  = 600

cfg.TRACE_CHECK_EYE_NORMAL_MUL = 400

cfg.AIR_RESISTANCE_MIN         = 1
cfg.AIR_RESISTANCE_MAX         = 50

cfg.PERFORMANCE_MAX_TIME       = 0.01
