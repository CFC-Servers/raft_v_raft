GM.Name = "Raft v Raft"
GM.Author = ""
GM.Website = "https://github.com/cfc-servers/raft_v_raft"

RVR = RVR or {}

local function includeShared( f )
    AddCSLuaFile( f )
    include( f )
end

includeShared( "modules/usergroups/sh_usergroups.lua" )
includeShared( "config/hunger.lua" )
includeShared( "modules/hunger/sh_hunger.lua" )
