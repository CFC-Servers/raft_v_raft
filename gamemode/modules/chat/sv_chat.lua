RVR.Chat = RVR.Chat or {}

function RVR.Chat.canHear( listener, speaker )
    if not listener:Alive() or not speaker:Alive() then
        return false
    end

    local speakerPos = speaker:GetPos()
    local listenerPos = listener:GetPos()

    if listenerPos:DistToSqr( speakerPos ) > GAMEMODE.Config.Chat.CHAT_DISTANCE ^ 2 then
        return false
    end

    return true
end

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
    return RVR.Chat.canHear( listener, speaker )
end

function GM:PlayerCanHearPlayersVoice( listener, speaker )
    return RVR.Chat.canHear( listener, speaker ), GAMEMODE.Config.Chat.VOICE_3D
end
