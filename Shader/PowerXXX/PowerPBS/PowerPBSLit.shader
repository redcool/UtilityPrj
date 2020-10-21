// Upgrade NOTE: replaced '_ObjectSpaceorld' with 'unity_ObjectToWorld'

Shader "PowerPBS/Lit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [hdr]_Color("Color",color) = (1,1,1,1)
        _NormalMap("NormalMap",2d) = "bump"{}
        _NormalScale("NormalScale",float) = 1

        _MetallicMap("MetallicMap(Metallic:R,Smoothness:A)",2d) = "white"{}
        _Metallic("Metallic",range(0,1)) = 0.5
        _Smoothness("Smoothness",range(0,1)) = 0.5

        _OcclusionMap("OcclusionMap(G))",2d)="white"{}
        _Occlusion("Occlusion",range(0,1)) = 1

        _HeightMap("Height map(B)",2d) = "white"{}
        _Height("Height",range(0,0.08)) = 0

        [hdr]_EmissionColor("Emission Color",color) = (1,1,1,1)
        _EmissionMap("EmissionMap",2d) = ""{}

        [Header(DetailMap)]
        [Toggle(DETAIL_MAP)]_DetailMapOn("_DetailMapOn",int) = 0
        [Toggle]_DetailUseUV2("_DetailUseUV2",int) = 0
        _DetailMaskMap("Detail Mask(A)",2d) = ""{}
        _DetailAlbedoMap("_DetailAlbedoMap",2d) = ""{}
        _DetailNormalMap("_DetailNormalMap",2d) = ""{}
        _DetailNormalScale("_DetailNormalScale",float) = 1

        [Space(20)][Header(ClearCoat)]
        [Toggle(CLEAR_COAT)]_ClearCoatOn("_ClearCoatOn",int) = 0
        [hdr]_ClearCoatSpecColor("_ClearCoatSpecColor",color) = (.3,.3,.3,1)
        _ClearCoatSmoothness("_ClearCoatSmoothness",range(0,1)) = 1
        _ClearCoatNormalMap("_ClearCoatNormalMap",2d)="bump"{}
        _ClearCoatNormalScale("_ClearCoatNormalScale",float) = 1

        [Space(20)][Header(Skin)]
        [Toggle(SKIN)]_SkinOn("SkinOn",int) = 0
        _SkinRampMap("_SkinRampMap",2d)=""{}
        _SSSTex("SSSTex,Curvature(R),Thickness(G)",2d) = ""{}
        _CurvatureScale("_CurvatureScale",range(0,1)) = 1
        _ThicknessScale("_ThicknessScale",range(0,1)) = 1
        _SkinDistortion("_SkinDistortion",float) = 1
        _SkinPower("_SkinPower",float) = 1
        _SkinSubColor("_SkinSubColor",color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase" "Queue"="Opaque"}
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma multi_compile _ CLEAR_COAT SKIN
            #pragma multi_compile _ DETAIL_MAP 

            #define FORWARD_BASE
            #include "PowerPBSForward.cginc"
            ENDCG
        }

        Pass
        {
            blend one one
            Tags{"LightMode"="ForwardAdd" "Queue"="Opaque"}
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_add
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile _ CLEAR_COAT SKIN
            #pragma multi_compile _ DETAIL_MAP 

            #include "PowerPBSForward.cginc"
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
