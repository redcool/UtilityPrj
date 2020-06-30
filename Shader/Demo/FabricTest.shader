// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/FabricTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        _FabricScatterScale("_FabricScatterScale",range(0,1)) = 1
        _FabricScatterColor("_FabricScatterColor",color) = (1,1,1,1)
        _Roughness("Roughness",float) = 1
        _Scale("_Scale",float) = 1
    }

    CGINCLUDE

inline float Pow4(float p){
    return p*p*p*p;
}
 inline float FabricD (float NdotH, float roughness)
 {
  return 0.96* roughness * pow(1 - NdotH, 2) + 0.057; 
 }
  
 inline half FabricScatterFresnelLerp(half nv, half scale)
 {
  half t0 = Pow4 (1 - nv); 
  half t1 = 0.4 * (1 - nv);
  return (t1 - t0) * scale + t0;
 }

    ENDCG

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
            float _FabricScatterScale;
            float4 _FabricScatterColor;
            float _Roughness;
            float _Scale;
            float4 _Color;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.n = UnityObjectToWorldNormal(v.n);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 n = normalize(i.n);
                float3 h = normalize(l+v);

                float nl = saturate(dot(n,l));
                float nv = saturate(dot(n,v));
                float nh = saturate(dot(n,h));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * nl* _Color;
                col += FabricD(nh,_Roughness);
                col += FabricScatterFresnelLerp(nv,_FabricScatterScale) * _FabricScatterColor * (nl *0.5+0.5) * _Scale;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
