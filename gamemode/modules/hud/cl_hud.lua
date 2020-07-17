local leftBg = Material( "rvr/backgrounds/hud_background.png" )
local rightBg = Material( "rvr/backgrounds/hud_background_main.png" )

local config = GM.Config.Hunger
local stats = {
    {
        material = Material( "rvr/icons/health.png" ),
        color = Color( 218, 75, 89 ),
        get = function()
            return LocalPlayer():Health()
        end,
        max = 100,
    },
    {
        material = Material( "rvr/icons/water.png" ),
        color = Color( 103, 151, 200 ),
        get = function()
            return LocalPlayer():GetWater()
        end,
        max = config.MAX_WATER,
    },
    {
        material = Material( "rvr/icons/food.png" ),
        color = Color( 172, 131, 35 ),
        get = function()
            return LocalPlayer():GetFood()
        end,
        max = config.MAX_FOOD,
    },
}

local function drawStats()
    local barHeight = ScrH() * 0.04

    local hudHeight = barHeight * #stats
    local leftBgWidth = hudHeight * ( 128 / 300 )

    local x = 5
    local y = ScrH() - hudHeight - 5

    surface.SetDrawColor( Color( 255, 255, 255 ) )

    surface.SetMaterial( leftBg )
    surface.DrawTexturedRect( x, y, leftBgWidth, hudHeight )

    local rightBgWidth = hudHeight * 1.7

    local bgSpacing = 2

    surface.SetMaterial( rightBg )
    surface.DrawTexturedRect( x + leftBgWidth + bgSpacing, y, rightBgWidth, hudHeight )

    for i, stat in ipairs( stats ) do
        local prog = stat.get() / stat.max
        prog = math.Clamp( prog, 0, 1 )

        local barWidth = ( rightBgWidth - 10 ) * prog

        local barX = x + leftBgWidth + bgSpacing + 5
        local barY = y + ( i - 1 ) * barHeight

        local col = stat.color
        local darkCol = Color( col.r * 0.8, col.g * 0.8, col.b * 0.8 )
        draw.RoundedBox( 5, barX, barY + 5, barWidth, barHeight - 10, darkCol )

        draw.RoundedBox( 5, barX + 2, barY + 7, barWidth - 4, barHeight - 14, col )

        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.SetMaterial( stat.material )
        surface.DrawTexturedRect( x + 8, barY + 2, barHeight - 5, barHeight - 5 )
    end
end

function GM:HUDPaint()
    hook.Run( "HUDDrawTargetID" )

    if hook.Run( "HUDShouldDraw", "RVR_Stats" ) then
        drawStats()
    end

    hook.Run( "DrawDeathNotice", 0.85, 0.04 )
end

local isHidden = { ["CHudHealth"] = true, ["CHudBattery"] = true, ["CHudAmmo"] = true, ["CHudSecondaryAmmo"] = true }
function GM:HUDShouldDraw( name )
    if isHidden[name] then return false end

    return self.BaseClass.HUDShouldDraw( self, name )
end

function GM:HUDDrawTargetID()
    local trace = LocalPlayer():GetEyeTrace()
    local aimEnt = trace.Entity

    if not aimEnt or not aimEnt:IsPlayer() then return end

    local range = GAMEMODE.Config.HUD.TARGET_ID_RANGE
    if LocalPlayer():GetShootPos():DistToSqr( trace.HitPos ) > range ^ 2 then return end

    local nickname = aimEnt:Nick()

    local font = "TargetID"

    surface.SetFont( font )
    local nameW = surface.GetTextSize( nickname )

    local x, y = gui.MousePos()

    if x == 0 and y == 0 then
        x = ScrW() / 2
        y = ScrH() / 2
    end

    y = y + 50

    local nameX = x - nameW / 2
    local nameY = y

    draw.SimpleText( nickname, font, nameX + 1, nameY + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( nickname, font, nameX + 2, nameY + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( nickname, font, nameX, nameY, team.GetColor( aimEnt:Team() ) )

    hook.Run( "RVR_TargetID", aimEnt, x, y )
end
