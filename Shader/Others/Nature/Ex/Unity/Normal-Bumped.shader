// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Bumped Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
 
	[Header(Snow)]
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0
	 
	_SnowDirection("Direction",vector) = (.1,1,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
}
 
CGINCLUDE
ENDCG


SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 300
		 
CGPROGRAM
#pragma surface surf Lambert vertex:vert
#define SNOW
#include "../../NatureLib.cginc"

sampler2D _MainTex;
float4 _MainTex_TexelSize;

sampler2D _BumpMap;
fixed4 _Color; 

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 worldPos;
	float3 wn;
};

void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);

	float3 worldNormal;
	float3 pos;
	SnowDir(v.vertex, v.normal, pos, worldNormal);
	v.vertex.xyz = pos;
	o.wn = worldNormal; 
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	fixed4 snowColor = SnowColor(IN.uv_MainTex,c, IN.wn,IN.worldPos,0);
	o.Albedo = snowColor;
	o.Alpha = c.a;   
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
}      
ENDCG
}

FallBack "Legacy Shaders/Diffuse"
}
