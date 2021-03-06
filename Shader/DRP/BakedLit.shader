﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "DRP/BakedLit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma multi_compile_fwdbase
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            // #pragma multi_compile _ LIGHTMAP_ON

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1:TEXCOORD1;
                float3 normal:NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 uv1:TEXCOORD2;
                float3 normal:TEXCOORD3;
                float3 worldPos:TEXCOORD4;
                SHADOW_COORDS(5)
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LightColor0;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);

                TRANSFER_SHADOW(o)
                return o;
            }

            float SampleShadowMask(float2 uv){
                float4 rawOcclusionMask = UNITY_SAMPLE_TEX2D(unity_ShadowMask, uv);
                return saturate(dot(rawOcclusionMask, unity_OcclusionMaskSelector));
            }

            float4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                // sample the texture
                float4 baseColor = tex2D(_MainTex, i.uv);

                // atten ,diffuse atten * shadowmask atten
                float atten = saturate(dot(i.normal,_WorldSpaceLightPos0.xyz));
                atten *= SHADOW_ATTENUATION(i);
#if defined(LIGHTMAP_ON)
                atten *= SampleShadowMask(i.uv1);
                // return UNITY_SAMPLE_TEX2D(unity_ShadowMask, i.uv1);;
#endif
                // light 
                float3 lightColor = _LightColor0.xyz * atten;

                float4 col = 0;
                // diffuse 
                col.xyz = lightColor * baseColor.xyz;
#if defined(LIGHTMAP_ON)
                // lightmap 
                half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1.xy);
                half3 bakedColor = DecodeLightmap(bakedColorTex);      
                col.xyz += baseColor.xyz * bakedColor;
#endif
                col.a = baseColor.a;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
Fallback "Mobile/VertexLit"
}
