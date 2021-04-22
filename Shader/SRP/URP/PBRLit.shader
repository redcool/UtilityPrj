Shader "URP/PBRLit"
{
    Properties
    {
        [Header(MainTexture)]
        [MainTexture]_BaseMap("_BaseMap",2d) = ""{}
        [MainColor][hdr]_Color("_Color",color) = (1,1,1,1)
        [Normal]_NormalMap("_NormalMap",2d) ="bump"{}
        _NormalScale("_NormalScale",float) = 1

        [Header(PBRMask)]
        _MetallicMaskMap("_MetallicMaskMap(Metallic(R),Smoothness(G),Occlusion(B))",2d) = "white"{}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("_Smoothness",range(0,1)) = 0.5
        _Occlusion("_Occlusion",range(0,1)) = 0.5

        [Header(Emission)]
        [ToggleOff]_EmissionOn("_EmissionOn",int) = 0
        _EmissionMap("_EmissionMap",2d) = "white"{}
        [hdr]_EmissionColor("_EmissionColor",Color) = (1,1,1,1)

        [Header(AlphaTest)]
        [Toggle]_CutoffOn("_CutoffOn",float) = 0
        _Cutoff("_Cutoff",range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #include "Lib/PBRLitInput.hlsl"
            #include "Lib/PBRLitForwardPass.hlsl"
            ENDHLSL
        }
    }
}
