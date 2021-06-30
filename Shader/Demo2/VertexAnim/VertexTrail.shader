Shader "Unlit/VertexTrail"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveSpeed("_WaveSpeed",float) = 1
        _WaveScale("_WaveScale",float) = 1
        _TrailIntensity("_TrailIntensity",float) = 1
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
            #include "../Lib/NodeLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _WaveSpeed,_WaveScale;
            float _TrailIntensity;

            void CalcVertexTrail(inout float3 worldPos,float3 dir,float waveScale,float waveSpeed,float3 normal){
                float n = 0;
                float2 uv = worldPos.xz + _Time.y * waveSpeed;
                Unity_GradientNoise_float(uv,waveScale,n/**/);
                float dirAtten = saturate(dot(normal,dir));
                // dirAtten = smoothstep(0.1,0.9,dirAtten);
                worldPos += dir * n * dirAtten * _TrailIntensity;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 dir = -unity_ObjectToWorld._13_23_33;
                CalcVertexTrail(worldPos.xyz/**/,dir,_WaveScale,_WaveSpeed,worldNormal);

                o.vertex = UnityWorldToClipPos(worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
