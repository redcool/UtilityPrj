Shader "Unlit/Noise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
CGINCLUDE

    half N21(half2 uv){
        return frac(sin(dot(uv,half2(12.678,78.234))) * 54321.123);
    }

    half N21(half2 uv,half cellSize){
        uv = floor(uv * cellSize);
        return N21(uv);
    }

ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv = ceil(i.uv *100);
                // return uv.xyxy;
                return N21(i.uv,10);
            }
            ENDCG
        }
    }
}
