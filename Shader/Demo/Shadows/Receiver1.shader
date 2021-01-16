Shader "Unlit/Receiver1"
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
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
                float3 normal:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _LightColor0;
            float4x4 unity_WorldToLight;
            sampler2D _LightTexture0;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TRANSFER_SHADOW(o);
                o.normal= UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 lightUV = mul(unity_WorldToLight,float4(i.worldPos,1)).xy;
                float lightFade = tex2D(_LightTexture0,lightUV).x;
                return lightFade;


                float nl = saturate(dot(i.normal,_WorldSpaceLightPos0.xyz));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float atten = SHADOW_ATTENUATION(i);
                return col * atten * nl * _LightColor0;
            }
            ENDCG
        }

         Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            ZWrite Off Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_LIGHTING_COORDS(1,2)
                float4 pos : SV_POSITION;
                float3 normal:TEXCOORD3;
                float3 worldPos:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {


                float nl = saturate(dot(i.normal,_WorldSpaceLightPos0.xyz));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // float atten = SHADOW_ATTENUATION(i);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                col.rgb *= atten * nl * _LightColor0;
                col.a  = 0;
                return col;
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
