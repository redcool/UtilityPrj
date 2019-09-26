// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Transparent/Cutout/Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
 
	[Header(Snow)]
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

	_SnowDirection("Direction",vector) = (0.1,1,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
	 
	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
	
	_Distance("Distance",range(0,15)) = 2
	_DistanceAttenWidth("DistanceAttenWidth",range(0.2,1)) = 0
}
	

SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 200
	Cull off
CGPROGRAM
#pragma surface surf Lambert alphatest:_Cutoff vertex:vert
#define SNOW
#define SNOW_DISTANCE
#include "../../NatureLib.cginc"


sampler2D _MainTex;
fixed4 _Color;

struct Input {
	float2 uv_MainTex;

	float3 worldPos;
	float4 wn;
};

void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);

	float3 worldNormal;
	float3 pos;
	SnowDir(v.vertex, v.normal, pos, worldNormal);
	v.vertex.xyz = pos;
	o.wn = float4(worldNormal,v.vertex.z);
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	fixed4 snowColor = SnowColor(IN.uv_MainTex, c, IN.wn.xyz, IN.worldPos,IN.wn.w);
	o.Albedo = snowColor;
	o.Alpha = c.a;
}
ENDCG
}

Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
