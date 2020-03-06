// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Transparent/Diffuse" {
Properties {
	//[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
 	
	[Header(WeatherController)]
	//[KeywordEnum(None,Snow,Surface_Wave)]_Feature("Features",float) = 0
	[Toggle(_FEATURE_NONE)]_SurfaceWaveOn("Disable Weather ?",int) = 0


	[Header(Snow)]  
	// 积雪是否有方向?
	[Toggle(DISABLE_SNOW_DIR)] _DisableSnowDir("Disable Snow Dir ?",float) = 0
	_DefaultSnowRate("Default Snow Rate",float) = 1.5
	//是否使用杂点扰动?
	[Toggle(SNOW_NOISE_MAP_ON)]_SnowNoiseMapOn("SnowNoiseMapOn",float) = 0
	[Toggle(_HEIGHT_SNOW)]_HeightSnow("Tree Height Snow?",float) = 1
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0
  
	_SnowDirection("Direction",vector) = (0,1,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
	 
	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
	_ToneMapping("ToneMapping",range(0,1)) = 0
	 
	_Distance("Distance",range(0,100)) = 2 
	_DistanceAttenWidth("DistanceAttenWidth",range(0.2,1)) = 0

	[Space(20)]
	[Header(SurfaceWave)]
        _WaveColor("Color",color)=(1,1,1,1)
        _Tile("Tile",vector) = (5,5,10,10)
        _Direction("Direction",vector) = (0,1,0,-1)

        [noscaleoffset]_WaveNoiseMap("WaveNoiseMap",2d) = "bump"{}
        // [Header(Reflection)]
        // _ReflectionTex("ReflectionTex",Cube) = ""{}
        // _FakeReflectionTex("FakeReflectionTex",2d) = "black"{}

        // [Header(Fresnal)] 
        // _FresnalWidth("FresnalWidth",float) = 1    
       
        // [Header(VertexWave)]
        // [Toggle]_VertexWave("Vertex Wave ?",float) = 0
        // _VertexWaveNoiseTex("VertexWaveNoiseTex",2d) = ""{}
        // _VertexWaveIntensity("VertexWaveIntensity",float) = 0.1
        // _VertexWaveSpeed("VertexWaveSpeed",float) = 1
  
        // [Header(Specular)]
        // _SpecPower("SpecPower",range(0.001,1)) = 10    
        // _Glossness("Glossness",range(0,1)) = 1 
        // _SpecWidth("SpecWidth",range(0,1)) = 0.2

		_WaveBorderWidth("WaveBorderWidth",range(0,1)) = 0.2
		_DirAngle("DirAngle",range(0,1)) = 0.8
		_WaveIntensity("WaveIntensity",range(0,1)) = 0.8
}
   
 
SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 200
	//Cull[_CullMode]    
CGPROGRAM
#pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
#pragma shader_feature SNOW_NOISE_MAP_ON
#pragma shader_feature DISABLE_SNOW_DIR
#pragma shader_feature _HEIGHT_SNOW 
#pragma surface surf Lambert alpha:fade vertex:vert novertexlights noforwardadd nodynlightmap nodirlightmap 
//#define SNOW
//#define SNOW_DISTANCE
#include "Assets/Game/GameRes/Shader/Weather/Nature/NatureLibMacro.cginc"


sampler2D _MainTex;
fixed4 _Color;

struct Input {
	float2 uv_MainTex;

	float3 worldPos;
	float3 wn;

	#ifdef _FEATURE_SURFACE_WAVE
	float4 normalUV;
	#endif
};
 
void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);
    
	#if defined(_FEATURE_SNOW) && !defined(_FEATURE_NONE)
		SNOW_VERT_FUNCTION(v.vertex,v.normal,o.wn);
	#endif

	#ifdef _FEATURE_SURFACE_WAVE
		WATER_VERT_FUNCTION(v.texcoord,o.normalUV);
		o.wn = UnityObjectToWorldNormal(v.normal);
	#endif
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

	#if defined(_FEATURE_SNOW) && !defined(_FEATURE_NONE)
		SNOW_FRAG_FUNCTION(IN.uv_MainTex,c,IN.wn.xyz,IN.worldPos);
	#endif
	#ifdef _FEATURE_SURFACE_WAVE
		WATER_FRAG_FUNCTION(c,IN.normalUV,IN.wn,IN.uv_MainTex,IN.worldPos);
	#endif

	o.Albedo = ApplyThunder(c.rgb);
	o.Alpha = c.a;
} 
ENDCG
}

Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
