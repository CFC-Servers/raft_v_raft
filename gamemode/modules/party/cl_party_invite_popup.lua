RVR.Party = RVR.Party or {}
local party = RVR.Party

local backgroundMat = Material( "rvr/backgrounds/party_invite_popup_background.png" )
local backgroundAspectRatio = backgroundMat:Height() / backgroundMat:Width()

local foregroundMat = Material( "rvr/backgrounds/party_invite_popup_foreground.png" )
local foregroundAspectRatio = foregroundMat:Height() / foregroundMat:Width()

local buttonBackgroundMat = Material( "rvr/backgrounds/party_invite_popup_button_background.png" )
local buttonBackgroundAspectRatio = buttonBackgroundMat:Width() / buttonBackgroundMat:Height()

local blacklist = {}

hook.Add( "RVR_Party_gotInvite", "RVR_ShowPopup", function( partyID, inviter )
    local partyData = RVR.Party.getParty( partyID )
    if not partyData then return end
    if RVR.MainMenu.frame then return end
    if blacklist[partyData.id] then return end

    party.createInvitePopup( partyData, inviter )
end )

local function makeLabel( text, y, parent, color )
    color = color or RVR.MainMenu.darkBrown

    local label = vgui.Create( "DLabel", parent )
    label:SetFont( "RVR_PartyInviteLabel" )
    label:SetText( text )
    label:SetTextColor( color )
    label:SizeToContentsX()
    label:SetTall( ScrH() * 0.02 )
    label:SetPos( 0, y - ScrH() * 0.01 )
    label:CenterHorizontal()

    return label
end

local function makeButton( text, x, y, h, frame, callback )
    local w = h * buttonBackgroundAspectRatio

    local btn = vgui.Create( "DButton", frame )
    btn:SetFont( "RVR_PartyInviteLabel" )
    btn:SetText( text )
    btn:SetTextColor( RVR.MainMenu.darkBrown )
    btn:SetSize( w, h )
    btn:SetPos( x - w * 0.5, y - h * 0.5 )

    function btn:Paint( _w, _h )
        surface.SetMaterial( buttonBackgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    function btn:DoClick()
        frame:Remove()
        if callback then callback() end
    end

    return btn
end

function party.createInvitePopup( partyData, inviter )
    surface.PlaySound( "garrysmod/balloon_pop_cute.wav" )

    local w = ScrW() * 0.23
    local h = w * backgroundAspectRatio

    local x, y = 0, party.menuY - h - ScrH() * 0.05

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:SetDraggable( false )
    frame:SetPos( x, y )
    frame:SetSize( w, h )

    local removeTime = CurTime() + GAMEMODE.Config.Party.INVITE_COOLDOWN

    function frame:Paint( _w, _h )
        surface.SetMaterial( backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    local innerPadding = ScrW() * 0.005

    local innerW = w - innerPadding * 2
    local innerH = innerW * foregroundAspectRatio * 0.8

    local innerPanel = vgui.Create( "DPanel", frame )
    innerPanel:SetPos( innerPadding, innerPadding )
    innerPanel:SetSize( innerW, innerH )

    function innerPanel:Paint( _w, _h )
        surface.SetMaterial( foregroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    makeLabel( inviter:Nick(), innerH * 0.2, innerPanel )
    makeLabel( " has invited you to ", innerH * 0.5, innerPanel )
    makeLabel( partyData.name .. " [" .. partyData.tag .. "]", innerH * 0.8, innerPanel, partyData.color )

    local buttonSectionTop = innerH + innerPadding + innerH * 0.2
    local buttonSectionH = h - buttonSectionTop

    local timerLabel = makeLabel( "", buttonSectionTop - innerH * 0.02, frame )
    function timerLabel:Think()
        local timeLeft = math.ceil( removeTime - CurTime() )
        self:SetText( tostring( timeLeft ) )
        self:SizeToContentsX()
        self:CenterHorizontal()
    end

    local buttonY = buttonSectionTop + buttonSectionH * 0.5

    makeButton( "Deny", w * 0.15, buttonY, buttonSectionH * 0.6, frame )
    makeButton( "Accept", w * 0.5, buttonY, buttonSectionH * 0.6, frame, function()
        RunConsoleCommand( "rvr", "party_join", partyData.id )
    end )
    makeButton( "Ignore", w * 0.85, buttonY, buttonSectionH * 0.6, frame, function()
        blacklist[partyData.id] = true
    end )

    timer.Simple( GAMEMODE.Config.Party.INVITE_COOLDOWN, function()
        frame:Remove()
    end )
end
