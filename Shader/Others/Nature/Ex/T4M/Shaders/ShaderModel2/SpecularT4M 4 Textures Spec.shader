// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "T4MShaders/Specular/T4M 4 Textures Spec" {
Properties {
	_SpecColor ("Specular Color(RGB); diff(A)", Color) = (1, 1, 1, 1)
	_ShininessL0 ("Layer1Shininess", Range (0.03, 1)) = 0.078125
	_Splat0 ("Layer 1", 2D) = "white" {}
	_ShininessL1 ("Layer2Shininess", Range (0.03, 1)) = 0.078125
	_Splat1 ("Layer 2", 2D) = "white" {}
	_ShininessL2 ("Layer3Shininess", Range (0.03, 1)) = 0.078125
	_Splat2 ("Layer 3", 2D) = "white" {}
	_ShininessL3 ("Layer4Shininess", Range (0.03, 1)) = 0.078125
	_Splat3 ("Layer 4", 2D) = "white" {}
	_Tiling3("_Tiling4 x/y", Vector)=(1,1,0,0)
	_Control ("Control (RGBA)", 2D) = "white" {}
	_MainTex ("Never Used", 2D) = "white" {}
	_SpecDir("Specular Direction",Vector)=(1,1,0,0)
 
	[Header(Snow)]
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

	_SnowDirection("Direction",vector) = (1,0,0,0)
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
#pragma exclude_renderers xbox360 ps3
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"

// Surface shader code generated based on:
// writes to per-pixel normal: no
// writes to emission: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: no
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: no
// reads from normal: no
// 4 texcoords actually used
//   float2 _Control
//   float2 _Splat0
//   float2 _Splat1
//   float2 _Splat2
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define SNOW
#include "../../../Weather/Nature/NatureLib.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 21 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

//#pragma surface surf T4MBlinnPhong
//#pragma exclude_renderers xbox360 ps3

sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
fixed _ShininessL0;
fixed _ShininessL1;
fixed _ShininessL2;
fixed _ShininessL3;
float4 _Tiling3;
fixed4 _SpecDir;

fixed4 _SnowNoiseTile;

inline fixed4 LightingT4MBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, _SpecDir));
	//fixed nh = max (0, dot (s.Normal, halfDir));
	fixed nh = max (0, dot (normalize(s.Normal), normalize(halfDir+_SpecDir.xyz)));
	fixed spec = pow (nh, s.Specular*128) * s.Gloss;
	
	fixed4 c;
	//c.rgb = (s.Albedo * _LightColor0.rgb * diff + _SpecColor.rgb * spec) * (atten*2);
	c.rgb = (s.Albedo*_SpecColor.a+_SpecColor.rgb*spec)*(atten*2);
	c.a = 0.0;
	return c;
}

struct Input {
	float2 uv_Control : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	float2 uv_Splat3 : TEXCOORD4;
	float3 worldPos:TEXCOORD5;
	float3 wn:TEXCOORD6;
};
 
void surf (Input IN, inout SurfaceOutput o) {
	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
		
	fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);  
	fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
	fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
	fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);

	fixed4 c = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
	fixed4 snowColor = SnowColor(IN.uv_Control,c, IN.wn, IN.worldPos,0);
	
	o.Alpha = 0.0;
	o.Albedo.rgb = snowColor.rgb;
	o.Gloss = (lay1.a * splat_control.r + lay2.a * splat_control.g + lay3.a * splat_control.b + lay4.a * splat_control.a);
	o.Specular = (_ShininessL0 * splat_control.r + _ShininessL1 * splat_control.g + _ShininessL2 * splat_control.b + _ShininessL3 * splat_control.a);
}
 
  
// vertex-to-fragment interpolation data
// no lightmaps:
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _Control _Splat0
  float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
  half3 worldNormal : TEXCOORD2;
  float3 worldPos : TEXCOORD3;
  fixed3 vlight : TEXCOORD4; // ambient/SH/vertexlights
  SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD7;
  #endif
};
#endif
// with lightmaps:
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _Control _Splat0
  float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
  half3 worldNormal : TEXCOORD2;
  float3 worldPos : TEXCOORD3;
  float4 lmap : TEXCOORD4;
  SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  #ifdef DIRLIGHTMAP_COMBINED
  fixed3 tSpace0 : TEXCOORD7;
  fixed3 tSpace1 : TEXCOORD8;
  fixed3 tSpace2 : TEXCOORD9;
  #endif
};
#endif
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  o.pos = UnityObjectToClipPos (v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #endif
  #if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  #endif
  o.worldPos = worldPos;
  o.worldNormal = worldNormal;
  #ifndef DYNAMICLIGHTMAP_OFF
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  #endif
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifdef LIGHTMAP_OFF
  #if UNITY_SHOULD_SAMPLE_SH
  float3 shlight = ShadeSH9 (float4(worldNormal,1.0));
  o.vlight = shlight;
  #else
  o.vlight = 0.0;
  #endif
  #ifdef VERTEXLIGHT_ON
  o.vlight += Shade4PointLights (
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    unity_4LightAtten0, worldPos, worldNormal );
  #endif // VERTEXLIGHT_ON
  #endif // LIGHTMAP_OFF

  TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_Control.x = 1.0;
  surfIN.uv_Splat0.x = 1.0;
  surfIN.uv_Splat1.x = 1.0;
  surfIN.uv_Splat2.x = 1.0;
  surfIN.uv_Splat3.x = 1.0;
  surfIN.uv_Control = IN.pack0.xy;
  surfIN.uv_Splat0 = IN.pack0.zw;
  surfIN.uv_Splat1 = IN.pack1.xy;
  surfIN.uv_Splat2 = IN.pack1.zw;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
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

  surfIN.worldPos = IN.worldPos;
  surfIN.wn = IN.worldNormal;
  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;
  #ifdef LIGHTMAP_OFF
  c.rgb += o.Albedo * IN.vlight;
  #endif // LIGHTMAP_OFF

  // lightmaps
  #ifndef LIGHTMAP_OFF
    #ifdef DIRLIGHTMAP_OFF
      // single lightmap
      fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
      fixed3 lm = DecodeLightmap (lmtex);
    #elif DIRLIGHTMAP_COMBINED
      // directional lightmaps
      fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
      half3 lm = DecodeLightmap(lmtex);
    #elif DIRLIGHTMAP_SEPARATE
      // directional with specular - no support
      half4 lmtex = 0;
      half3 lm = 0;
    #endif // DIRLIGHTMAP_OFF

  #endif // LIGHTMAP_OFF


  // realtime lighting: call lighting function
  #ifndef LIGHTMAP_OFF
  c += LightingT4MBlinnPhong (o, lightDir, worldViewDir, atten);
  #else
    c.a = o.Alpha;
  #endif

  #ifndef LIGHTMAP_OFF
    // combine lightmaps with realtime shadows
    #ifdef SHADOWS_SCREEN
      #if defined(UNITY_NO_RGBM)
      c.rgb += o.Albedo * min(lm, atten*2);
      #else
      c.rgb += o.Albedo * max(min(lm,(atten*2)*lmtex.rgb), lm*atten);
      #endif
    #else // SHADOWS_SCREEN
      c.rgb += o.Albedo * lm;
    #endif // SHADOWS_SCREEN
  #endif // LIGHTMAP_OFF

  #ifndef DYNAMICLIGHTMAP_OFF
  fixed4 dynlmtex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, IN.lmap.zw);
  c.rgb += o.Albedo * DecodeRealtimeLightmap (dynlmtex);
  #endif

  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}

ENDCG

}

	// ---- forward rendering additive lights pass:
//	Pass {
//		Name "FORWARD"
//		Tags { "LightMode" = "ForwardAdd" }
//		ZWrite Off Blend One One

//CGPROGRAM
//// compile directives
//#pragma vertex vert_surf
//#pragma fragment frag_surf
//#pragma exclude_renderers xbox360 ps3
//#pragma multi_compile_fog
//#pragma multi_compile_fwdadd
//#include "HLSLSupport.cginc"
//#include "UnityShaderVariables.cginc"
//// Surface shader code generated based on:
//// writes to per-pixel normal: no
//// writes to emission: no
//// needs world space reflection vector: no
//// needs world space normal vector: no
//// needs screen space position: no
//// needs world space position: no
//// needs view direction: no
//// needs world space view direction: no
//// needs world space position for lighting: no
//// needs world space view direction for lighting: YES
//// needs world space view direction for lightmaps: no
//// needs vertex color: no
//// needs VFACE: no
//// passes tangent-to-world matrix to pixel shader: no
//// reads from normal: no
//// 4 texcoords actually used
////   float2 _Control
////   float2 _Splat0
////   float2 _Splat1
////   float2 _Splat2
//#define UNITY_PASS_FORWARDADD
//#include "UnityCG.cginc"
//#include "Lighting.cginc"
//#include "AutoLight.cginc"

//#define INTERNAL_DATA
//#define WorldReflectionVector(data,normal) data.worldRefl
//#define WorldNormalVector(data,normal) normal

//// Original surface shader snippet:
//#line 21 ""
//#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
//#endif

////#pragma surface surf T4MBlinnPhong
////#pragma exclude_renderers xbox360 ps3

//sampler2D _Control;
//sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
//fixed _ShininessL0;
//fixed _ShininessL1;
//fixed _ShininessL2;
//fixed _ShininessL3;
//float4 _Tiling3;
//fixed4 _SpecDir;

//inline fixed4 LightingT4MBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
//{
//	fixed diff = max (0, dot (s.Normal, lightDir));
//	//fixed nh = max (0, dot (s.Normal, halfDir));
//	fixed nh = max (0, dot (normalize(s.Normal), normalize(halfDir+_SpecDir.xyz)));
//	fixed spec = pow (nh, s.Specular*128) * s.Gloss;
	
//	fixed4 c;
//	//c.rgb = (s.Albedo * _LightColor0.rgb * diff + _SpecColor.rgb * spec) * (atten*2);
//	c.rgb = (s.Albedo*_SpecColor.a+_SpecColor.rgb*spec)*(atten*2);
//	c.a = 0.0;
//	return c;
//}

//struct Input {
//	float2 uv_Control : TEXCOORD0;
//	float2 uv_Splat0 : TEXCOORD1;
//	float2 uv_Splat1 : TEXCOORD2;
//	float2 uv_Splat2 : TEXCOORD3;
//	float2 uv_Splat3 : TEXCOORD4;
//};
 
//void surf (Input IN, inout SurfaceOutput o) {
//	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
		
//	fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);
//	fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
//	fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
//	fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);
//	o.Alpha = 0.0;
//	o.Albedo.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
//	o.Gloss = (lay1.a * splat_control.r + lay2.a * splat_control.g + lay3.a * splat_control.b + lay4.a * splat_control.a);
//	o.Specular = (_ShininessL0 * splat_control.r + _ShininessL1 * splat_control.g + _ShininessL2 * splat_control.b + _ShininessL3 * splat_control.a);
//}


//// vertex-to-fragment interpolation data
//struct v2f_surf {
//  float4 pos : SV_POSITION;
//  float4 pack0 : TEXCOORD0; // _Control _Splat0
//  float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
//  half3 worldNormal : TEXCOORD2;
//  float3 worldPos : TEXCOORD3;
//  SHADOW_COORDS(4)
//  UNITY_FOG_COORDS(5)
//};
//float4 _Control_ST;
//float4 _Splat0_ST;
//float4 _Splat1_ST;
//float4 _Splat2_ST;

//// vertex shader
//v2f_surf vert_surf (appdata_full v) {
//  v2f_surf o;
//  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
//  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
//  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
//  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
//  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
//  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
//  float3 worldPos = mul(_Object2World, v.vertex).xyz;
//  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
//  o.worldPos = worldPos;
//  o.worldNormal = worldNormal;

//  TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
//  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
//  return o;
//}

//// fragment shader
//fixed4 frag_surf (v2f_surf IN) : SV_Target {
//  // prepare and unpack data
//  Input surfIN;
//  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
//  surfIN.uv_Control.x = 1.0;
//  surfIN.uv_Splat0.x = 1.0;
//  surfIN.uv_Splat1.x = 1.0;
//  surfIN.uv_Splat2.x = 1.0;
//  surfIN.uv_Splat3.x = 1.0;
//  surfIN.uv_Control = IN.pack0.xy;
//  surfIN.uv_Splat0 = IN.pack0.zw;
//  surfIN.uv_Splat1 = IN.pack1.xy;
//  surfIN.uv_Splat2 = IN.pack1.zw;
//  float3 worldPos = IN.worldPos;
//  #ifndef USING_DIRECTIONAL_LIGHT
//    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
//  #else
//    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
//  #endif
//  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
//  #ifdef UNITY_COMPILER_HLSL
//  SurfaceOutput o = (SurfaceOutput)0;
//  #else
//  SurfaceOutput o;
//  #endif
//  o.Albedo = 0.0;
//  o.Emission = 0.0;
//  o.Specular = 0.0;
//  o.Alpha = 0.0;
//  o.Gloss = 0.0;
//  fixed3 normalWorldVertex = fixed3(0,0,1);
//  o.Normal = IN.worldNormal;
//  normalWorldVertex = IN.worldNormal;

//  // call surface function
//  surf (surfIN, o);
//  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
//  fixed4 c = 0;
//  c += LightingT4MBlinnPhong (o, lightDir, worldViewDir, atten);
//  c.a = 0.0;
//  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
//  UNITY_OPAQUE_ALPHA(c.a);
//  return c;
//}

//ENDCG

//}

//	// ---- meta information extraction pass:
//	Pass {
//		Name "Meta"
//		Tags { "LightMode" = "Meta" }
//		Cull Off

//CGPROGRAM
//// compile directives
//#pragma vertex vert_surf
//#pragma fragment frag_surf
//#pragma exclude_renderers xbox360 ps3
//#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
//#include "HLSLSupport.cginc"
//#include "UnityShaderVariables.cginc"
//// Surface shader code generated based on:
//// writes to per-pixel normal: no
//// writes to emission: no
//// needs world space reflection vector: no
//// needs world space normal vector: no
//// needs screen space position: no
//// needs world space position: no
//// needs view direction: no
//// needs world space view direction: no
//// needs world space position for lighting: no
//// needs world space view direction for lighting: YES
//// needs world space view direction for lightmaps: no
//// needs vertex color: no
//// needs VFACE: no
//// passes tangent-to-world matrix to pixel shader: no
//// reads from normal: no
//// 4 texcoords actually used
////   float2 _Control
////   float2 _Splat0
////   float2 _Splat1
////   float2 _Splat2
//#define UNITY_PASS_META
//#include "UnityCG.cginc"
//#include "Lighting.cginc"

//#define INTERNAL_DATA
//#define WorldReflectionVector(data,normal) data.worldRefl
//#define WorldNormalVector(data,normal) normal

//// Original surface shader snippet:
//#line 21 ""
//#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
//#endif

////#pragma surface surf T4MBlinnPhong
////#pragma exclude_renderers xbox360 ps3

//sampler2D _Control;
//sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
//fixed _ShininessL0;
//fixed _ShininessL1;
//fixed _ShininessL2;
//fixed _ShininessL3;
//float4 _Tiling3;
//fixed4 _SpecDir;

//inline fixed4 LightingT4MBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
//{
//	fixed diff = max (0, dot (s.Normal, lightDir));
//	//fixed nh = max (0, dot (s.Normal, halfDir));
//	fixed nh = max (0, dot (normalize(s.Normal), normalize(halfDir+_SpecDir.xyz)));
//	fixed spec = pow (nh, s.Specular*128) * s.Gloss;
	
//	fixed4 c;
//	//c.rgb = (s.Albedo * _LightColor0.rgb * diff + _SpecColor.rgb * spec) * (atten*2);
//	c.rgb = (s.Albedo*_SpecColor.a+_SpecColor.rgb*spec)*(atten*2);
//	c.a = 0.0;
//	return c;
//}

//struct Input {
//	float2 uv_Control : TEXCOORD0;
//	float2 uv_Splat0 : TEXCOORD1;
//	float2 uv_Splat1 : TEXCOORD2;
//	float2 uv_Splat2 : TEXCOORD3;
//	float2 uv_Splat3 : TEXCOORD4;
//};
 
//void surf (Input IN, inout SurfaceOutput o) {
//	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
		
//	fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);
//	fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
//	fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
//	fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);
//	o.Alpha = 0.0;
//	o.Albedo.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
//	o.Gloss = (lay1.a * splat_control.r + lay2.a * splat_control.g + lay3.a * splat_control.b + lay4.a * splat_control.a);
//	o.Specular = (_ShininessL0 * splat_control.r + _ShininessL1 * splat_control.g + _ShininessL2 * splat_control.b + _ShininessL3 * splat_control.a);
//}

//#include "UnityMetaPass.cginc"

//// vertex-to-fragment interpolation data
//struct v2f_surf {
//  float4 pos : SV_POSITION;
//  float4 pack0 : TEXCOORD0; // _Control _Splat0
//  float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
//};
//float4 _Control_ST;
//float4 _Splat0_ST;
//float4 _Splat1_ST;
//float4 _Splat2_ST;

//// vertex shader
//v2f_surf vert_surf (appdata_full v) {
//  v2f_surf o;
//  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
//  o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
//  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
//  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
//  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
//  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
//  float3 worldPos = mul(_Object2World, v.vertex).xyz;
//  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
//  return o;
//}

//// fragment shader
//fixed4 frag_surf (v2f_surf IN) : SV_Target {
//  // prepare and unpack data
//  Input surfIN;
//  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
//  surfIN.uv_Control.x = 1.0;
//  surfIN.uv_Splat0.x = 1.0;
//  surfIN.uv_Splat1.x = 1.0;
//  surfIN.uv_Splat2.x = 1.0;
//  surfIN.uv_Splat3.x = 1.0;
//  surfIN.uv_Control = IN.pack0.xy;
//  surfIN.uv_Splat0 = IN.pack0.zw;
//  surfIN.uv_Splat1 = IN.pack1.xy;
//  surfIN.uv_Splat2 = IN.pack1.zw;
//  #ifdef UNITY_COMPILER_HLSL
//  SurfaceOutput o = (SurfaceOutput)0;
//  #else
//  SurfaceOutput o;
//  #endif
//  o.Albedo = 0.0;
//  o.Emission = 0.0;
//  o.Specular = 0.0;
//  o.Alpha = 0.0;
//  o.Gloss = 0.0;
//  fixed3 normalWorldVertex = fixed3(0,0,1);

//  // call surface function
//  surf (surfIN, o);
//  UnityMetaInput metaIN;
//  UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
//  metaIN.Albedo = o.Albedo;
//  metaIN.Emission = o.Emission;
//  return UnityMetaFragment(metaIN);
//}

//ENDCG

//}

	// ---- end of surface shader generated code

#LINE 70
 
}
FallBack "Specular"
}