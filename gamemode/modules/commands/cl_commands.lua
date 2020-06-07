local function processArguments( argsStr )
    local args = {}
    local str = ""

    local insideQuotes = false

    local i = 1

    while i <= string.len( argsStr ) do
        local char = argsStr[i]

        if char == "\"" then
            insideQuotes = not insideQuotes
            str = str .. char
        elseif char == "\\" then
            i = i + 1

            char = argsStr[i]
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

local function consoleCommandAutoComplete( cmd, stringArgs )
    stringArgs = string.Trim( string.lower( stringArgs ) )
    local args = processArguments( stringArgs )
    local command = table.remove( args, 1 )

    if not command or #args < 1 then return end

    command = "rvr " .. command

    local suggestions = {}

    for i = 1, #args - 1 do
        command = command .. " " .. args[i]
    end

    for _, ply in pairs( player.GetAll() ) do
        local plyNick = ply:Nick()

        if string.find( string.lower( plyNick ), args[#args] ) then
            table.insert( suggestions, command .. " \"" .. plyNick .. "\"" )
        end
    end

    return suggestions
end

local function onConsoleCommand( ply, cmd, args, argsStr )
    net.Start( "RVR_Commands_runConsoleCommand" )
    net.WriteString( argsStr )
    net.SendToServer()
end

concommand.Add( "rvr", onConsoleCommand, consoleCommandAutoComplete, "Usage: help command:string\nDescription: Run special commands from the Raft V Raft gamemode" )
