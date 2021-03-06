// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Self-Illumin/Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Illum ("Illumin (A)", 2D) = "white" {}
	_Emission ("Emission (Lightmapper)", Float) = 1.0
	
	[Header(WeatherController)]
	//[KeywordEnum(None,Snow,Surface_Wave)]_Feature("Features",float) = 0
	[Toggle(_FEATURE_NONE)]_SurfaceWaveOn("Disable Weather ?",int) = 0

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
	Tags { "RenderType"="Opaque" }
	LOD 200
	

	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
	

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdbase novertexlight nodynlightmap nodirlightmap
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'vert'
// writes to per-pixel normal: no
// writes to emission: YES
// writes to occlusion: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: no
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: no
// reads from normal: no
// 2 texcoords actually used
//   float2 _MainTex
//   float2 _Illum
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 61 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */
//#pragma surface surf Lambert vertex:vert novertexlights noforwardadd nodynlightmap nodirlightmap noforwardadd nodynlightmap nodirlightmap nometa  exclude_path:deferred exclude_path:prepass 
#pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
#pragma shader_feature SNOW_NOISE_MAP_ON
#pragma shader_feature DISABLE_SNOW_DIR
#pragma shader_feature _HEIGHT_SNOW
#pragma shader_feature RIPPLE_ON
#pragma shader_feature PLANTS
#pragma shader_feature PLANTS_OFF
#pragma shader_feature EXPAND_BILLBOARD
#pragma multi_compile _ RAIN_REFLECTION

#include "Assets/Game/GameRes/Shader/Weather/Nature/NatureLibMacro.cginc"

sampler2D _MainTex;
sampler2D _Illum;
fixed4 _Color;
fixed _Emission;
fixed _WaveColorOn;

struct Input {
	float2 uv_MainTex;
	float2 uv_Illum;
		
	float3 worldPos; 
	float3 wn;

	float4 normalUV;
};

void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);
 
	#ifdef _FEATURE_SNOW 
		SNOW_VERT_FUNCTION(v.vertex,v.normal,o.wn);
	#endif
   
	#ifdef _FEATURE_SURFACE_WAVE
		WATER_VERT_FUNCTION(v.texcoord,o.normalUV);
		o.wn = UnityObjectToWorldNormal(v.normal);
	#endif
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed4 c = tex * _Color;
	half4 mainColor = c;

	#ifdef _FEATURE_SNOW
		SNOW_FRAG_FUNCTION(IN.uv_MainTex,c,IN.wn.xyz,IN.worldPos);
	#endif

	#if defined(_FEATURE_SURFACE_WAVE)
		WATER_FRAG_FUNCTION(c,IN.normalUV,IN.wn,IN.uv_MainTex,IN.worldPos);
	#endif   

	o.Albedo = ApplyThunder(c.rgb);
	o.Emission = ApplyThunder(c.rgb) * tex2D(_Illum, IN.uv_Illum).a;
#if defined (UNITY_PASS_META)
	o.Emission *= _Emission.rrr;
#endif
	o.Alpha = c.a;
}


// vertex-to-fragment interpolation data
// no lightmaps:
#ifndef LIGHTMAP_ON
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _Illum
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  float3 custompack0 : TEXCOORD3; // wn
  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD4; // SH
  #endif
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  float4 normalUV : TEXCOORD7;
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
#endif
// with lightmaps:
#ifdef LIGHTMAP_ON
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _Illum
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  float3 custompack0 : TEXCOORD3; // wn
  float4 lmap : TEXCOORD4;
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  float4 normalUV : TEXCOORD7;
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
#endif
float4 _MainTex_ST;
float4 _Illum_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  UNITY_TRANSFER_INSTANCE_ID(v,o);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
  Input customInputData;
  vert (v, customInputData);
  o.custompack0.xyz = customInputData.wn;
  o.normalUV = customInputData.normalUV;
  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Illum);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #endif
  #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  #endif
  o.worldPos = worldPos;
  o.worldNormal = worldNormal;
  #ifdef LIGHTMAP_ON
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifndef LIGHTMAP_ON
    #if UNITY_SHOULD_SAMPLE_SH
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // !LIGHTMAP_ON

  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_Illum.x = 1.0;
  surfIN.worldPos.x = 1.0;
  surfIN.wn.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_Illum = IN.pack0.zw;
  surfIN.wn = IN.custompack0.xyz;
  surfIN.normalUV = IN.normalUV;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = IN.worldNormal;
  normalWorldVertex = IN.worldNormal;

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingLambert_GI(o, giInput, gi);

  // realtime lighting: call lighting function
  c += LightingLambert (o, gi);
  c.rgb += o.Emission;
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}


#endif

// -------- variant for: INSTANCING_ON 
#if defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'vert'
// writes to per-pixel normal: no
// writes to emission: YES
// writes to occlusion: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: no
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: no
// reads from normal: no
// 2 texcoords actually used
//   float2 _MainTex
//   float2 _Illum
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 61 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */
//#pragma surface surf Lambert vertex:vert novertexlights noforwardadd nodynlightmap nodirlightmap noforwardadd nodynlightmap nodirlightmap nometa  exclude_path:deferred exclude_path:prepass 
// #if defined(_FEATURE_SNOW)
// //#pragma shader_feature SNOW_NOISE_MAP_ON
// //#pragma shader_feature DISABLE_SNOW_DIR
// //#pragma shader_feature _HEIGHT_SNOW
// #endif
// //#pragma shader_feature RIPPLE_ON
// //#pragma shader_feature PLANTS
// #if defined(PLANTS)
// //#define UP_Y
// //#pragma shader_feature PLANTS_OFF
// //#pragma shader_feature EXPAND_BILLBOARD
// #endif

#include "Assets/Game/GameRes/Shader/Weather/Nature/NatureLibMacro.cginc"

sampler2D _MainTex;
sampler2D _Illum;
fixed4 _Color;
fixed _Emission;
fixed _WaveColorOn;

struct Input {
	float2 uv_MainTex;
	float2 uv_Illum;
		
	float3 worldPos; 
	float3 wn;

	#ifdef _FEATURE_SURFACE_WAVE
	float4 normalUV;
	#endif
};

void vert(inout appdata_full v, out Input o) {
	UNITY_INITIALIZE_OUTPUT(Input, o);
 
	#ifdef _FEATURE_SNOW 
		SNOW_VERT_FUNCTION(v.vertex,v.normal,o.wn);
	#endif
   
	#ifdef _FEATURE_SURFACE_WAVE
		WATER_VERT_FUNCTION(v.texcoord,o.normalUV);
		o.wn = UnityObjectToWorldNormal(v.normal);
	#endif
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed4 c = tex * _Color;
	half4 mainColor = c;

	#ifdef _FEATURE_SNOW
		SNOW_FRAG_FUNCTION(IN.uv_MainTex,c,IN.wn.xyz,IN.worldPos);
	#endif

	#if defined(_FEATURE_SURFACE_WAVE)
		WATER_FRAG_FUNCTION(c,IN.normalUV,IN.wn,IN.uv_MainTex,IN.worldPos);
	#endif   

	o.Albedo = ApplyThunder(c.rgb);
	o.Emission = ApplyThunder(c.rgb) * tex2D(_Illum, IN.uv_Illum).a;
#if defined (UNITY_PASS_META)
	o.Emission *= _Emission.rrr;
#endif
	o.Alpha = c.a;
}


// vertex-to-fragment interpolation data
// no lightmaps:
#ifndef LIGHTMAP_ON
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _Illum
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  float3 custompack0 : TEXCOORD3; // wn
  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD4; // SH
  #endif
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
#endif
// with lightmaps:
#ifdef LIGHTMAP_ON
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _MainTex _Illum
  half3 worldNormal : TEXCOORD1;
  float3 worldPos : TEXCOORD2;
  float3 custompack0 : TEXCOORD3; // wn
  float4 lmap : TEXCOORD4;
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
#endif
float4 _MainTex_ST;
float4 _Illum_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  UNITY_TRANSFER_INSTANCE_ID(v,o);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
  Input customInputData;
  vert (v, customInputData);
  o.custompack0.xyz = customInputData.wn;
  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Illum);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #endif
  #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  #endif
  o.worldPos = worldPos;
  o.worldNormal = worldNormal;
  #ifdef LIGHTMAP_ON
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifndef LIGHTMAP_ON
    #if UNITY_SHOULD_SAMPLE_SH
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // !LIGHTMAP_ON

  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_Illum.x = 1.0;
  surfIN.worldPos.x = 1.0;
  surfIN.wn.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_Illum = IN.pack0.zw;
  surfIN.wn = IN.custompack0.xyz;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = IN.worldNormal;
  normalWorldVertex = IN.worldNormal;

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingLambert_GI(o, giInput, gi);

  // realtime lighting: call lighting function
  c += LightingLambert (o, gi);
  c.rgb += o.Emission;
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}


#endif


ENDCG

}

	// ---- end of surface shader generated code

#LINE 131

} 
FallBack "Legacy Shaders/Self-Illumin/VertexLit"
CustomEditor "LegacyIlluminShaderGUI"
}
