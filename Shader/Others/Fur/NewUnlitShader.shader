Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FurTex("FurTex",2d)=""{}
        _Density("_Density",float) = 1
        _Tile("_Tile",float) = 1
        _Length("length",float) =1
        _Rigidness("rigidness",float)=1
    }


    SubShader
    {
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
        pass{
            CGPROGRAM
            #define FUR_OFFSET 0
            #pragma vertex vert
            #pragma fragment frag
            #include "FurLib.cginc"
            ENDCG
        }
        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.1
            #pragma vertex vert
            #pragma fragment frag
            #include "FurLib.cginc"
            ENDCG
        }

              pass{
            CGPROGRAM
            #define FUR_OFFSET 0.2
            #pragma vertex vert
            #pragma fragment frag
            #include "FurLib.cginc"            
            ENDCG
        }
                pass{
            CGPROGRAM
            #define FUR_OFFSET 0.3
            #pragma vertex vert
            #pragma fragment frag
            #include "FurLib.cginc"            
            ENDCG
        }

                        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.4
            #pragma vertex vert
            #pragma fragment frag
            #include "FurLib.cginc"            
            ENDCG
        }

                        pass{
            CGPROGRAM
            #define FUR_OFFSET 0.5
            #pragma vertex vert
            #pragma fragment frag
            #include "FurLib.cginc"            
            ENDCG
        }
    }
}
