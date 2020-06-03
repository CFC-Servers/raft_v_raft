GM.Name = "Raft v Raft"
GM.Author = ""
GM.Website = "https://github.com/cfc-servers/raft_v_raft"

local function includeShared( f )
    AddCSLuaFile( f )
    include( f )
end

includeShared( "modules/commands/sh_commands.lua" )
includeShared( "config/hunger.lua" )
includeShared( "modules/hunger/sh_hunger.lua" )
