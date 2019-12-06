// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Bumped Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}

	[Header(Custom Light)]
	_LightDir("Light Dir",vector) = (0,0,0,0)
	_LightColor("Light Color",color) = (0,0,0,1)

	//[KeywordEnum(None,Snow,Surface_Wave)]_Feature("Features",float) = 0
 
	[Header(Snow)]
	// 积雪是否有方向?
	[Toggle(DISABLE_SNOW_DIR)] _DisableSnowDir("Disable Snow Dir ?",float) = 0
	_DefaultSnowRate("Default Snow Rate",float) = 1.5
	//是否使用杂点扰动?
	[Toggle(SNOW_NOISE_MAP_ON)]_SnowNoiseMapOn("SnowNoiseMapOn",float) = 0
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0
	 
	_SnowDirection("Direction",vector) = (.1,1,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
	_ToneMapping("ToneMapping",range(0,1)) = 0
	     
	[Space(20)]
	[Header(SurfaceWave)]
        _WaveColor("Color",color)=(1,1,1,1)
        _Tile("Tile",vector) = (5,5,10,10)
        _Direction("Direction",vector) = (0,1,0,-1)

        [noscaleoffset]_WaveNoiseMap("WaveNoiseMap",2d) = "bump"{}
        // [Header(Reflection)]
        // _ReflectionTex("ReflectionTex",Cube) = ""{}
        // _FakeReflectionTex("FakeReflectionTex",2d) = "black"{}

        [Header(Fresnal)] 
        _FresnalWidth("FresnalWidth",float) = 1    
       
        // [Header(VertexWave)]
        // [Toggle]_VertexWave("Vertex Wave ?",float) = 0
        // _VertexWaveNoiseTex("VertexWaveNoiseTex",2d) = ""{}
        // _VertexWaveIntensity("VertexWaveIntensity",float) = 0.1
        // _VertexWaveSpeed("VertexWaveSpeed",float) = 1
  
        [Header(Specular)]
        _SpecPower("SpecPower",range(0.001,1)) = 10    
        _Glossness("Glossness",range(0,1)) = 1 
        _SpecWidth("SpecWidth",range(0,1)) = 0.2

		_WaveBorderWidth("WaveBorderWidth",range(0,1)) = 0.2
		_DirAngle("DirAngle",range(0,1)) = 0.8
		_WaveIntensity("WaveIntensity",range(0,1)) = 0.8
}


SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 300
		 
CGPROGRAM
#pragma target 3.0
#pragma surface surf SimpleLambert vertex:vert novertexlights noforwardadd nodynlightmap nodirlightmap 
#pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
#pragma shader_feature _ SNOW_NOISE_MAP_ON DISABLE_SNOW_DIR
//#define SNOW
#include "../../NatureLib.cginc"
#include "../../CustomLight.cginc"

sampler2D _MainTex;
float4 _MainTex_TexelSize;
 
sampler2D _BumpMap;
fixed4 _Color;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	
	float3 worldPos; 
	float3 wn;
	#ifdef _FEATURE_SNOW 
	#endif

	#ifdef _FEATURE_SURFACE_WAVE
	float4 normalUV;
	#endif
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
   
	#ifdef _FEATURE_SURFACE_WAVE
	o.normalUV = v.texcoord.xyxy * _Tile + _Time.xxxx* _Direction;
	o.wn = UnityObjectToWorldNormal(v.normal);
	#endif
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

	#ifdef _FEATURE_SNOW
	fixed4 snowColor = SnowColor(IN.uv_MainTex,c, IN.wn,IN.worldPos,0);
	c.rgb = snowColor.rgb;
	#endif

	#ifdef _FEATURE_SURFACE_WAVE
	float3 noiseNormal;
	float2 noiseUV;
	float edge;
	NoiseUVNormal(c,IN.normalUV,IN.wn,noiseUV,noiseNormal,edge);

	float4 noiseCol = tex2D(_MainTex,IN.uv_MainTex+noiseUV);
	v2f_surface v2fSurface = {IN.uv_MainTex,IN.worldPos,IN.wn};
	half4 surfaceColor = SurfaceWaveFrag(v2fSurface,noiseCol,noiseNormal,edge);

	c.rgb = surfaceColor.rgb;
	#endif   
 
	o.Albedo = c.rgb;
	o.Alpha = c.a;  
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
}
ENDCG
}

FallBack "Legacy Shaders/Diffuse"
}
