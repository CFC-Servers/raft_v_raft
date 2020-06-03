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

net.Receive( "RVR_Player_Take_Drown_Damage", function()
    LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 255, 15 ), 1, 0.1 )
end )

local function renderDrowningElement()
    -- TODO: Add HUD elements for drowning
end

hook.Add( "HUDPaint", "RVR_Render_Drowning_Element", renderDrowningElement )
