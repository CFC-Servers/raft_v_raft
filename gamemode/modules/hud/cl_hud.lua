local config = GM.Config.Hunger
local stats = {
    {
        material = Material( "icons/water.png" ),
        color = Color( 138, 138, 230 ),
        get  = function()
            return  LocalPlayer():GetWater()
        end,
        max = config.MAX_WATER,
    },
    {
        material = Material( "icons/food.png" ),
        color = Color( 181, 114, 60 ),
        get = function()
            return LocalPlayer():GetFood()
        end,
        max = config.MAX_FOOD,
    },
    {
        material = Material( "rvr/icons/health.png" ),
        color = Color( 227, 100, 100 ),
        get = function()
            return LocalPlayer():Health()
        end,
        max = 100,
    }
}

-- TODO widths and heights should scale with screen resolution
function GM:HUDPaint()
    local x = 0
    local y = ScrH() - 5 - 35 * #stats
    draw.RoundedBox( 2, x, y, 320, 35 * #stats + 5, Color( 50, 50, 50, 190 ) )

    for i, stat in ipairs( stats ) do
        local width = 272
        local height = 30
        width = width * stat.get() / stat.max
        local x = 40
        local y = ScrH() - 35 * i

        draw.RoundedBox( 2, x, y, width, height, stat.color )
        if stat.material then
            surface.SetMaterial( stat.material )
        end

        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 5, y, 30, 30 )
    end
end

local isHidden = { ["CHudHealth"] = true, ["CHudBattery"] = true, ["CHudAmmo"] = true, ["CHudSecondaryAmmo"] = true }
function GM:HUDShouldDraw( name )
    if isHidden[name] then return false end

    return self.BaseClass.HUDShouldDraw( self, name )
end
