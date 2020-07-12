RVR.Party = RVR.Party or {}
local party = RVR.Party
party.menuEnabled = true

local bgMat = Material( "rvr/backgrounds/party_menu_player.png" )
local bgMatOwner = Material( "rvr/backgrounds/party_menu_owner.png" )
local aspectRatio = bgMat:Height() / ( bgMat:Width() * 1.2 )

local buttonBgMat = Material( "rvr/backgrounds/party_menu_dropdown_background.png" )
local buttonAspectRatio = buttonBgMat:Height() / buttonBgMat:Width()

local dropDownEnabledMat = Material( "rvr/icons/craftingmenu_dropdownopen.png" )
local dropDownDisabledMat = Material( "rvr/icons/craftingmenu_dropdownclosed.png" )

local yellow = Color( 188, 162, 105 )
local brown = Color( 91, 56, 34 )

surface.CreateFont( "RVR_PartyNameLabel", {
    font = "Bungee Regular",
    size = ScrH() * 0.04,
    weight = 700,
} )

hook.Add( "RVR_Party_PartyChanged", "RVR_Party_Menu", function( id, data )
    timer.Simple( 0.2, party.reloadMenu )
end )

function party.reloadMenu()
    if party.menu then
        party.menu:Remove()
    end

    local partyData = LocalPlayer():GetParty()

    if not partyData then return end

    local partyFull = #partyData.members == GAMEMODE.Config.Party.MAX_PLAYERS

    local topMargin = 5
    local w = ScrW() * 0.17
    local elemH = w * aspectRatio
    local h = ( elemH + topMargin ) * ( #partyData.members + ( partyFull and 0.5 or 1 ) )

    party.menu = vgui.Create( "DFrame" )
    party.menu:SetTitle( "" )
    party.menu:ShowCloseButton( false )
    party.menu:SetDraggable( false )
    party.menu:SetPos( 0, ScrH() * 0.35 )
    party.menu:SetSize( w, h )
    party.menu:DockPadding( 0, 0, 0, 0 )
    party.menu.Paint = nil

    local btn = vgui.Create( "DButton", party.menu )
    btn:SetText( "" )
    btn:SetSize( ( elemH * 0.5 ) / buttonAspectRatio, elemH * 0.5 )
    function btn:Paint( _w, _h )
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( buttonBgMat )
        surface.DrawTexturedRect( 0, 0, _w, _h )

        surface.SetMaterial( party.menuEnabled and dropDownEnabledMat or dropDownDisabledMat )
        local iconW, iconH = dropDownEnabledMat:Width() * 0.75, dropDownEnabledMat:Height() * 0.75
        surface.DrawTexturedRect( ( _w - iconW ) * 0.5, ( _h - iconH ) * 0.5 + 2, iconW, iconH )
    end

    function btn:DoClick()
        party.menuEnabled = not party.menuEnabled
    end

    local containerH = ( elemH + topMargin ) * ( #partyData.members + ( partyFull and 0 or 0.5 ) )

    local superContainer = vgui.Create( "DPanel", party.menu )
    superContainer:Dock( TOP )
    superContainer:DockMargin( 0, ( elemH + topMargin ) * 0.5, 0, 0 )
    superContainer.Paint = nil
    superContainer.prog = party.menuEnabled and 1 or 0
    function superContainer:Think()
        if self.prog < 1 and party.menuEnabled then
            self.prog = math.Clamp( self.prog + FrameTime() * 5, 0, 1 )
        elseif self.prog > 0 and not party.menuEnabled then
            self.prog = math.Clamp( self.prog - FrameTime() * 5, 0, 1 )
        end


        self:SetTall( self.prog * containerH )
    end

    local container = vgui.Create( "DPanel", superContainer )
    container:Dock( BOTTOM )
    container:SetTall( containerH )
    container.Paint = nil

    local selfIsOwner = LocalPlayer() == partyData.owner

    for _, v in pairs( partyData.members ) do
        local isOwner = v == partyData.owner

        local playerPanel = vgui.Create( "DPanel", container )
        playerPanel:Dock( TOP )
        playerPanel:DockMargin( 0, 0, 0, topMargin )
        playerPanel:SetTall( elemH )
        function playerPanel:Paint( _w, _h )
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( isOwner and bgMatOwner or bgMat )
            surface.DrawTexturedRect( 0, 0, _w, _h )
        end

        local label = vgui.Create( "DLabel", playerPanel )
        label:Dock( FILL )
        label:DockMargin( 10, 10, 0, 10 )
        label:SetFont( "RVR_PartyNameLabel" )
        label:SetTextColor( isOwner and yellow or brown )
        label:SetText( v:Nick() )

        local isSelf = v == LocalPlayer()

        if not isOwner and not selfIsOwner and not isSelf then continue end
        local leaveButton = isSelf and not isOwner

        local icon = vgui.Create( "DImage", playerPanel )
        icon:Dock( RIGHT )
        icon:DockMargin( 10, 10, 10, 10 )
        icon:SetImage( isOwner and "rvr/icons/party_menu_crown.png" or "rvr/icons/party_menu_cross.png" )
        icon:SetMouseInputEnabled( true )

        function icon:PerformLayout()
            self:SetWide( self:GetTall() )
        end

        if not isOwner then
            icon:SetCursor( "hand" )
            function icon:OnMousePressed()
                if self.pressed then return end
                self.pressed = true

                self:Remove()

                if leaveButton then
                    RunConsoleCommand( "say", "!party_leave" )
                else
                    net.Start( "RVR_Party_kickPlayer" )
                    net.WriteEntity( v )
                    net.SendToServer()
                end
            end
        end
    end

    if partyFull then return end

    local buttonH = ( elemH + topMargin ) * 0.5 - 10
    local horizontalPadding = ( w - buttonH ) * 0.5

    local inviteBtn = vgui.Create( "DButton", container )
    inviteBtn:SetText( "" )
    inviteBtn:Dock( TOP )
    inviteBtn:DockMargin( horizontalPadding, 0, horizontalPadding, 10 )

    function inviteBtn:PerformLayout()
        self:SetTall( self:GetWide() )
    end

    local plusWidth = 4
    function inviteBtn:Paint( _w, _h )
        local offset = ( _w - plusWidth ) * 0.5
        surface.SetDrawColor( brown )
        surface.DrawRect( offset, 0, plusWidth, _h )
        surface.DrawRect( 0, offset, _w, plusWidth )
    end

    function inviteBtn:DoClick()
        local inviteMenu = DermaMenu()
        local someoneAdded = false
        for _, ply in pairs( player.GetHumans() ) do
            if not ply:IsInSameParty( LocalPlayer() ) then
                inviteMenu:AddOption( ply:Nick(), function()
                    net.Start( "RVR_Party_invitePlayer" )
                    net.WriteEntity( ply )
                    net.SendToServer()
                end )
                someoneAdded = true
            end
        end

        if not someoneAdded then
            inviteMenu:AddOption( "There's no players to add!" )
        end
        inviteMenu:Open()
    end
end
