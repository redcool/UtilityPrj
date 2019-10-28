// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/StandardMetallic_ChannelCombined"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _ControlMap("ControlMap", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}
		_EmissionMask("EmissionMask", 2D) = "white" {}
		_EmissionMaskParam("EmissionMaskParam", Vector) = (0,0,0,1)
        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        _DetailNormalMap("Normal Map", 2D) = "bump" {}

		

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
// Sphere clip
        [Toggle]_SphereClip("Enable Sphere Clip",float) = 0
        [Toggle]_SphereClipSign("SphereClip Sign",float) = 0
        // 使用代码全局设置这2个属性
        //_SphereClipBorderWidth("SphereClip BorderWidth",float) = 1
        //_SphereClipBorderColor("_SphereClipBorderColor",color) = (1,1,1,1)

// strand spec
        [Toggle]_HairSpec("Hair Spec",float) = 0
        _HairSpecMaskMap("Hair spec mask(r)",2d) = ""{}
        _HairSpecShiftMap("Hair Spec shift map(g)",2d) = ""{}
        _HairSpecShift1("_HairSpecShift1",float) = 0
        _HairSpecShift2("_HairSpecShift2",float) = 0
        _HairSpecColor1("_HairSpecColor1",color) = (1,1,1,1)
        _HairSpecColor2("_HairSpecColor2",color) = (1,1,1,1)
        _HairSpecPower1("_HairSpecPower1",float) = 10
        _HairSpecPower2("_HairSpecPower2",float) = 10
        _HairSpecIntensity1("_HairSpecIntensity1",float) = 1
        _HairSpecIntensity2("_HairSpecIntensity2",float) = 1
    }

    CGINCLUDE
        #define UNITY_SETUP_BRDF_INPUT MetallicSetup
        #define CHANNEL_COMBINED //metallic:r, occlusion:g,smoothness:a, emissionMask : b
        //#define UNITY_BRDF_PBS BRDF2_Unity_PBS
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        LOD 300


        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            cull [_CullMode]

            CGPROGRAM
            #pragma target 3.5
            
            // -------------------------------------
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

            #pragma shader_feature _SPHERECLIP_ON
            #pragma shader_feature _HAIRSPEC_ON

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma vertex vertBase
            #pragma fragment fragBase
            #include "UnityCustomStandardCoreForward.cginc"
            ENDCG
        }
        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.5

            // -------------------------------------

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP

            #pragma shader_feature _SPHERECLIP_ON
            #pragma shader_feature _HAIRSPEC_ON

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityCustomStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.5

            // -------------------------------------

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Deferred pass
        Pass
        {
            Name "DEFERRED"
            Tags { "LightMode" = "Deferred" }

            CGPROGRAM
            #pragma target 3.0
            #pragma exclude_renderers nomrt


            // -------------------------------------
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP

            #pragma multi_compile_prepassfinal
            #pragma multi_compile_instancing

            #pragma vertex vertDeferred
            #pragma fragment fragDeferred

            #include "UnityCustomStandardCore.cginc"

            ENDCG
        }

        // ------------------------------------------------------------------
        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityCustomStandardMeta.cginc"
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        LOD 150

        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 2.0
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            // SM2.0: NOT SUPPORTED shader_feature ___ _DETAIL_MULX2
            // SM2.0: NOT SUPPORTED shader_feature _PARALLAXMAP

            #pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #pragma vertex vertBase
            #pragma fragment fragBase
            #include "UnityCustomStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 2.0
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            // SM2.0: NOT SUPPORTED #pragma shader_feature ___ _DETAIL_MULX2
            // SM2.0: NOT SUPPORTED shader_feature _PARALLAXMAP
            #pragma skip_variants SHADOWS_SOFT

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityCustomStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 2.0
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma skip_variants SHADOWS_SOFT
            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }

        // ------------------------------------------------------------------
        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityCustomStandardMeta.cginc"
            ENDCG
        }
    }


    FallBack "VertexLit"
    CustomEditor "CustomStandardShaderGUIChannelCombined"
}
