Shader "Unlit/stencilWrite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange]_Stencil("_Stencil",range(0,255)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="AlphaTest"}
        LOD 100

        stencil{
            ref [_Stencil]
            // comp always
            pass replace
        }

        Pass
        {
            zwrite off
            colorMask 0
        }
    }
}
