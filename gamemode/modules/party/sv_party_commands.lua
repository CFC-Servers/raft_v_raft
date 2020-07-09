RVR.Party = RVR.Party or {}
local party = RVR.Party

local function invitePlayer( caller, ply )
    local partyData = caller:GetParty()

    if not partyData then
        return "You're not in a party"
    end

    local success, err = party.invite( partyData.id, caller, ply )

    if success then
        -- TODO: Only print if player isnt in main menu, otherwise alert client
        ply:ChatPrint( "You've been invited to " .. partyData.name ..
            ". Use /join " .. partyData.id .. " within " .. party.inviteLifetime .. " seconds to respond.\n" ..
            "WARNING: Accepting an invite will make you leave your current party, along with any items you have" )
        return "Invited " .. ply:Nick() .. " to " .. partyData.name
    end

    return "Failed to invite: " .. err
end

local function joinParty( caller, partyData )
    local success, err = party.attemptJoin( caller, partyData )

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
        return "You can't kick yourself, if you want to leave a party, use /leave"
    end

    if not table.HasValue( partyData.members, ply ) then
        return "This player is not in your party"
    end

    party.removeMember( partyData.id, ply )

    return "Successfully kicked " .. ply:Nick() .. " from your party"
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
                    local partyID = aimEnt:GetPartyID()
                    if not partyID then
                        return nil, "Player not in a party"
                    end
                    return partyID
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
        "invite",
        { "Player" },
        { "player" },
        RVR_USER_ALL,
        invitePlayer,
        "Invites a player to your party"
    )

    RVR.Commands.register(
        "kick",
        { "Player" },
        { "player" },
        RVR_USER_ALL,
        kickPlayer,
        "Kicks a player from your party"
    )

    RVR.Commands.register(
        "join",
        { "Party" },
        { "party" },
        RVR_USER_ALL,
        joinParty,
        "Attempt to join a party"
    )

    RVR.Commands.register(
        "leave",
        {},
        {},
        RVR_USER_ALL,
        leaveParty,
        "Leave your party and return to menu"
    )
end )
