// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "PowerDiffuse/Lit" {
  /**
    基础渲染.
    光照模型 : blinn phong + gi
    CustomLight.cginc : 处理光照计算,光照图, sh等.
    RenderingCore.cginc : 组织数据,几何,gi
    支持2平行光:
      1 场景光照
        _WorldSpaceLightPos0(实时光照), _MainLightDir(光照图,通过LightingProcess.cs来传递光照数据)
      2 物体自身的光照信息 
        _LightDir
    
  */
  Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Color ("Main Color", Color) = (1,1,1,1)

    [Header(NormalMap)]
    _BumpMap ("Normalmap", 2D) = "bump" {}
    _NormalMapScale("_NormalMapScale",range(0.001,5)) = 1
    // [Toggle]_UseVertexNormal("UseVertexNormal",int) = 0

    [Header(CullMode)]
    [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull Mode",float) = 2

    [Header(AlphaTest)]
    [Toggle(ALPHA_TEST_ON)] _AlphaTestOn("AlphaTest On?",int) = 0
    _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

    [Header(Depth)]
    [Toggle]_ZWrite("Zwrite",int) = 1

    [Header(BlendMode)]
    [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("_SrcBlend", Float) = 1.0
    [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("_DstBlend", Float) = 0.0

    [Header(Emission)]
    _Illum ("Illumin (A)", 2D) = "white" {}
    _IllumColor("_IllumColor",color) = (1,1,1,1)
    _EmissionScale("Emission Scale",float) = 0

    [Header(Custom Light)]
    [Toggle]_CustomLightOn("Custom Light?",int)=0
    _LightDir("Light Dir",vector) = (0,1,0,0)
    _LightColor("Light Color",color) = (0,0,0,1)

    [Header(SpecularSettings)]
    _SpecColor("_SpecColor",Color)=(1,1,1,1)
    _SpecIntensity("_SpecIntensity",range(0.1,1)) = 0.5
    _Gloss("_Gloss",range(0.01,5))= 0.5

    [Header(WeatherController)]
    //[KeywordEnum(None,Snow,Surface_Wave)]_Feature("Features",float) = 0
    [Toggle(_FEATURE_NONE)]_DisableWeather("Disable Weather ?",int) = 1

    [Header(Wind)]
    //[Toggle(PLANTS_OFF)]_PlantsOff("禁用风力",float) = 0
    [Toggle(PLANTS_OFF)]_Plants_Off("禁用风力",float) = 1
    [Toggle(EXPAND_BILLBOARD)]_ExpandBillboard("叶片膨胀?",float) = 0
    _Wave("抖动(树枝,边抖动,风向偏移,风向回弹)",vector) = (0,0.2,0.2,0.1)
    _Wind("风力(xyz:方向,w:风强)",vector) = (1,1,1,1)
    _AttenField("无抖动范围 (x: 水平距离,y:竖直距离)",vector) = (1,1,1,1)
    _WorldPos("_WorldPos",vector)=(0,0,0,0)
    _WorldScale("_WorldScale",vector)=(1,1,1,1)

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
    
    [Header(Ripple)]
    [Toggle(RIPPLE_ON)]_RippleOn("RippleOn?",int)=0
    _RippleTex("RippleTex",2d)=""{}
    _RippleScale("RippleScale",range(1,100)) = 1
    _RippleIntensity("RippleIntensity",range(0,1)) = 1
    _RippleColorTint("RippleColorTint",color) = (0.8,0.8,0.8,1)
    _RippleSpeed("RippleSpeed",range(0,2.4)) = 1

    [Header(Daytime)]
    [Toggle]_DaytimeOn("Daytime On?",int)=0
  }


  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 300
    
    // ---- forward rendering base pass:
    Pass {
      Name "FORWARD"
      Tags { "LightMode" = "ForwardBase" }
      Blend [_SrcBlend][_DstBlend]
      cull [_Cull]
      zwrite[_ZWrite]

      CGPROGRAM
      // compile directives
      #pragma vertex vert_surf
      #pragma fragment frag_surf
      #pragma target 3.0
      #pragma multi_compile_instancing
	    #pragma multi_compile_fog
      #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
      #pragma multi_compile_fwdbase nodynlightmap nodirlightmap
      // #pragma skip_variants DIRECTIONAL_COOKIE POINT_COOKIE SPOT
      // #pragma skip_variants LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON
      #define UNITY_PASS_FORWARDBASE

      #pragma target 3.0
      #pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
      #pragma shader_feature SNOW_NOISE_MAP_ON
      #pragma shader_feature DISABLE_SNOW_DIR
      #pragma shader_feature _HEIGHT_SNOW
      #pragma shader_feature RIPPLE_ON
      #pragma multi_compile _ PLANTS
      #pragma multi_compile _ PLANTS_OFF
      //#pragma shader_feature EXPAND_BILLBOARD
      #pragma multi_compile _ RAIN_REFLECTION
      #pragma multi_compile _ ALPHA_TEST_ON
      //#define SNOW

      #include "HLSLSupport.cginc"
      #include "UnityShaderVariables.cginc"
      #include "UnityShaderUtilities.cginc"
      #include "UnityCG.cginc"
      #include "Lighting.cginc"
      #include "AutoLight.cginc"
      #include "UnityStandardUtils.cginc"
      #include "../FogLib.cginc"
      #include "../NatureLibMacro.cginc"
      #include "../CustomLight.cginc"
      #include "../RenderingCore.cginc"

      ENDCG

    }
    
    Pass {
      Name "FORWARD"
      Tags { "LightMode" = "ForwardAdd" }
      ZWrite Off Blend One One

      CGPROGRAM
      // compile directives
      #pragma vertex vert_surf_add
      #pragma fragment frag_surf_add
      #pragma target 3.0
      #pragma multi_compile_instancing
      #pragma multi_compile_fog
      #pragma multi_compile _ ALPHA_TEST_ON

      #pragma skip_variants INSTANCING_ON
      #pragma multi_compile_fwdadd nodynlightmap nodirlightmap
      #include "HLSLSupport.cginc"
      #include "UnityShaderVariables.cginc"
      #include "UnityShaderUtilities.cginc"

      #if !defined(INSTANCING_ON)
      #define UNITY_PASS_FORWARDADD
      #include "UnityCG.cginc"
      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      //#define SNOW
      #include "../NatureLibMacro.cginc"
      #include "../CustomLight.cginc"
      #include "../FogLib.cginc"
      #include "../RenderingCore.cginc"
      
      #endif


      ENDCG

    }

    Pass {
      Tags { "LightMode" = "ShadowCaster" }
      Blend [_SrcBlend][_DstBlend]
      cull [_Cull]
      zwrite[_ZWrite]

      CGPROGRAM
      // compile directives
      #pragma vertex vert_surf
      #pragma fragment frag_surf
      #pragma target 3.0
      #pragma multi_compile_instancing
	    #pragma multi_compile_fog
      #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
      // #pragma skip_variants DIRECTIONAL_COOKIE POINT_COOKIE SPOT
      // #pragma skip_variants LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON

      #pragma target 3.0
      #pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
      #pragma shader_feature SNOW_NOISE_MAP_ON
      #pragma shader_feature DISABLE_SNOW_DIR
      #pragma shader_feature _HEIGHT_SNOW
      #pragma shader_feature RIPPLE_ON
      #pragma multi_compile _ PLANTS
      #pragma multi_compile _ PLANTS_OFF
      //#pragma shader_feature EXPAND_BILLBOARD
      #pragma multi_compile _ RAIN_REFLECTION
      #pragma multi_compile _ ALPHA_TEST_ON
      //#define SNOW

      #include "HLSLSupport.cginc"
      #include "UnityShaderVariables.cginc"
      #include "UnityShaderUtilities.cginc"
      #include "UnityCG.cginc"
      #include "Lighting.cginc"
      #include "AutoLight.cginc"
      #include "UnityStandardUtils.cginc"
      #include "../FogLib.cginc"
      #include "../NatureLibMacro.cginc"
      #include "../CustomLight.cginc"
      #include "../RenderingCore.cginc"

      ENDCG

    }

  }
  CustomEditor "WeatherInspector"
  FallBack "Legacy Shaders/Diffuse"
}
