
HEADER
{
	Description = "";
}

FEATURES
{
	#include "vr_common_features.fxc"
	Feature( F_ADDITIVE_BLEND, 0..1, "Blending" );
}

COMMON
{
	#ifndef S_ALPHA_TEST
	#define S_ALPHA_TEST 0
	#endif
	#ifndef S_TRANSLUCENT
	#define S_TRANSLUCENT 1
	#endif
	
	#include "common/shared.hlsl"

	#define S_UV2 1
}

struct VertexInput
{
	#include "common/vertexinput.hlsl"
};

struct PixelInput
{
	#include "common/pixelinput.hlsl"
	float3 vPositionOs : TEXCOORD14;
};

VS
{
	#include "common/vertex.hlsl"

	PixelInput MainVs( VertexInput i )
	{
		PixelInput o = ProcessVertex( i );
		o.vPositionOs = i.vPositionOs.xyz;
		return FinalizeVertex( o );
	}
}

PS
{
	#include "sbox_pixel.fxc"
	#include "common/pixel.material.structs.hlsl"
	#include "common/pixel.lighting.hlsl"
	#include "common/pixel.shading.hlsl"
	#include "common/pixel.material.helpers.hlsl"
	#include "common/pixel.color.blending.hlsl"
	#include "common/proceedural.hlsl"
	
	SamplerState g_sSampler0 <
	 Filter( ANISO ); AddressU( WRAP ); AddressV( WRAP ); >;CreateInputTextureCube( Texture, Srgb, 8,
	 "None", "_color", ",0/,0/0", Default4( 1.00, 1.00, 1.00, 1.00 ) );CreateInputTexture2D( Texture0, Srgb, 8,
	 "None", "_color", ",0/,0/0", Default4( 1.00, 1.00, 1.00, 1.00 ) );TextureCube g_tTexture < Channel( RGBA, Box( Texture ), Srgb );
	 OutputFormat( DXT5 ); SrgbRead( True ); >;Texture2D g_tTexture0 < Channel( RGBA, Box( Texture0 ), Srgb );
	 OutputFormat( DXT5 ); SrgbRead( True ); >;
	float4 MainPs( PixelInput i ) : SV_Target0
	{
		Material m;
		m.Albedo = float3( 1, 1, 1 );
		m.Normal = TransformNormal( i, float3( 0, 0, 1 ) );
		m.Roughness = 1;
		m.Metalness = 0;
		m.AmbientOcclusion = 1;
		m.TintMask = 1;
		m.Opacity = 1;
		m.Emission = float3( 0, 0, 0 );
		m.Transmission = 0;
		
		float4 local0 = TexCubeS( g_tTexture, g_sSampler0, CalculatePositionToCameraDirWs( i.vPositionWithOffsetWs.xyz + g_vHighPrecisionLightingOffsetWs.xyz ) );
		float4 local1 = Tex2DS( g_tTexture0, g_sSampler0, i.vTextureCoords.xy );
		
		m.Albedo = local0.xyz;
		m.Emission = local1.xyz;
		m.Opacity = 1;
		m.Roughness = 1;
		m.Metalness = 0;
		m.AmbientOcclusion = 1;
		
		m.AmbientOcclusion = saturate( m.AmbientOcclusion );
		m.Roughness = saturate( m.Roughness );
		m.Metalness = saturate( m.Metalness );
		m.Opacity = saturate( m.Opacity );
		
		ShadingModelValveStandard sm;
		return FinalizePixelMaterial( i, m, sm );
	}
}
