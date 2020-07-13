RVR.Party = RVR.Party or {}
local party = RVR.Party

util.AddNetworkString( "RVR_Party_kickPlayer" )
util.AddNetworkString( "RVR_Party_invitePlayer" )

-- TODO: Remove ChatPrints, replace with networked events for easier localisation and replacement action (like main menu)
-- ^ Will be done with the main menu, as not yet decided how this would look

local function invitePlayer( caller, ply )
    local partyData = caller:GetParty()

    if not partyData then
        return "You're not in a party"
    end

    local success, err = party.invite( partyData.id, caller, ply )

    if not success then
        return "Failed to invite: " .. err
    end

    -- TODO: Only print if player isnt in main menu, otherwise alert client
    ply:ChatPrint( "You've been invited to " .. partyData.name ..
        ". Use !party_join " .. partyData.name .. " within " .. GAMEMODE.Config.Party.INVITE_LIFETIME .. " seconds to respond.\n" ..
        "WARNING: Accepting an invite will make you leave your current party, along with any items you have" )
    return "Invited " .. ply:Nick() .. " to " .. partyData.name
end

local function joinParty( caller, partyData )
    local success, err = party.attemptJoin( partyData.id, caller )

    if success then
        return "Successfully joined " .. partyData.name
    end

    return err
end

local function leaveParty( caller )
    local partyID = caller:GetPartyID()

    if not partyID then
        return "You're not in a party"
    end

    party.removeMember( partyID, caller )

    return "Successfully left party"
end

local function kickPlayer( caller, ply )
    local partyData = caller:GetParty()

    if not partyData then
        return "You're not in a party"
    end

    if partyData.owner ~= caller then
        return "Only the party owner can kick players"
    end

    if ply == caller then
        return "You can't kick yourself, if you want to leave a party, use !leave"
    end

    if not table.HasValue( partyData.members, ply ) then
        return "This player is not in your party"
    end

    local success, err = party.removeMember( partyData.id, ply )
    if not success then
        return "Failed: " .. err
    end

    ply:ChatPrint( "You have been kicked from " .. partyData.name )

    return "Successfully kicked " .. ply:Nick() .. " from your party"
end

net.Receive( "RVR_Party_kickPlayer", function( len, caller )
    local ply = net.ReadEntity()
    if type( ply ) ~= "Player" then return end

    kickPlayer( caller, ply )
end )

net.Receive( "RVR_Party_invitePlayer", function( len, caller )
    local ply = net.ReadEntity()
    if type( ply ) ~= "Player" then return end

    invitePlayer( caller, ply )
end )

local function createParty( caller, name, tag, color, joinMode )
    if joinMode < 0 or joinMode > 2 then
        return "Invalid join mode, must be 0 (PUBLIC), 1 (STEAM_FRIENDS), or 2 (INVITE_ONLY)"
    end

    local success, err = party.createParty( name, caller, tag, color, joinMode )

    if not success then
        return "Failed to create party: " .. err
    end

    return "Successfully created party " .. name
end

local function setJoinMode( caller, mode )
    local partyData = caller:GetParty()

    if not partyData then
        return "You're not in a party"
    end

    if caller ~= partyData.owner then
        return "Only the party owner can set the join mode"
    end

    local success, err = party.setJoinMode( partyData.id, mode )

    if not success then
        return err
    end

    return "Successfully set the party mode to " .. party.joinModeStrs[mode]
end

hook.Add( "RVR_ModulesLoaded", "RVR_Party_commands", function()
    RVR.Commands.addType( "party", function( str, caller )
        if str == "^" then
            local partyID = caller:GetPartyID()
            if not partyID then
                return nil, "You're not in a party"
            end
            return partyID
        end

        if str == "@" then
            local aimEnt = caller:GetEyeTrace().Entity
            -- TODO: Support checking rafts to get their party
            if aimEnt and IsValid( aimEnt ) and ( aimEnt:IsPlayer() or aimEnt.IsRaft ) then
                if aimEnt:IsPlayer() then
                    local partyData = aimEnt:GetParty()
                    if not partyData then
                        return nil, "Player not in a party"
                    end
                    return partyData
                else
                    -- TODO: Replace this with however we store the party owner on a raft
                    return nil, "Getting party from raft not yet supported :("
                end
            else
                return nil, "Not looking at a player or raft"
            end
        end

        local id = tonumber( str )
        if id and party.getParty( id ) then
            return party.getParty( id )
        end

        local partyData = party.getByName( str )
        if partyData then
            return partyData
        end

        return nil, "Unrecognised party, use party ID, name, ^ or @"
    end )

    RVR.Commands.register(
        "party_invite",
        { "Player" },
        { "player" },
        RVR_USER_ALL,
        invitePlayer,
        "Invites a player to your party"
    )

    RVR.Commands.register(
        "party_kick",
        { "Player" },
        { "player" },
        RVR_USER_ALL,
        kickPlayer,
        "Kicks a player from your party"
    )

    RVR.Commands.register(
        "party_join",
        { "Party" },
        { "party" },
        RVR_USER_ALL,
        joinParty,
        "Attempt to join a party"
    )

    RVR.Commands.register(
        "party_leave",
        {},
        {},
        RVR_USER_ALL,
        leaveParty,
        "Leave your party and return to menu"
    )

    RVR.Commands.register(
        "party_set_mode",
        { "Join mode" },
        { "int" },
        RVR_USER_ALL,
        setJoinMode,
        "Sets the joining mode of a party. 0:public, 1:steam friends, 2:invite only"
    )

    RVR.Commands.register(
        "party_create",
        { "Name", "Tag", "Color", "Join mode" },
        { "string", "string", "color", "int" },
        RVR_USER_ADMIN,
        createParty,
        "Creates a party"
    )
end )
