local checkmark = Material( "rvr/icons/checkmark.png" )

net.Receive( "RVR_PlayerDeath", function()
    hook.Run( "RVR_PlayerDeath", net.ReadEntity(), net.ReadEntity(), net.ReadEntity() )
end )

net.Receive( "RVR_SuccessfulPlayerSpawn", function()
    hook.Run( "RVR_SuccessfulPlayerSpawn", net.ReadEntity() )
end )

hook.Add( "HUDShouldDraw", "RVR_HideDeathTint", function( hudType )
    if hudType == "CHudDamageIndicator" then
        return false
    end
end )

hook.Add( "RVR_Inventory_HotbarCanScroll", "RVR_PlayerDeath", function()
    if not LocalPlayer():Alive() then return false end
end )

local function drawCircle( x, y, radius, seg, startAng, angRange )
    local cir = {}

    startAng = startAng or 0
    angRange = angRange or 360

    if angRange == 360 then
        table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    end

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( -startAng + ( i / seg ) * -angRange )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    surface.DrawPoly( cir )
end

hook.Add( "HUDPaint", "RVR_PlayerDeathScreen", function()
    if not hook.Run( "HUDShouldDraw", "RVR_PlayerDeath" ) then return end
    local ply = LocalPlayer()

    if ply:Alive() or not ply.RVR_NextRespawn then return end

    local timeLeft = math.max( ply.RVR_NextRespawn - CurTime(), 0 )

    local ratio = math.Clamp( timeLeft / GAMEMODE.Config.PlayerDeath.RESPAWN_TIME, 0, 1 )

    local hotbarFrame = RVR.Inventory.hotbar.frame
    local _, hotbarY = hotbarFrame:GetPos()

    local radius = ScrH() * 0.05
    local iconX, iconY = ScrW() * 0.5, hotbarY - radius - 20

    surface.SetDrawColor( Color( 30, 30, 30, 180 ) )
    drawCircle( iconX, iconY, radius, 50 )

    local hue = 100 * ( 1 - math.Clamp( ratio * 2, 0, 1 ) )

    surface.SetDrawColor( HSVToColor( hue, 1, 1 ) )
    drawCircle( iconX, iconY, radius, 50, 180, ( 1 - ratio ) * -360 )

    local checkmarkSize = 0.7

    if timeLeft > 0 then
        surface.SetTextColor( 255, 255, 255 )
        surface.SetFont( "RVR_CraftingHeader" )
        local text = tostring( math.ceil( timeLeft ) )
        local textW, textH = surface.GetTextSize( text )
        surface.SetTextPos( iconX - textW * 0.5, iconY - textH * 0.5 )
        surface.DrawText( text )
    else
        surface.SetMaterial( checkmark )
        surface.SetDrawColor( 255, 255, 255 )
        surface.DrawTexturedRect( iconX - radius * checkmarkSize, iconY - radius * checkmarkSize,
            radius * checkmarkSize * 2, radius * checkmarkSize * 2 )
    end
end )

hook.Add( "HUDPaintBackground", "RVR_PlayerDeathScreen", function()
    if LocalPlayer():Alive() then return end
    if not hook.Run( "HUDShouldDraw", "RVR_DeathTint" ) then return end
    surface.SetDrawColor( 255, 0, 0, 70 )
    surface.DrawRect( 0, 0, ScrW(), ScrH() )
end )
