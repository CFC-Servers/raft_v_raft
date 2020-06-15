AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function SWEP:SetItemData( itemData )
    -- Delay as NetworkVarNotify doesn't trigger if this is too early
    -- TODO: Test if this value can be lower
    timer.Simple( 0.1, function()
        self:SetViewModelOffset( itemData.viewModelOffset or Vector( 5, 10, -5 ) )
        self:SetViewModelAng( itemData.viewModelAng or Angle( 15, 0, 0 ) )
        self:SetItemModel( itemData.model )
    end )
end
