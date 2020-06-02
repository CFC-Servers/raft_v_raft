local stats = {
    {
        color = Color(138, 138, 230),
        get  = function()
            return  LocalPlayer():GetWater()
        end,
        max = 100,
    },

    {
        color = Color(181, 114, 60),
        get = function()
            return LocalPlayer():GetFood()
        end,
        max = 100,
    },

    {   name = "health",
        material = Material( "icons/health.png" ),
        color = Color(227, 100, 100),
        get = function()
            return LocalPlayer():Health()
        end,
        max = 100,

    },
}
function GM:HUDPaint()

    draw.RoundedBox( 2, 0, 1070-35*#stats-5, 312, 35*#stats+5, Color(50, 50, 50, 150) ) 

    for i, stat in ipairs(stats) do
        local width = 272
        width = width * stat.get() / stat.max
        draw.RoundedBox( 2, 35, 1070-35*i, width, 30, stat.color ) 
        if stat.material then
            surface.SetMaterial(stat.material)
        end
        surface.SetDrawColor(Color(255,255,255))
        surface.DrawTexturedRect( 5, 1070-35*i, 30, 30 )
    end
end

local isHidden = {["CHudHealth"] = true, ["CHudBattery"] = true, ["CHudAmmo"] = true, ["CHudSecondaryAmmo"] = true}
function GM:HUDShouldDraw(name)
    if isHidden[name] then return false end

    return self.BaseClass.HUDShouldDraw( self, name )
end


