// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/1"
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
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #define DIRECTIONAL_COOKIE

            #include "AutoLight.cginc"

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
                float3 posLight:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Cookie;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                float3 posWorld = mul(unity_ObjectToWorld,v.vertex);
                o.posLight = mul(unity_WorldToLight,posWorld);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float cookieAtten = 1;
                if(_WorldSpaceLightPos0.w == 0){
                    cookieAtten = tex2D(_Cookie,i.posLight.xy).r;
                }
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * 1;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #define DIRECTIONAL_COOKIE
            #include "AutoLight.cginc"

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
                float4 posLight:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

        //     uniform float4x4 unity_WorldToLight; // transformation 
        //     // from world to light space (from Autolight.cginc)
        //  uniform sampler2D _LightTexture0; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                float4 posWorld = mul(unity_ObjectToWorld,v.vertex);
                o.posLight = mul(unity_WorldToLight,posWorld);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float cookieAtten = 1;
                // if(_WorldSpaceLightPos0.w == 0){
                    cookieAtten = tex2D(_LightTexture0,i.posLight.xy/i.posLight.w).a;
                // }
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * cookieAtten;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
