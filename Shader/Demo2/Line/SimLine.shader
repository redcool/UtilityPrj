Shader "Unlit/SimLine"
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float3 worldNormal:TEXCOORD3;
                float3 worldTangent:TEXCOORD4;
                float3 worldBitangent:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal,o.worldTangent) * v.tangent.w;
                return o;
            }

            float3 _MainLightPosition;
            #define _WorldSpaceLightPos0 _WorldSpaceLightPos0

            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.worldNormal );
                float3 t = normalize(i.worldTangent);
                float3 b = normalize(i.worldBitangent);
                float3 n1 = normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                float3 nd = abs(n1-n);
                float d = nd.x+nd.y+nd.z;
                // return d;

                float nt = dot(n1,t)*0.5+0.5;
                float nb = dot(n1,b) * 0.5+0.5;
                float nn = dot(n,n1)*0.5+0.5;
                float c = nb*nt;
                float e = (c*d+c)-.25;
                float e1 = smoothstep(0.02,0.1,e);

                return e1;
            }
            ENDCG
        }
    }
}
