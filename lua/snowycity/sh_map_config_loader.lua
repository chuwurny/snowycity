xorlib.Dependency("snowycity", "cl_base.lua")

xorlib.IncludeFile(xorlib.ClientIncluder,
                   "snowycity/map_config",
                   game.GetMap() .. ".lua")

local isMapConfigLoaded = xorlib.IsIncluded("snowycity/map_config",
                                            game.GetMap() .. ".lua")

x.Assert(isMapConfigLoaded, "No config found for map %s", game.GetMap())
