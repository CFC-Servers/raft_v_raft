local addFunctions = {
    vmt = resource.AddFile,
    mdl = resource.AddFile,
    png = resource.AddSingleFile,
}

local function addDirectory( dir )
    local files, dirs = file.Find( dir .. "/*", "GAME" )
    if not files then return end

    for _, fileName in pairs( files ) do
        local ext = string.match( fileName, "^.+%.(%a+)$" )
        local addFunc = addFunctions[ext]
        if addFunc then
            addFunc( dir .. "/" .. fileName )
        end
    end

    for _, dirName in pairs( dirs ) do
        addDirectory( dir .. "/" .. dirName )
    end
end

addDirectory( "materials/models/rvr" )
addDirectory( "materials/rvr" )
addDirectory( "models/rvr" )
