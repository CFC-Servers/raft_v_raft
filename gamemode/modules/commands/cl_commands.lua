local function consoleCommandAutoComplete( cmd, stringArgs )
    local args = processArguments( string.lower( stringArgs ) )
    local command = table.remove( args, 1 )

    local suggestions = {}

    for i = 1, #args - 1 do
        command = command .. " " .. args[i]
    end

    for _, ply in pairs( player.GetAll() ) do
        local plyNick = ply:Nick()

        if string.find( string.lower( plyNick ), arg ) then
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
