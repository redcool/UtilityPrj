Shader "Unlit/pbr1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("_Smoothness",range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityLib.hlsl"

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
                float4 tSpace0:TEXCOORD1;
                float4 tSpace1:TEXCOORD2;
                float4 tSpace2:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Smoothness,_Metallic;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 n = TransformObjectToWorldNormal(v.normal);
                float3 worldPos = TransformObjectToWorld(v.vertex);
                o.tSpace0 = float4(0,0,n.x,worldPos.x);
                o.tSpace1 = float4(0,0,n.y,worldPos.y);
                o.tSpace2 = float4(0,0,n.z,worldPos.z);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 mainTex = tex2D(_MainTex, i.uv);
                float3 albedo = mainTex.xyz;
                float alpha = mainTex.w;

                float3 n = float3(i.tSpace0.z,i.tSpace1.z,i.tSpace2.z);
                float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
                float3 v = GetWorldSpaceViewDir(worldPos);
                float3 l = GetWorldSpaceLightDir(worldPos);

                float metallic = _Metallic;
                float smoothness = _Smoothness;
                float roughness = 1 - smoothness;
                float a = roughness * roughness;
                float a2  =a*a;

                float4 col = 0;

                // gi
                float3 sh = SampleSH(n);
                float3 giDiff = sh * albedo;
                col.xyz = giDiff;

                // direct light
                float3 h = normalize(l+v);
                float nh = saturate(dot(n,h));
                float nl = saturate(dot(n,l));

                float specTerm = D_GGXNoPI(nh,a2);
                float3 specColor = lerp(0.04,albedo,metallic) * specTerm;

                float3 diffColor = albedo;
                diffColor *= 1 - metallic;

                float3 radiance = _MainLightColor * nl;

                col.xyz += (diffColor + specColor) * radiance;
                col.w = alpha;

                return col;
            }
            ENDHLSL
        }
    }
}
