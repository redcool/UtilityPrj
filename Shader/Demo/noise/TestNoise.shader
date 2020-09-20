// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampMap("Ramp",2d) = ""{}
        _NoiseMap("NoiseMap",2d) = ""{}
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
                float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float3 n:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampMap;
            sampler2D _NoiseMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.n = UnityObjectToWorldNormal(v.n);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 noise = tex2D(_NoiseMap,i.uv);
                float3 l = UnityWorldSpaceLightDir(i.worldPos);
                float3 v = UnityWorldSpaceViewDir(i.worldPos);
                float3 h = normalize(l+v);
                float3 n = normalize(i.n+noise.xyz);
                float nh = dot(n,h);
                float nl = (dot(n,l)*0.5+0.5);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 ramp = tex2D(_RampMap, float2(nl,nh));

                col.rgb *= ramp.rgb;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
