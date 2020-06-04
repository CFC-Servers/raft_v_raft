local function processArguments( argsStr )
    local args = {}
    local str = ""

    local insideQuotes = false

    local i = 1

    while i <= string.len( argsStr ) do
        local char = argsStr[i]

        if char == "\"" then
            insideQuotes = not insideQuotes
        elseif char == "\\" then
            i = i + 1

            char = string.sub( argsStr, i, i )
            str = str .. char
        elseif char == " " and not insideQuotes then
            args[#args + 1] = str
            str = ""
        else
            str = str .. char
        end

        i = i + 1
    end

    return args
end

local function consoleCommandAutoComplete( cmd, stringArgs )
    local args = processArguments( string.lower( stringArgs ) )
    local command = table.remove( args, 1 )

    if #args < 2 then return end

    local suggestions = {}

    for i = 1, #args - 1 do
        command = command .. " " .. args[i]
    end

    for _, ply in pairs( player.GetAll() ) do
        local plyNick = ply:Nick()

        if string.find( string.lower( plyNick ), args[#args] ) then
            suggestions[#suggestions + 1] = suggestion .. " \"" .. plyNick .. "\""
        end
    end
end

local function onConsoleCommand( ply, cmd, args, argsStr )
    net.Start( "RVR_Commands_runConsoleCommand" )
    net.WriteString( argsStr )
    net.SendToServer()
end

concommand.Add( "rvr", onConsoleCommand, consoleCommandAutoComplete, "Usage: help command:string\nDescription: Run special commands from the Raft V Raft gamemode" )
