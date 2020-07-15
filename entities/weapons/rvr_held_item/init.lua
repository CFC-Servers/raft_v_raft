AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function SWEP:SetItemData( itemData )
    -- Delay as NetworkVarNotify doesn't trigger if this is too early
    -- TODO: Test if this value can be lower
    timer.Simple( 0.1, function()
        self:SetItemType( itemData.type )
    end )
end
