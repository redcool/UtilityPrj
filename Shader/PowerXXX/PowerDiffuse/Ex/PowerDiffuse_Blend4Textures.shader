// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PowerDiffuse/Blend4Textures" {
  Properties {
    // [Toggle(NORMAL_MAP_ON)] _NormalMapOn("_NormalMapOn ?",float) = 0
    // [Toggle(BLINN_ON)]_BlinnOn("Blinn on",int) = 1

    [Header(Specular)]
    _SpecDir("Specular Direction",Vector)=(0,0,0,0)
    _SpecColor ("Specular Color(RGB); diff(A)", Color) = (1, 1, 1, 1)

    // [Toggle]_CustomLightOn("Custom Light?",int)=0
    // _LightDir("Light Dir",vector) = (0,1,0,0)
    // _LightColor("Light Color",color) = (0,0,0,1)

    [Header(Splat0)]
    _Splat0 ("Layer 1", 2D) = "white" {}
		[NoScaleOffset]_BumpSplat0 ("Layer1Normalmap", 2D) = "bump" {}
		_NormalRange("NormalRange",Range(0.1,2))=1
    _ShininessL0 ("Layer1Shininess", Range (0.03, 1)) = 0.078125
    _GlossIntensity0("_GlossIntensity0",Range (0,10)) = 1

    [Header(Splat1)]
    _Splat1 ("Layer 2", 2D) = "white" {}
    [NoScaleOffset]_BumpSplat1 ("Layer2Normalmap", 2D) = "bump" {}
    _NormalRange1("NormalRange1",Range(0.1,2))=1
    _ShininessL1 ("Layer2Shininess", Range (0.03, 1)) = 0.078125
    _GlossIntensity1("_GlossIntensity1",range(0,10)) = 1

    [Header(Splat2)]
    _Splat2 ("Layer 3", 2D) = "white" {}
    [NoScaleOffset]_BumpSplat2 ("Layer3Normalmap", 2D) = "bump" {}
    _NormalRange2("NormalRange2",Range(0.1,2))=1
    _ShininessL2 ("Layer3Shininess", Range (0.03, 10)) = 0.078125
	  _GlossIntensity2("_GlossIntensity3",range(0,10)) = 1
    
    [Header(Splat3)]
    _Splat3 ("Layer 4", 2D) = "white" {}
    [NoScaleOffset]_BumpSplat3 ("Layer4Normalmap", 2D) = "bump" {}
    _NormalRange3("NormalRange3",Range(0.1,2))=1
    _ShininessL3 ("Layer4Shininess", Range (0.03, 1)) = 0.078125
	  _GlossIntensity3("_GlossIntensity4",range(0,10)) = 1
	
    [Header(ControlMap)]
    // _Tiling3("_Tiling4 x/y", Vector)=(1,1,0,0)
    _Control ("Control (RGBA)", 2D) = "white" {}
    // _MainTex ("Never Used", 2D) = "white" {}
    
    [Header(WeatherController)]
    [Toggle(_FEATURE_NONE)]_DisableWeather("Disable Weather ?",int) = 1
    //commonly, script control them.
    [KeywordEnum(None,Snow,Surface_Wave)]_Feature("Features",float) = 0
    _WeatherIntensity("_WeatherIntensity",range(0,1)) = 1
    [Toggle(RAIN_REFLECTION)]_RainReflection("_RainReflection",int) = 0

    [Header(Snow)] 
    // 积雪是否有方向?
    [Toggle(DISABLE_SNOW_DIR)] _DisableSnowDir("Disable Snow Dir ?",float) = 0
    _DefaultSnowRate("Default Snow Rate",float) = 1.5
    //是否使用杂点扰动?
    [Toggle(SNOW_NOISE_MAP_ON)]_SnowNoiseMapOn("SnowNoiseMapOn",float) = 0
    [noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
    _NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

    _SnowDirection("Direction",vector) = (1,0,0,0)
    _SnowColor("Snow Color",color) = (1,1,1,1)
    _SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
    _SnowTile("tile",vector) = (1,1,1,1)
    _BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
    _ToneMapping("ToneMapping",range(0,1)) = 0
    _SplatSnowIntensity("积雪分层强度",vector) = (1,1,1,1)

    [Space(10)]
    [Header(Rain Specular)]
    _RainSpecDir("Rain Specular Direction",Vector)=(1,1,0,0)
    _RainSpecColor ("Rain Specular Color(RGB); diff(A)", Color) = (1, 1, 1, 1)
    _RainTerrainShininess("RainTerrainShininess",vector)=(1,1,1,1)

    [Space(20)]
    [Header(SurfaceWave)]
    _WaveLayerIntensity("流水(涟漪)分层强度",vector) = (1,1,1,1)
    _WaveColor("Color",color)=(1,1,1,1)
    _Tile("Tile",vector) = (5,5,10,10)
    _Direction("Direction",vector) = (0,1,0,-1)

    [noscaleoffset]_WaveNoiseMap("WaveNoiseMap",2d) = "bump"{}
    [Header(WaterEdge)]
    _WaveBorderWidth("WaveBorderWidth",range(0,1)) = 0.2
    _DirAngle("DirAngle",range(0,1)) = 0.8
    _WaveIntensity("WaveIntensity",range(0,1)) = 0.8

    [Header(Env Reflection)]
    _EnvTex("Env Tex",Cube) = ""{}
    _EnvColor("Env Color",color) = (1,1,1,1)
    _EnvNoiseMap("Env Noise Map",2d) = ""{}
    _EnvIntensity("Env Intensity",float) = 1
    _EnvTileOffset("Env Tile(xy),Offset(zw)",vector) = (1,1,0.1,0.1)
    _EnvLayerIntensity("环境反射分层强度",vector) = (1,1,1,1)

    [Header(Ripple)]
    [Toggle(RIPPLE_ON)]_RippleOn("RippleOn?",int) = 0
    _RippleTex("RippleTex",2d)=""{}
    _RippleScale("RippleScale",range(1,100)) = 1
    _RippleIntensity("RippleIntensity",range(0,1)) = 1
    _RippleColorTint("RippleColorTint",color) = (0.8,0.8,0.8,1)
    _RippleSpeed("RippleSpeed",range(0,2.4)) = 1
	[Header(Daytime)]
	[Toggle]_DaytimeOn("Daytime On?",int) = 0
  }
  
  SubShader {
    Tags {
      "SplatCount" = "4"
      "RenderType" = "Opaque"
    }

    Pass {
      Name "FORWARD"
      Tags { "LightMode" = "ForwardBase" }
      
      CGPROGRAM
      // compile directives
      #pragma target 3.0
      #pragma vertex vert_surf
      #pragma fragment frag_surf
      #pragma multi_compile_fog
      #pragma multi_compile_fwdbase
      #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
      // #pragma skip_variants POINT POINT_COOKIE SHADOWS_SCREEN VERTEXLIGHT_ON FOG_EXP FOG_EXP2 INSTANCING_ON
      // #pragma skip_variants  DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON  LIGHTMAP_SHADOW_MIXING SHADOWS_SCREEN SHADOWS_SHADOWMASK 

      #pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
      // #pragma shader_feature SNOW_NOISE_MAP_ON
      // #pragma shader_feature DISABLE_SNOW_DIR
      // #pragma shader_feature RIPPLE_ON
      // #pragma multi_compile _ RAIN_REFLECTION
	    // #pragma multi_compile _ NORMAL_MAP_ON
      // #pragma multi_compile _ BLINN_ON
      // #pragma multi_compile _ FOG_ON
      // #define NORMAL_MAP_ON
      // #define BLINN_ON
      // #define FOG_ON


      #define TERRAIN_WEATHER
      #include "PowerDiffuse_Blend4TexturesCore.cginc"

      ENDCG

    }
    Pass {
      Tags { "LightMode" = "ForwardAdd" }
      Blend one one
      zwrite off
      
      CGPROGRAM
      // compile directives
      #pragma target 3.0
      #pragma vertex vert_surf
      #pragma fragment frag_surf
      #pragma multi_compile_fog
      #pragma multi_compile_fwdadd
      #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
      // #pragma skip_variants POINT POINT_COOKIE SHADOWS_SCREEN VERTEXLIGHT_ON FOG_EXP FOG_EXP2 INSTANCING_ON
      // #pragma skip_variants  DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON  LIGHTMAP_SHADOW_MIXING SHADOWS_SCREEN SHADOWS_SHADOWMASK 

      // #pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
      // #pragma shader_feature SNOW_NOISE_MAP_ON
      // #pragma shader_feature DISABLE_SNOW_DIR
      // #pragma shader_feature RIPPLE_ON
      // #pragma multi_compile _ RAIN_REFLECTION
	    // #pragma multi_compile _ NORMAL_MAP_ON
      // #pragma multi_compile _ BLINN_ON
      // #pragma multi_compile _ FOG_ON
      #define NORMAL_MAP_ON
      #define BLINN_ON
      #define FOG_ON


      #define TERRAIN_WEATHER
      #define FORWARD_ADD
      #include "PowerDiffuse_Blend4TexturesCore.cginc"

      ENDCG

    }
    
  }
  CustomEditor "WeatherSpecTerrainInspector"
  Fallback "Legacy Shaders/VertexLit"
}