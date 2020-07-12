local viewSize = 1024

RVR.Util = RVR.Util or {}

local mats = {}
function RVR.Util.getModelTexture( model, pos, ang )
    if mats[model] then return mats[model] end
    pos = pos or Vector( 0, 0, 0 )
    ang = ang or Angle()

    local texture = GetRenderTargetEx( "rvr_model_" .. model, viewSize, viewSize, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888 )

    local ent = ClientsideModel( model )
    ent:SetNoDraw( true )
    ent:SetPos( pos )
    ent:SetAngles( ang )

    render.PushRenderTarget( texture )
        render.OverrideAlphaWriteEnable( true, true )
        render.OverrideDepthEnable( true, true )
        
        render.Clear( 0, 0, 0, 0, true )
        
        cam.Start3D( Vector( 0, 0, 0 ), Angle(), nil, 0, 0, viewSize, viewSize )
            render.SuppressEngineLighting( true )
            render.SetLightingOrigin( ent:GetPos() )
            render.ResetModelLighting( 1, 1, 1 )
            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 0.9999999 )

            ent:DrawModel()
            render.SuppressEngineLighting( false )
        cam.End3D()
        
        render.OverrideAlphaWriteEnable( false )
        render.OverrideDepthEnable( false )
    render.PopRenderTarget()

    ent:Remove()
    
    local mat = CreateMaterial( "rvr_model17_" .. model, "UnlitGeneric", {
        ['$basetexture'] = texture,
        ["$translucent"] = 1,
        ["$vertexcolor"] = 1
    } )
    
    mat:SetTexture( "$basetexture", texture )

    mats[model] = mat
    return mat
end
