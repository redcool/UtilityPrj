Shader "Unlit/RenderToUV"
{
    Properties
    {
        _MainTex("_MainTex",2d)=""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ztest off
        cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv:TEXCOORD;
            };

            float4 uvOffset;
            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.uv * uvOffset.xy + uvOffset.zw;
                #if UNITY_UV_STARTS_AT_TOP
                uv.y = 1-uv.y;
                #endif
                o.vertex = float4(uv*2-1,0.5,1);
                o.uv = uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // return tex2D(_MainTex,i.uv);
                return 1;
            }
            ENDCG
        }
    }
}
