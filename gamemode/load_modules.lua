local moduleDir = GM.FolderName.."/gamemode/modules/"

local _, modules = file.Find( moduleDir.."*", "LUA" )

for _, moduleName in pairs( ENABLED_MODULES ) do
    local path = moduleDir..moduleName.."/"
    local files, _ = file.Find( path.."*.lua", "LUA" )
    
    for _, file in pairs( files ) do
        local fullPath = path..file
        if CLIENT then
            include( fullPath )
        elseif string.StartWith( file, "sh_" ) then
            include( fullPath )
            AddCSLuaFile( fullPath )
        elseif string.StartWith( file, "sv_" ) then
            include( fullPath )
        elseif string.StartWith( file, "cl_" ) then
            AddCSLuaFile( fullePath )
        end
    end
end

hook.Run( "RVR_ModulesLoaded" )
