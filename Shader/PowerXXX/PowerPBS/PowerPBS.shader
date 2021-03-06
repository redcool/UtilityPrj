﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

/**
    pbs渲染流程
    1 简化了gi(diffuse,specular)
    2 同LightingProcess传递光照信息

    2021/03/11 
        1 加入阴影
        2 调整Occlusion的算法
    
    2021/06/21
        PowerPBSInput.cginc中使用cbuffer UnityPerMaterial

    usecase :
    drp 
        uncomment 
            Tags{"LightMode"="ForwardBase" }
        comment
            #define URP_SHADOW
    urp
        comment
            Tags{"LightMode"="ForwardBase" }
        comment
            #define URP_SHADOW
*/
Shader "Character/PowerPBS"
{
    Properties
    {
        [Header(Lighting Process Is Required)]
        
        [Space(20)][Header(MainProp)]
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        
        [noscaleoffset]_NormalMap("NormalMap",2d) = "bump"{}
        _NormalMapScale("_NormalMapScale",range(0,5)) = 1

        [noscaleoffset]_MetallicMap("Metallic(R),Smoothness(G),Occlusion(B)",2d) = "white"{}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("Smoothness",range(0,1)) = 0
        _Occlusion("_Occlusion",range(0,1)) = 1

        [Space(10)][Header(Shadow)]
        [Toggle]_ApplyShadowOn("_ApplyShadowOn",int) = 1

		[Space(10)][Header(Detail4_Map Top Layer)]
		[Toggle]_Detail4_MapOn("_Detail4_MapOn",int) = 0
		[Enum(Multiply,0,Replace,1)]_Detail4_MapMode("_Detail4_MapMode",int) = 0
		_Detail4_Map("_Detail4_Map(RGB),Detail4_Mask(A)",2d) = "white"{}
		_Detail4_MapIntensity("_Detail4_MapIntensity",range(0,1)) = 1
		/*_Detail4_NormalMap("_Detail4_NormalMap",2d) = "bump"{}
		_Detail4_NormalMapScale("_Detail4_NormalMapScale",range(0,5)) = 1*/
		[Space(10)][Header(Detail3_Map)]
		[Toggle]_Detail3_MapOn("_Detail3_MapOn",int) = 0
		[Enum(Multiply,0,Replace,1)]_Detail3_MapMode("_Detail3_MapMode",int) = 0
		_Detail3_Map("_Detail3_Map(RGB),Detail3_Mask(A)",2d) = "white"{}
		_Detail3_MapIntensity("_Detail3_MapIntensity",range(0,1)) = 1
		/*_Detail3_NormalMap("_Detail3_NormalMap",2d) = "bump"{}
		_Detail3_NormalMapScale("_Detail3_NormalMapScale",range(0,5)) = 1*/
		[Space(10)][Header(Detail2_Map)]
		[Toggle]_Detail2_MapOn("_Detail2_MapOn",int) = 0
        [Enum(Multiply,0,Replace,1)]_Detail2_MapMode("_Detail2_MapMode",int) = 0
		_Detail2_Map("_Detail2_Map(RGB),EyeMask(A)",2d) = "white"{}
		_Detail2_MapIntensity("_Detail2_MapIntensity",range(0,1)) = 1
		/*_Detail2_NormalMap("_Detail2_NormalMap",2d) = "bump"{}
		_Detail2_NormalMapScale("_Detail2_NormalMapScale",range(0,5)) = 1*/
		[Space(10)][Header(Detail1_Map)]
		[Toggle]_Detail1_MapOn("_Detail1_MapOn",int) = 0
        [Enum(Multiply,0,Replace,1)]_Detail1_MapMode("_Detail1_MapMode",int) = 0
		_Detail1_Map("_Detail1_Map(rgb),MouthMask(A)",2d) = "white"{}
		_Detail1_MapIntensity("_Detail1_MapIntensity",range(0,1)) = 1
		/*_Detail1_NormalMap("_Detail1_NormalMap",2d) = "bump"{}
		_Detail1_NormalMapScale("_Detail1_NormalMapScale",range(0,5)) = 1*/
        [Space(10)][Header(DetailMap Bottom Layer)]
        [Toggle]_DetailMapOn("_DetailMapOn",int) = 0
        [Enum(Multiply,0,Replace,1)]_DetailMapMode("_DetailMapMode",int) = 0
        _DetailMap("_DetailMap(RGB),DetailMask(A)",2d) = "white"{}
        _DetailMapIntensity("_DetailMapIntensity",range(0,1)) = 1
        _DetailNormalMap("_DetailNormalMap",2d) = "bump"{}
        _DetailNormalMapScale("_DetailNormalMapScale",range(0,5)) = 1
        
        [Space(10)][Header(IBL)]
        [noscaleoffset]_EnvCube("_EnvCube",cube) = "white"{}
        _EnvIntensity("_EnvIntensity",float) = 1
        _ReflectionOffsetDir("_ReflectionOffsetDir",vector) = (0,0,0,0)

        [Space(10)][Header(Emission)]
        [noscaleoffset]_EmissionMap("_EmissionMap(RGB),EmissionMask(A)",2d) = "white"{}
        [hdr]_EmissionColor("_EmissionColor",color) = (1,1,1,1)
        _Emission("_Emission",float) = 0

        [Space(10)][Header(Indirect Diffuse)]
        _IndirectIntensity("_IndirectIntensity",float) = 0.5

        [Space(10)][Header(CustomLight)]
        [Toggle]_CustomLightOn("_CustomLightOn",int) = 0
        _LightDir("_LightDir",vector) = (0,0.5,0,0)
        _LightColor("_LightColor",color) = (1,1,1,1)

        [Space(10)][Header(AlphaTest)]
        [Toggle]_AlphaTestOn("_AlphaTestOn",int) = 0
        _Cutoff("_Cutoff",range(0,1)) = 0.5

        [Space(10)][Header(AlphaBlendMode)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

        [Space(10)][Header(AlphaMultiMode)]
        [Toggle]_AlphaPreMultiply("_AlphaPreMultiply",int) = 0

        [Space(10)][Header(DepthMode)]
        [Toggle]_ZWriteOn("_ZWriteOn?",int) = 1

        // [Space(10)][Header(CullMode)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2


        [Header(Height Cloth FrontSSS BackSSS)]
        _HeightClothSSSMask("_Height(R) , Cloth(G) , SSSMask(B,A)",2d) = "white"{} 

        [Space(10)][Header(SSS)]
        [Toggle]_SSSOn("_SSSOn",int) = 0
        _FrontSSSIntensity("_FrontSSSIntensity",range(0,1)) = 1
        _FrontSSSColor("_FrontSSSColor",color) = (1,0,0,0)
        _BackSSSIntensity("_BackSSSIntensity",range(0,1)) = 1
        _BackSSSColor("_BackSSSColor",color) = (1,0,0,0)

        [Space(10)][Header(ParallelOffset)]
        [Toggle]_ParallalOn("_ParallalOn",int) = 0

        _Height("_Height",range(0.005,0.08)) = 0
        
        [Space(10)][Header(Cloth)]
        [Toggle]_ClothOn("_ClothOn",int) = 0
        _ClothSpecWidthMin("_ClothSpecWidthMin",range(0.1,1)) =0.8
        _ClothSpecWidthMax("_ClothSpecWidthMax",range(0.1,1)) =1
        
        [Toggle]_ClothMaskOn("_ClothMaskOn",int) = 0

        [Space(10)][Header(Hair)]
        [Toggle]_HairOn("_HairOn (SpecTerm Use StrandSpec)",int) = 0
        [Header(Tangent Binormal Mask Map)]
        _TBMaskMap("_TBMaskMap(R,white:use binormal)",2d) = "white"{}

        [Header(Tangent Shift)]
        _ShiftTex("_ShiftTex(g:shift,b:mask)",2d) = ""{}
		_HairAoIntensity("HairAoIntensity",range(0,1))=1

        [Header(Spec Shift1)]
        _Shift1("_Shift1",float) = 0
        _SpecPower1("_SpecPower1",range(0.01,1)) = 1
        _SpecColor1("_SpecColor1",color) = (1,1,1,1)
        _SpecIntensity1("_SpecIntensity1",float) = 10
        
        [Header(Spec Shift2)]
        _Shift2("_Shift2",float) = 0
        _SpecPower2("_SpecPower2",range(0.01,1)) = 1
        _SpecColor2("_SpecColor2",color) = (1,1,1,1)
        _SpecIntensity2("_SpecIntensity2",float) = 10
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 431
        Blend [_SrcMode][_DstMode]
        ZWrite [_ZWriteOn]
        Cull[_CullMode]

        Pass
        {
            // Tags{"LightMode"="ForwardBase" } // drp need this, otherwise shadow out
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            // #pragma multi_compile_fwdbase
            #pragma target 3.0
            #define UNITY_BRDF_PBS BRDF1_Unity_PBS
            #define PBS1

            #define URP_SHADOW // for urp 
            #include "PowerPBSForward.cginc"
           
            ENDCG
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define URP_SHADOW
            #include "PowerPBSShadowCasterPass.cginc"
            ENDCG
        }
    }
/*    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 421
        Blend [_SrcMode][_DstMode]
        ZWrite [_ZWriteOn]
        Cull[_CullMode]

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 3.0
            #define UNITY_BRDF_PBS BRDF2_Unity_PBS
            #define PBS2
            #include "PowerPBSForward.cginc"
           
            ENDCG
        }
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend [_SrcMode][_DstMode]
        ZWrite [_ZWriteOn]
        Cull[_CullMode]

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 3.0
            #define UNITY_BRDF_PBS BRDF3_Unity_PBS
            #define PBS3
            #include "PowerPBSForward.cginc"
           
            ENDCG
        }
    }
*/
    FallBack "Diffuse"
}
