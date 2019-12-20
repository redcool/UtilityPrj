// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Transparent/Cutout/Diffuse" {
Properties {
	[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	_NormalMap("Normal Map",2d) = ""{}

	[Header(Wind)]
	[Toggle(EXPAND_BILLBOARD)]_ExpandBillboard("叶片膨胀?",float) = 0
	_Wave("抖动(树枝,边抖动,风向偏移,风向回弹)",vector) = (0,0.2,0.2,0.1)
	_Wind("风力(xyz:方向,w:风强)",vector) = (1,1,1,1)
 	_AttenField("无抖动范围 (x: 水平距离,y:竖直距离)",vector) = (1,1,1,1)

	[Header(Snow)]  
	//[Toggle(SNOW)]_SnowEnable("Snow Enabled",float) = 1
	[Toggle(SNOW_NOISE_MAP_ON)]_SnowNoiseMapOn("SnowNoiseMapOn",float) = 0
	[Toggle(_HEIGHT_SNOW)]_HeightSnow("Tree Height Snow?",float) = 1
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0
  
	_SnowDirection("Direction",vector) = (0,1,0,0)
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
#pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
#pragma shader_feature  SNOW_NOISE_MAP_ON
#pragma shader_feature _HEIGHT_SNOW 

//#pragma shader_feature EXPAND_BILLBOARD
#pragma surface surf Lambert alphatest:_Cutoff vertex:vert noforwardadd
//#define SNOW
//#define SNOW_DISTANCE

#define PLANTS
#include "../../NatureLib.cginc"


sampler2D _MainTex;
sampler2D _NormalMap;
fixed4 _Color;



struct Input {
	float2 uv_MainTex;

	float3 worldPos;
	float4 wn;
};
 
void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);
	#if defined(PLANTS)
	v.vertex = ClampVertexWave(v, _Wave, _AttenField.y,_AttenField.x);
	//v.vertex = Squash(v.vertex);
	#endif

	#ifdef _FEATURE_SNOW
	float3 worldNormal;
	float3 pos;
	SnowDir(v.vertex, v.normal, pos, worldNormal);
	v.vertex.xyz = pos;
	o.wn = float4(worldNormal,v.vertex.z);  
	#endif
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

	#ifdef _FEATURE_SNOW
	c.rgb = SnowColor(IN.uv_MainTex, c, IN.wn.xyz, IN.worldPos,IN.worldPos.y);
	#endif

	o.Albedo = c.rgb;   
	o.Alpha = c.a;
	o.Normal= UnpackNormal(tex2D(_NormalMap,IN.uv_MainTex));
} 
ENDCG
}

Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
