// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Transparent/Cutout/Diffuse" {
Properties {
	[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

 	[KeywordEnum(None,Snow,SurfaceWave)]_Feature("Features",float) = 0

	[Header(Snow)]
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

	_SnowDirection("Direction",vector) = (0.1,1,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
	 
	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
	
	_Distance("Distance",range(0,100)) = 2
	_DistanceAttenWidth("DistanceAttenWidth",range(0.2,1)) = 0
}
	

SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 200
	Cull[_CullMode]
CGPROGRAM
#pragma surface surf Lambert alphatest:_Cutoff vertex:vert
#pragma multi_compile _FEATURE_SNOW _FEATURE_SURFACE_WAVE

//#define SNOW
#define SNOW_DISTANCE
#include "../../NatureLib.cginc"


sampler2D _MainTex;
fixed4 _Color;

struct Input {
	float2 uv_MainTex;

	#ifdef _FEATURE_SNOW
	float3 worldPos;
	float4 wn;
	#endif
};
 
void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);

	#ifdef _FEATURE_SNOW 
	float3 worldNormal;
	float3 pos;
	SnowDir(v.vertex, v.normal, pos, worldNormal);
	v.vertex.xyz = pos;
	o.wn = float4(worldNormal,0);
	#endif
}
    
void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	#ifdef _FEATURE_SNOW 
	fixed4 snowColor = SnowColor(IN.uv_MainTex, c, IN.wn.xyz, IN.worldPos,IN.worldPos.y);
	c.rgb = snowColor.rgb;
	#endif
  
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}
ENDCG
}

Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
