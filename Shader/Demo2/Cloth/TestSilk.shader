Shader "Unlit/TestSilk"
{
    Properties
    {
        _RoughT("_RoughT",range(0,1)) = 1
        _RoughB("_RoughB",range(0,1)) = 1
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
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal:TEXCOORD2;
                float3 tangent:TEXCOORD3;
                float3 binormal:TEXCOORD4;
                float3 worldPos:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _WorldSpaceLightPosition;
            float _RoughB,_RoughT;

            #define INV_PI 1/3.14

            inline float D_GGXAnisoNoPI(float TdotH, float BdotH, float NdotH, float roughnessT, float roughnessB)
            {
                float a2 = roughnessT * roughnessB;
                float3 v = float3(roughnessB * TdotH, roughnessT * BdotH, a2 * NdotH);
                float  s = dot(v, v);

                // If roughness is 0, returns (NdotH == 1 ? 1 : 0).
                // That is, it returns 1 for perfect mirror reflection, and 0 otherwise.
                return (a2 * a2 * a2)/( s * s);
            }

            float D_GGXAniso(float TdotH, float BdotH, float NdotH, float roughnessT, float roughnessB)
            {
                return INV_PI * D_GGXAnisoNoPI(TdotH, BdotH, NdotH, roughnessT, roughnessB);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent.xyz = UnityObjectToWorldDir(v.tangent);
                o.binormal = cross(o.normal,o.tangent) * v.tangent.w;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.normal);
                float3 t = normalize(i.tangent);
                float3 b = normalize(i.binormal);
                float3 l = UnityWorldSpaceLightDir(i.worldPos);
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 h = normalize(l + v);
// return h.xyzx;

                float nl = (dot(n,l));
                float th = (dot(t,h));
                float bh = (dot(b,h));
                float nh = (dot(n,h));
                float nv = dot(n,v);
                float hv = dot(h,v);

                float dn = length(fwidth(n));
                return smoothstep(0.01,0.2,dn);
                
                return smoothstep(0.,2,saturate(nv + nh) );
                // return smoothstep(0.6,.9,nh);
                return D_GGXAniso(th,bh,nh,_RoughT,_RoughB) * (nl*0.5+0.5);
            }
            ENDCG
        }
    }
}
