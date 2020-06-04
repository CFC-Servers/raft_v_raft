util.AddNetworkString( "RVR_Commands_runConsoleCommand" )

RVR.Commands = RVR.Commands or {}
local commands = RVR.Commands

commands.list = {}
commands.types = {}

function commands.addType( name, func )
    if commands.types[name] then
        error( "A type with the same name (" .. name .. ") already exists" )
    end

    commands.types[name] = func
end

commands.addType( "int", function( arg )
    local num = tonumber( arg )

    if not num or num % 1 ~= 0 then
        return nil, "Invalid integer: " .. arg
    end

    return num
end )

commands.addType( "float", function( arg )
    local num = tonumber( arg )

    if not num then
        return "Invalid float: " .. arg
    end

    return num
end )

local booleanValues = {
    ["enabled"]  = true,
    ["enable"]   = true,
    ["true"]     = true,
    ["yes"]      = true,
    ["1"]        = true,

    ["disabled"] = false,
    ["disable"]  = false,
    ["false"]    = false,
    ["no"]       = false,
    ["0"]        = false
}

commands.addType( "bool", function( arg )
    if booleanValues[arg] ~= nil then
        return booleanValues[arg]
    end

    return nil, "Invalid boolean: " .. arg
end )

commands.addType( "string", function( arg )
    return arg
end )

commands.addType( "player", function( arg )
    local isSteamID = string.find( arg, "STEAM_" )

    if isSteamID then
        local ply = player.GetBySteamID( arg )

        if ply then
            return ply
        else
            return nil, "Invalid player: " .. arg
        end
    end

    for _, ply in pairs( player.GetAll() ) do
        if string.find( ply:Nick(), arg ) then return ply end
    end

    return nil, "Invalid player: " .. arg
end )

function commands.checkArguments( argNames, argTypes, args )
    if #args < #argTypes then
        local commandHelp = ""

        for i, argName in ipairs( argNames ) do
            local argType = argTypes[i]

            commandHelp = commandHelp .. argName .. ":" .. argType
        end

        return nil, "Missing argument: " .. commandHelp
    end

    local newArgs = {}

    for i, arg in ipairs( args ) do
        local argType = argTypes[i]

        local value, errorMsg = commands.types[argType]( arg )

        if errorMsg then
            return nil, errorMsg
        end

        newArgs[#newArgs + 1] = value
    end

    return newArgs
end

local function processArguments( argsStr )
    argsStr = string.Trim( argsStr )

    local args = {}
    local str = ""

    local insideQuotes = false

    local i = 1

    while i <= string.len( argsStr ) do
        local char = string.sub( argsStr, i, i )

        if char == "\"" then
            insideQuotes = not insideQuotes
        elseif char == "\\" then
            i = i + 1

            char = string.sub( argsStr, i, i )
            str = str .. char
        elseif char == " " and not insideQuotes then
            table.insert( args, str )
            str = ""
        else
            str = str .. char
        end

        i = i + 1
    end

    if str ~= "" then
        table.insert( args, str )
    end

    return args
end

local function processCommand( ply, command, args )
    local commandInfo = commands.list[command]

    if commandInfo then
        if not RVR.isUserGroup( ply, commandInfo.userGroup ) then
            return "You need to be " .. RVR.getGroupName( commandInfo.userGroup ) .. " to use this command"
        end

        local newArgs, errorMsg = commands.checkArguments( commandInfo.argNames, commandInfo.argTypes, args )

        if errorMsg then
            return errorMsg, true
        end

        local msg = commandInfo.func( ply, unpack( newArgs ) )

        return msg, true
    end
end

function commands.register( names, argNames, argTypes, userGroup, func, desc )
    if #argNames ~= #argTypes then
        error( "There must be the same amount of argument names and types" )
    end

    if type( names ) == "string" then
        names = { names }
    end

    for _, name in ipairs( names ) do
        if commands.list[name] then
            error( "A command with the same name (" .. name .. ") already exists" )
        end

        for _, argType in ipairs( argTypes ) do
            if not commands.types[argType] then
                error( "\"" .. argType .. "\" is not a valid argument type" )
            end
        end

        local description = "Usage: " .. name

        for i, argName in ipairs( argNames ) do
            local argType = argTypes[i]

            description = description .. " " .. argName .. ":" .. argType
        end

        if desc then
            description = description .. "\nDescription: " .. desc
        end

        commands.list[name] = {
            argNames = argNames,
            argTypes = argTypes,
            userGroup = userGroup,
            func = func,
            description = description
        }
    end
end

local function onPlayerSay( ply, text )
    if string.sub( text, 1, 1 ) ~= "!" then return end

    text = string.sub( text, 2 )

    local args = processArguments( text )
    local command = table.remove( args, 1 )

    local msg, validCommand = processCommand( ply, command, args )

    if msg then
        ply:ChatPrint( msg )
    end

    if not validCommand then
        ply:ChatPrint( "Command \"" .. command .. "\" does not exist" )
    else
        return ""
    end
end

hook.Add( "PlayerSay", "RVR_Commands_onPlayerSay", onPlayerSay )

local function onRunConsoleCommand( len, ply )
    local argsStr = net.ReadString()

    local args = processArguments( argsStr )
    local command = table.remove( args, 1 )

    local msg, validCommand = processCommand( ply, command, args )

    if msg then
        ply:PrintMessage( HUD_PRINTCONSOLE, msg )
    end

    if not validCommand then
        ply:PrintMessage( HUD_PRINTCONSOLE, "Command \"" .. command .. "\" does not exist" )
    end
end

net.Receive( "RVR_Commands_runConsoleCommand", onRunConsoleCommand )

commands.register( "help", {"command"}, {"string"}, RVR_USER_ALL, function( command )
    if not commands.list[command] then
        return "Help: Command \"" .. command .. "\" does not exist"
    end

    return commands.list[command].description
end, "Prints the usage and description of a command" )