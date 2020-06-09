local function runRecurse( dir, ext, f )
    local files, dirs = file.Find( dir .. "/*", "GAME" )
    if not files then return end
    for k, v in pairs( files ) do
        if string.match( v, "^.+%." .. ext .. "$" ) then
            f( dir .. "/" .. v )
        end
    end
    for k, v in pairs( dirs ) do
        runRecurse( dir .. "/" .. v, ext, f )
    end
end

runRecurse( "materials/models/rvr", "vmt", resource.AddFile )
runRecurse( "materials/rvr", "png", resource.AddSingleFile )
runRecurse( "models/rvr", "mdl", resource.AddFile )
