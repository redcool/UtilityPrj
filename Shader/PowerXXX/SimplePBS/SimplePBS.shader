// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

/**
    pbs渲染流程
    1 简化了gi(diffuse,specular)
    2 同LightingProcess传递光照信息
*/
Shader "Character/SimplePBS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        
        _NormalMap("NormalMap",2d) = "bump"{}
        _NormalMapScale("_NormalMapScale",range(0,5)) = 1

        _MetallicMap("_MetallicMap(R)",2d) = "white"{}
        _Metallic("_Metallic",range(0,1)) = 0.5

        _SmoothnessMap("SmoothnessMap(G)",2d) = "white"{}
        _Smoothness("Smoothness",range(0,1)) = 0

        _OcclusionMap("_OcclusionMap(B)",2d) = "white"{}
        _Occlusion("_Occlusion",range(0,1)) = 1

        _EnvCube("_EnvCube",cube) = "white"{}
        _EnvIntensity("_EnvIntensity",float) = 1

        _EmissionMap("_EmissionMap",2d) = "white"{}
        _Emission("_Emission",float) = 0

        _IndirectIntensity("_IndirectIntensity",float) = 0.5
//-------- 2nd light
        [Header(Light)]
        [Toggle]_CustomLightOn("_CustomLightOn",int) = 0
        _LightDir("_LightDir",vector) = (0,0.5,0,0)
        _LightColor("_LightColor",color) = (1,1,1,1)
//------- alpha test
        [Header(AlphaTest)]
        [Toggle]_AlphaTestOn("_AlphaTestOn",int) = 0

        [Header(AlphaBlendMode)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

        [Header(DepthMode)]
        [Toggle]_ZWriteOn("_ZWriteOn?",int) = 1

        [Header(CullMode)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
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
            Tags{"LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 3.0
            #define UNITY_BRDF_PBS BRDF1_Unity_PBS
            #include "SimplePBSCore.cginc"
           
            ENDCG
        }
    }
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
            #include "SimplePBSCore.cginc"
           
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
            #include "SimplePBSCore.cginc"
           
            ENDCG
        }
    }

    FallBack "Transparent/Cutout/VertexLit"
}
