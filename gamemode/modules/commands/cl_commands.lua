local function consoleCommandAutoComplete( cmd, stringArgs )
    stringArgs = string.Trim( string.lower( stringArgs ) )
    local args = RVR.Commands.processArguments( stringArgs, true )
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
