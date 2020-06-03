local configDir = GM.FolderName.."/gamemode/config/"
local files, _ = file.Find( configDir.."*", "LUA" )

for _, file in pairs( files ) do 
    local path = configDir .. file
    AddCSLuaFile( path )
    include( path )
end

hook.Run( "RVR_ConfigLoaded" )
