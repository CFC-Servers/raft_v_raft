local moduleDir = GM.FolderName .. "/gamemode/modules/"

local _, modules = file.Find( moduleDir .. "*", "LUA" )

print( "[RVR] Loading modules..." )
for _, moduleName in pairs( modules ) do
    local path = moduleDir .. moduleName .. "/"
    local files, _ = file.Find( path .. "*.lua", "LUA" )
    local isServer = false
    local isClient = false

    for _, fileName in pairs( files ) do
        local fullPath = path .. fileName
        if CLIENT then
            include( fullPath )
        elseif string.StartWith( fileName, "sh_" ) then
            isClient = true
            isServer = true

            include( fullPath )
            AddCSLuaFile( fullPath )
        elseif string.StartWith( fileName, "sv_" ) then
            isServer = true

            include( fullPath )
        elseif string.StartWith( fileName, "cl_" ) then
            isClient = true

            AddCSLuaFile( fullPath )
        end
    end

    if SERVER then
        local realmStr
        if isServer and isClient then
            realmStr = "shared"
        elseif isServer then
            realmStr = "server"
        elseif isClient then
            realmStr = "client"
        else
            print( "[RVR] Warning, empty module: " .. moduleName )
        end

        if realmStr then
            print( "[RVR] Loaded " .. realmStr .. " module: " .. moduleName )
        end
    else
        print( "[RVR] Loaded module: " .. moduleName )
    end
end
print( "[RVR] Finished loading modules" )

hook.Run( "RVR_ModulesLoaded" )
