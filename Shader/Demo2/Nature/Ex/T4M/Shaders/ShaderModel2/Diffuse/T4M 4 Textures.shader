Shader "T4MShaders/ShaderModel2/Diffuse/T4M 4 Textures" {
Properties {
	_Splat0 ("Layer 1", 2D) = "white" {}
	_Splat1 ("Layer 2", 2D) = "white" {}
	_Splat2 ("Layer 3", 2D) = "white" {}
	_Splat3 ("Layer 4", 2D) = "white" {}
	_Tiling3("_Tiling4 x/y", Vector)=(1,1,0,0) 
	_Control ("Control (RGBA)", 2D) = "white" {}
	_MainTex ("Never Used", 2D) = "white" {}

	[Header(Snow)]
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

	_SnowDirection("Direction",vector) = (0.1,1,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
 	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
}

SubShader {
	Tags {
   "SplatCount" = "4"
   "RenderType" = "Opaque"
	}
CGPROGRAM
#pragma multi_compile _ SNOW
#pragma surface surf Lambert nodynlightmap  nodirlightmap vertex:vert
#pragma exclude_renderers xbox360 ps3
#include "Assets/Game/GameRes/Shader/Weather/Nature/NatureLib.cginc"

struct Input {
	float2 uv_Control : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	float2 uv_Splat3 : TEXCOORD4;

	float3 worldPos;
	float3 wn;
};

void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);

#ifdef _FEATURE_SNOW
	float3 worldNormal;
	float3 pos;
	SnowDir(v.vertex, v.normal, pos, worldNormal);
	v.vertex.xyz = pos;
	o.wn = worldNormal; 
#endif	
}
sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
float4 _Tiling3;
void surf (Input IN, inout SurfaceOutput o) {
	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
		
	fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);
	fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
	fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
	fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);
	fixed4 c = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
#ifdef _FEATURE_SNOW	
	fixed4 snowColor = SnowColor(IN.uv_Control,c, IN.wn,IN.worldPos,0);
	c.rgb = snowColor;
#endif	
      
	o.Alpha = 0.0;
	o.Albedo.rgb = c.rgb;
}
ENDCG 
}
// Fallback to Diffuse
Fallback "Diffuse"
}
