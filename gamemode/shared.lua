GM.Name = "Raft v Raft"
GM.Author = ""
GM.Website = "https://github.com/cfc-servers/raft_v_raft"

RVR = RVR or {}

include( "config/inventory.lua" )
include( "modules/items/sh_items.lua" )

local function includeShared( f )
    AddCSLuaFile( f )
    include( f )
end

includeShared( "config/hunger.lua" )
includeShared( "modules/hunger/sh_hunger.lua" )
