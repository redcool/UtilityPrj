Shader "Unlit/caster"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        cull front
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 depth:TEXCOORD;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.depth = o.vertex.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = i.depth.x/i.depth.y;
                #if defined(SHADER_TARGET_GLSL)
                    depth = depth *0.5+0.5;
                #elif defined(UNITY_REVERSED_Z)
                    depth = 1 -depth;
                #endif
                return EncodeFloatRGBA(depth);
            }
            ENDCG
        }
    }
}
