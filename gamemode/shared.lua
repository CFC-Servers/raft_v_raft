GM.Name = "Raft v Raft"
GM.Author = ""
GM.Website = "https://github.com/cfc-servers/raft_v_raft"

RVR = RVR or {}

AddCSLuaFile( "load_config.lua" )
AddCSLuaFile( "load_modules.lua" ) 
include( "load_config.lua" )
include( "load_modules.lua" )
