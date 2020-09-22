// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/RampThinFilm"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _RampMap("RampMap",2d) = ""{}
        _NoiseMap("NoiseMap",2d) = ""{}
        _NoiseScale("_NoiseScale",float) = 10
        _Tiling("_Tiling",float) = 1
    }

    CGINCLUDE
        sampler2D _RampMap;
        sampler2D _NoiseMap;
        float _NoiseScale;
        float _Tiling;

        struct ThinFilmInfo{
            sampler2D rampMap;
            sampler2D noiseMap;
            float2 uv;
            float uvScale;
            float3 normal;
            float3 lightDir;
            float3 viewDir;
            float tiling;
        };

        float4 RampThinFilm(ThinFilmInfo info){
            fixed4 noise = tex2D(info.noiseMap,info.uv * info.uvScale);
            float3 n = normalize(info.normal + noise);
            float3 l = info.lightDir;

            float h = normalize(l + info.viewDir);
            float nl = dot(n,l);
            // float wnl = nl * 0.5 + 0.5;
            float snl = saturate(nl);
            float nh = (dot(n,h));
            return tex2D(info.rampMap,float2( (nh+noise.x) * info.tiling,nl));
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
                float4 vertex : SV_POSITION;
                float3 n:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.n = UnityObjectToWorldNormal(v.n);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.n);
                float3 l = _WorldSpaceLightPos0.xyz;
                float3 v = UnityWorldSpaceViewDir(i.worldPos);
                float nl = saturate(dot(n,l));

                ThinFilmInfo info = {_RampMap,_NoiseMap,i.uv,_NoiseScale,n,l,v,_Tiling};

                float3 thinFilm = RampThinFilm(info);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = col.rgb * nl*0.3 + thinFilm;
                return col;
            }
            ENDCG
        }
    }
}
