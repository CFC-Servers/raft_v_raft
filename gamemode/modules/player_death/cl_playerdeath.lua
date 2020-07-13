net.Receive( "RVR_PlayerDeath", function()
    hook.Run( "RVR_PlayerDeath", net.ReadEntity(), net.ReadEntity(), net.ReadEntity() )
end )
