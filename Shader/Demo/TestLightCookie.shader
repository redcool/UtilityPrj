// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestLightCookie"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cookie("cookie",2d) = ""{}
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 posLight:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // unity lightcookie vars
            // float4x4 unity_WorldToLight;
            // sampler2D _LightTexture0;
            
            float4x4 _WorldToLight;
            sampler2D _Cookie;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.posLight = mul(_WorldToLight,mul(unity_ObjectToWorld,v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.posLight.xy/i.posLight.w + 0.5;

                float atten = tex2D(_Cookie,uv).a;
                return atten;
            }
            ENDCG
        }
    }
}
