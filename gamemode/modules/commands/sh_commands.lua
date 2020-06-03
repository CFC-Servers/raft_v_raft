RVR.Commands = RVR.Commands or {}
local commands = RVR.Commands

commands.list = {}

local validArgTypes = {
    ["number"] = true,
    ["string"] = true,
    ["player"] = true
}

local function isNumber( str )
    if not string.find( str, "[0-9]+" ) then return end

    return tonumber( str )
end

local function isPlayer( str )
    local isSteamID = string.find( str, "STEAM_" )

    if isSteamID then
        local ply = player.GetBySteamID( str )

        if ply then
            return ply
        else
            return false
        end
    end

    for _, ply in pairs( player.GetAll() ) do
        if string.find( ply:Nick(), str ) then return ply end
    end

    return false
end

function commands.checkArguments( argTypes, args )
    if #args < #argTypes then
        local commandHelp = ""

        for _, argType in ipairs( argTypes ) do
            commandHelp = commandHelp .. "<" .. argType .. "> "
        end

        return nil, "Missing argument: " .. commandHelp
    end

    local newArgs = {}

    for i = 1, #argTypes do
        local argType = argTypes[i]
        local arg = args[i]

        if argType == "number" then
            local number = isNumber( arg )

            if not number then
                return nil, "Invalid number \"" .. arg .. "\""
            end

            newArgs[#newArgs + 1] = number
        elseif argType == "player" then
            local ply = isPlayer( arg )

            if not ply then
                return nil, "Invalid player \"" .. arg .. "\""
            end

            newArgs[#newArgs + 1] = ply
        else
            newArgs[#newArgs + 1] = arg
        end
    end

    return newArgs
end

local function consoleCommandAutoComplete( cmd, stringArgs )
    stringArgs = string.Trim( stringArgs )
    stringArgs = string.lower( stringArgs )

    local tbl = {}

    for k, v in pairs( player.GetAll() ) do
        local nick = v:Nick()

        if string.find( string.lower( nick ), stringArgs ) then
            nick = "\"" .. nick .. "\""
            nick = cmd .. " " .. nick

            table.insert( tbl, nick )
        end
    end

    return tbl
end

local function onConsoleCommand( ply, cmd, args )
    local command = string.gsub( cmd, "rvr_", "" )

    local commandInfo = commands.list[command]

    if commandInfo then
        local newArgs, errorMessage = commands.checkArguments( commandInfo.argTypes, args )

        if errorMessage then
            ply:PrintMessage( HUD_PRINTCONSOLE, errorMessage )
            return
        end

        commandInfo.func( unpack( newArgs ) )

        ply:PrintMessage( HUD_PRINTCONSOLE, "Sucessfully ran command!" )
    end
end

function commands.register( name, argTypes, func, desc )
    if commands.list[name] then
        error( "A command with the same name (" .. name .. ") already exists" )
    end

    for _, argType in ipairs( argTypes ) do
        if not validArgTypes[argType] then
            error( "\"" .. argType .. "\" is not a valid argument type" )
        end
    end

    commands.list[name] = {
        argTypes = argTypes,
        func = func
    }

    concommand.Add( "rvr_" .. name, onConsoleCommand, consoleCommandAutoComplete, desc )
end

if SERVER then
    local function onPlayerSay( ply, text )
        if string.sub( text, 1, 1 ) ~= "!" then return end

        text = string.sub( text, 2 )

        local args = string.Explode( " ", text )
        local command = table.remove( args, 1 )

        local commandInfo = commands.list[command]

        if commandInfo then
            local newArgs, errorMessage = commands.checkArguments( commandInfo.argTypes, args )

            if errorMessage then
                ply:ChatPrint( errorMessage )
                return ""
            end

            commandInfo.func( unpack( newArgs ) )

            ply:ChatPrint( "Sucessfully ran command!" )
            return ""
        end
    end

    hook.Add( "PlayerSay", "RVR_Commands_onPlayerSay", onPlayerSay )
else
    local function onPlayerChat( ply, text )
        if string.sub( text, 1, 1 ) ~= "!" then return end

        text = string.sub( text, 2 )

        local args = string.Explode( " ", text )
        local command = table.remove( args, 1 )

        local commandInfo = commands.list[command]

        if commandInfo then
            local newArgs, errorMessage = commands.checkArguments( commandInfo.argTypes, args )

            if errorMessage then
                ply:ChatPrint( errorMessage )
                return true
            end

            commandInfo.func( unpack( newArgs ) )

            ply:ChatPrint( "Sucessfully ran command!" )
            return true
        end
    end

    hook.Add( "OnPlayerChat", "RVR_Commands_onPlayerChat", onPlayerChat )
end
