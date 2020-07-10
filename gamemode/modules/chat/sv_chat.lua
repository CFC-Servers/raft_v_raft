function RVR.canHear( listener, speaker )
    if not listener:Alive() or not speaker:Alive() then
        return false
    end
    
    local speakerPos = speaker:GetPos()
    local listenerPos = listener:GetPos()

    if listenerPos:Distance( speakerPos ) > GAMEMODE.Config.Chat.CHAT_DISTANCE then
        return false
    end
    
    return true
end

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
    if teamOnly then
        -- TODO check party system?
        return false
    end
    
    return RVR.canHear( listener, speaker )
end

function GM:PlayerCanHearPlayersVoice( listener, speaker )
    return RVR.canHear( listener, speaker ), GAMEMODE.Config.Chat.VOICE_3D
end
