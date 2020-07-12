GM.Name = "Raft v Raft"
GM.Author = ""
GM.Website = "https://github.com/cfc-servers/raft_v_raft"

RVR = RVR or {}

AddCSLuaFile( "localization.lua" )
AddCSLuaFile( "load_config.lua" )
AddCSLuaFile( "load_modules.lua" )
include( "localization.lua" )
include( "load_config.lua" )
include( "load_modules.lua" )
