function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
    if teamOnly then
        -- TODO check party system?
        return false
    end
    local listenerPos = listener:GetPos()
    local speakerPos = speaker:GetPos()
    if listenerPos:Distance( speakerPos ) > GAMEMODE.Config.Chat.CHAT_DISTANCE then
        return false
    end

    return true
end

