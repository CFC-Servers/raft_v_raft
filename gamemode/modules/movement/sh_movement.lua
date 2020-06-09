function GM:FinishMove( ply, mv )
    local ground = ply:GetGroundEntity()
    if not IsValid( ground ) or ground:GetClass() ~= "raft_foundation" then return end
    
    local vel = mv:GetVelocity()
    ply:SetLocalVelocity( vel )
	ply:SetAbsVelocity( vel )
	ply:SetLocalAngles( mv:GetAngles() )
    
    local pos = mv:GetOrigin() + vel * FrameTime() * 0.3
    pos.z = math.min( 20, pos.z)
    ply:SetPos( pos )
    ply:SetLocalPos( pos )
    ply:SetNetworkOrigin( pos )
    
    return true
end
