// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/receiver"
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
                float4 posLightSpace:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GlobalShadowMap;
            float4 _GlobalShadowMap_TexelSize;
            float4x4 _CamTransform;
            float _GlobalShadowIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.posLightSpace = mul(_CamTransform,worldPos);
                return o;
            }
            float PCFSample(float depth,float2 uv){
                float shadow = 0;
                for(int i=-1;i<2;i++){
                    for(int j =-1;j<2;j++){
                        float z = tex2D(_GlobalShadowMap,uv + float2(i,j) * _GlobalShadowMap_TexelSize);
                        shadow += depth > z? 1: _GlobalShadowIntensity;
                    }
                }
                return shadow/9;
            }
            float GetShadow(float4 posLightSpace){
                float3 projCoord = posLightSpace.xyz/posLightSpace.w;
                projCoord.xy = projCoord.xy * 0.5 + 0.5;

                float z = tex2D(_GlobalShadowMap,projCoord.xy).r;
                float depth = projCoord.z;
                // #if defined(UNITY_REVERSED_Z)
                // depth = 1-depth;
                // #endif
//return z;
                //return depth > z? 1: _GlobalShadowIntensity;
                return PCFSample(depth,projCoord.xy);
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float shadow = GetShadow(i.posLightSpace);
                return shadow;
            }
            ENDCG
        }
    }
}
