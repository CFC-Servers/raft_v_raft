util.AddNetworkString( "RVR_Commands_runConsoleCommand" )

include( "sh_commands.lua" )

RVR.Commands = RVR.Commands or {}
local commands = RVR.Commands

commands.commands = {}
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
    ["enabled"] = true,
    ["enable"] = true,
    ["true"] = true,
    ["yes"] = true,
    ["1"] = true,

    ["disabled"] = false,
    ["disable"] = false,
    ["false"] = false,
    ["no"] = false,
    ["0"] = false
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

commands.addType( "entity", function( arg, ply )
    if arg == "^" then
        return ply
    end

    local entID, err = commands.types.int( arg, ply )
    if err == nil then
        return Entity( entID ), nil
    end

    if arg == "@" then
        local ent = ply:GetEyeTrace().Entity

        local err = nil
        if not IsValid( ent ) then
            err = "You aren't aiming at a valid entity"
        end

        return ent, err
    end

    return nil, "Not an entity"
end )

commands.addType( "player", function( arg, ply )
    if arg == "^" then
        return ply
    end

    if arg == "@" then
        local target = ply:GetEyeTrace().Entity
        local isValidPlayer = IsValid( target ) and target:IsPlayer()

        if isValidPlayer then
            return target
        end

        return nil, "Not currently aiming at a player!"
    end

    local isSteamID = string.find( arg, "STEAM_" )

    if isSteamID then
        local ply = player.GetBySteamID( arg )

        if ply then
            return ply
        else
            return nil, "Invalid player: " .. arg
        end
    end

    local selectedPlayers = {}
    local playerList = ""

    arg = string.lower( arg )

    for _, ply in pairs( player.GetAll() ) do
        local plyNick = string.lower( ply:Nick() )

        if string.find( plyNick, arg ) then
            table.insert( selectedPlayers, ply )
            playerList = playerList .. "\n" .. plyNick
        end
    end

    if #selectedPlayers > 1 then
        return nil, "\"" .. arg .. "\" matches multiple players:" .. playerList
    elseif #selectedPlayers == 1 then
        return selectedPlayers[1]
    end

    return nil, "Invalid player: " .. arg
end )

RVR.Commands.addType( "color", function( str, caller )
    if str[1] ~= "#" or ( #str ~= 7 and #str ~= 9 ) then
        return nil, "Colors should be in hex, prefixed with a #, e.g. #FF0000 for red"
    end

    local r = tonumber( str:sub( 2, 3 ), 16 )
    local g = tonumber( str:sub( 4, 5 ), 16 )
    local b = tonumber( str:sub( 6, 7 ), 16 )
    local a = 255

    if #str > 7 then
        a = tonumber( str:sub( 7, 8 ), 16 )
    end

    if r and g and b and a then
        return Color( r, g, b, a )
    end

    return nil, "Invalid color string"
end )

function commands.checkArguments( argNames, argTypes, args, ply )
    if #args < #argTypes then
        local commandHelp = ""

        for i, argName in ipairs( argNames ) do
            local argType = argTypes[i]

            commandHelp = commandHelp .. argName .. ":" .. argType .. " "
        end

        return nil, "Missing argument. Usage " .. commandHelp
    end

    local newArgs = {}

    for i, argType in ipairs( argTypes ) do
        local arg = args[i]

        local value, errorMsg = commands.types[argType]( arg, ply )

        if errorMsg then
            return nil, errorMsg
        end

        newArgs[i] = value
    end

    return newArgs
end

local function processCommand( ply, command, args )
    local commandInfo = commands.commands[command]

    if not commandInfo then return end

    if not RVR.isUserGroup( ply, commandInfo.userGroup ) then
        return "You need to be " .. RVR.getGroupName( commandInfo.userGroup ) .. " to use this command"
    end

    local newArgs, errorMsg = commands.checkArguments( commandInfo.argNames, commandInfo.argTypes, args, ply )

    if errorMsg then
        return errorMsg, true
    end

    local msg = commandInfo.func( ply, unpack( newArgs ) )
    return msg, true
end

local function getUsage( name, argNames, argTypes )
    local usage = "Usage: " .. name

    for i, argName in ipairs( argNames ) do
        local argType = argTypes[i]

        usage = usage .. " " .. argName .. ":" .. argType
    end

    return usage
end

function commands.register( names, argNames, argTypes, userGroup, func, desc )
    if #argNames ~= #argTypes then
        error( "There must be the same amount of argument names and types" )
    end

    if type( names ) == "string" then
        names = { names }
    end

    for _, name in ipairs( names ) do
        if commands.commands[name] then
            error( "A command with the same name (" .. name .. ") already exists" )
        end

        for _, argType in ipairs( argTypes ) do
            if not commands.types[argType] then
                error( "\"" .. argType .. "\" is not a valid argument type" )
            end
        end

        local description = getUsage( name, argNames, argTypes )

        if desc then
            description = description .. "\nDescription: " .. desc
        end

        commands.commands[name] = {
            argNames = argNames,
            argTypes = argTypes,
            userGroup = userGroup,
            func = func,
            description = description
        }
    end
end

local function onPlayerSay( ply, text )
    if text[1] ~= "!" then return end

    text = string.sub( text, 2 )

    local args = commands.processArguments( text )
    local command = table.remove( args, 1 ) or ""

    local msg, validCommand = processCommand( ply, command, args )

    if msg then
        ply:ChatPrint( msg )
    end

    if validCommand then
        return ""
    end
end

hook.Add( "PlayerSay", "RVR_Commands_onPlayerSay", onPlayerSay )

local function onRunConsoleCommand( len, ply )
    local argsStr = net.ReadString()

    local args = commands.processArguments( argsStr )
    local command = table.remove( args, 1 ) or ""

    local msg, validCommand = processCommand( ply, command, args )

    if msg then
        ply:PrintMessage( HUD_PRINTCONSOLE, msg )
    end

    if not validCommand then
        ply:PrintMessage( HUD_PRINTCONSOLE, "Command \"" .. command .. "\" does not exist" )
    end
end

net.Receive( "RVR_Commands_runConsoleCommand", onRunConsoleCommand )

local function initializeBaseCommands()
    commands.register( "usage", { "command" }, { "string" }, RVR_USER_ALL, function( ply, command )
        if not commands.commands[command] then
            return "Help: Command \"" .. command .. "\" does not exist"
        end

        return commands.commands[command].description
    end, "Prints the usage and description of a command" )

    commands.register( "help", {}, {}, RVR_USER_ALL, function( ply )
        local plyUserGroup = RVR.getUserGroup( ply )

        ply:PrintMessage( HUD_PRINTCONSOLE, "----- RaftVRaft Commands -----" )

        for commandName, commandData in pairs( commands.commands ) do
            if plyUserGroup < commandData.userGroup then continue end

            local description = commandName .. ":\n" .. commandData.description .. "\n "

            ply:PrintMessage( HUD_PRINTCONSOLE, description )
        end

        ply:PrintMessage( HUD_PRINTCONSOLE, "------------------------------" )

        ply:ChatPrint( "Look in console for a list of commands." )
    end, "Prints a list of all available commands in console" )
end

hook.Add( "RVR_ModulesLoaded", "RVR_Commands_initializeBaseCommands", initializeBaseCommands )
