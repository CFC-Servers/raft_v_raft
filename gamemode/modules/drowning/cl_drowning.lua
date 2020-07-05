local drownTimeStart
local shouldDrawDrowningElement = false

local barForeground = Material( "rvr/backgrounds/oxygen_bar_foreground.png" )
local barBackground = Material( "rvr/backgrounds/oxygen_bar_background.png" )

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
    if not shouldDrawDrowningElement then return end

    local timePassed = CurTime() - drownTimeStart
    local prog = timePassed / GAMEMODE.Config.Drowning.DROWNING_THRESHOLD

    local hotbarFrame = RVR.Inventory.hotbar.frame
    local x, y = hotbarFrame:GetPos()
    local w = hotbarFrame:GetWide()
    local wToRemove = 40

    w = w - wToRemove
    x = x + wToRemove * 0.5

    local h = w * ( 58 / 808 ) * 0.6
    y = y - h - 10

    surface.SetDrawColor( Color( 255, 255, 255 ) )
    surface.SetMaterial( barBackground )
    surface.DrawTexturedRect( x, y, w, h )

    surface.SetMaterial( barForeground )
    surface.DrawTexturedRect( x + 2, y + 2, ( w - 4 ) * ( 1 - prog ), h - 4 )
end

hook.Add( "HUDPaint", "RVR_Render_Drowning_Element", renderDrowningElement )
