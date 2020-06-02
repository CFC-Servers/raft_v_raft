local drownTimeStart
local shouldDrawDrowningElement = false

net.Receive( "RVR_Player_Enter_Water", function()
    local time = net.ReadFloat()

    drownTimeStart = time
    shouldDrawDrowningElement = true
end )

net.Receive( "RVR_Player_Leave_Water", function()
    shouldDrawDrowningElement = false
end )

local function renderDrowningElement()

end

hook.Add( "HUDPaint", "RVR_Render_Drowning_Element", renderDrowningElement )
