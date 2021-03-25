Shader "Unlit/PowerFur"
{
    Properties
    {
        [Header(Main)]
        _MainTex ("Texture", 2D) = "white" {}
        [hdr]_Color("_Color",color) = (1,1,1,1)
        _FurMaskMap("_FurMaskMap (R:Alpha Culling,G:Vertex Offset Atten,B: AO)",2d)=""{}

        [Header(Vertex Offset)]
        [Toggle]_VertexOffsetAttenOn("_VertexOffsetAttenOn",int) = 0
        _Length("_Length",float) =1
        _Rigidness("_Rigidness",float)=1

        [Header(AO)]
        [Toggle]_VertexAOOn("_VertexAOOn",int) = 1
        [Toggle]_FragmentAOOn("_FragmentAOOn",int) = 1

        [Header(Fur)]
        // _Density("_Density",float) = 1
        // _FurRadius("_FurRadius",float) = 1
        // _OcclusionPower("_OcclusionPower",float) = 1
        // _OcclusionColor("_OcclusionColor",color) = (1,1,1,1)

        
        _UVOffset("_UVOffset(XY:Fur uv offset,ZW:Not Used)",vector) = (0,0,0,0)
        
        [Header(FlowMap)]
        [Toggle]_FlowMapOn("_FlowMapOn",int) = 0
        _FlowMap("_FlowMap",2d) = ""{}
        _FlowMapIntensity("_FlowMapIntensity",float) = 1

        [Header(Wind)]
        _WindSpeed("_WindSpeed",float) = 0
        _WindScale("_WindScale",float) = 0
        _WindDir("_WindDir",vector) = (1,0,0,0)

        [Header(Color)]
        [hdr]_Color1("Dark Color",color) = (1,1,1,1)
        [hdr]_Color2("Bright Color",color) = (0.5,.5,.5,1)
        
        [Header(Thickness)]
        _ThicknessMin("_ThicknessMin",float) = 0.1
        _ThicknessMax("_ThicknessMax",float) = 0.7
    }


    SubShader
    {
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
        // blend srcAlpha one
        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.05
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"
            ENDCG
        }
        
        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.1
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"
            ENDCG
        }

        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.15
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"            
            ENDCG
        }
        pass{
            
            CGPROGRAM
            #define FUR_OFFSET 0.2
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"            
            ENDCG
        }

         pass{
            CGPROGRAM
            #define FUR_OFFSET 0.25
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"            
            ENDCG
        }

        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.3
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"            
            ENDCG
        }
        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.35
            #pragma vertex vert
            #pragma fragment frag
            #include "PowerFurPass.cginc"            
            ENDCG
        }
        
    }
}
