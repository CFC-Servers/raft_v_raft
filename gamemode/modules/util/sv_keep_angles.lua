RVR.Util = RVR.Util or {}

local forwardAngle = Vector( 1, 0, 0 ):Angle()
local defaultDamping = 0.75
local defaultStrength = 100

function RVR.Util.keepAnglesThink( phys, strength, damp )
    -- TODO: understand/improve this

    strength = strength or defaultStrength
    damp = damp or defaultDamping

    local entAng = physObject:GetAngles() 

    local pitch = math.rad( math.AngleDifference( entAng.pitch, forwardAngle.pitch ) )
    local yaw = 0
    local roll = math.rad( math.AngleDifference( entAng.roll, forwardAngle.roll ) )

    local divAng = Vector( pitch, yaw, 0 )
    divAng:Rotate( Angle( 0, -entAng.roll, 0 ) )
    
    local vel = -Vector( roll, divAng.x, divAng.y ) * strength 
    local damping = -phys:GetAngleVelocity() * damp
    phys:AddAngleVelocity( vel + damping )
end
