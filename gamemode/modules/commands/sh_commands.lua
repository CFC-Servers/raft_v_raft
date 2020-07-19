RVR.Commands = RVR.Commands or {}

function RVR.Commands.processArguments( argsStr, keepQuotes )
    argsStr = string.Trim( argsStr )

    local args = {}
    local str = ""
    local insideQuotes = false
    local i = 1

    while i <= string.len( argsStr ) do
        local char = argsStr[i]

        if char == "\"" then
            insideQuotes = not insideQuotes

            if keepQuotes then
                str = str .. char
            end
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
