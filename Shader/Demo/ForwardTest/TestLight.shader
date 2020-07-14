Shader "Unlit/TestLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _ VERTEXLIGHT_ON
            //#pragma multi_compile_fwdbase
            //#define VERTEXLIGHT_ON

            #include "UnityCG.cginc"
            #include "SimpleLighting.cginc"

            ENDCG
        }
        
        Pass
        {
            tags{"LightMode"="ForwardAdd"}
            blend one one
            zwrite off
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            //#define VERTEXLIGHT_ON
            //#define POINT
            #include "UnityCG.cginc"
            #include "SimpleLighting.cginc"

            ENDCG
        }
    }
}
