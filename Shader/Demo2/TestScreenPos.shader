Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("_Scale",range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            cull off
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
                float4 posScreen:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;

            // float4 _ScreenParams;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex.xy = v.vertex.xy * 2;
                o.vertex.zw = float2(1,1);


                float4 clipPos = UnityObjectToClipPos(v.vertex);
                float w = clipPos.w;
                clipPos *= 0.5;
                o.posScreen = float4(clipPos.xy+clipPos.w,clipPos.z,w);
// o.vertex = clipPos;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 suv = i.vertex.xy /_ScreenParams.xy;
                suv.y = 1 -suv.y;

                // suv = i.posScreen.xy/i.posScreen.w;

                return tex2D(_MainTex,suv);
                return float4(suv,0,0);
                return float4(i.uv,0,0);
            }
            ENDCG
        }
    }
}
