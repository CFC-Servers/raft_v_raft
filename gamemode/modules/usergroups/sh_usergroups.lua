RVR_USER_ALL = 1
RVR_USER_ADMIN = 2
RVR_USER_SUPERADMIN = 3

local userGroupNames = {
    "user",
    "admin",
    "superadmin"
}

function RVR.getGroupName( userGroup )
    return userGroupNames[userGroup]
end

function RVR.getUserGroup( ply )
    if ply:IsSuperAdmin() then return RVR_USER_SUPERADMIN end
    if ply:IsAdmin() then return RVR_USER_ADMIN end

    return RVR_USER_ALL
end

function RVR.isUserGroup( ply, userGroup )
    return RVR.getUserGroup( ply ) >= userGroup
end
