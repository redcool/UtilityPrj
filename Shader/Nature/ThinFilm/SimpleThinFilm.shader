// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/SimpleThinFilm"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Thickness("_Thickness",range(1,2000)) = 400
        _IOR("_IOR",vector) = (0.9,1,1.1,1.2)

        _NoiseMap("NoiseMap",2d) = ""{}
        _NoiseScale("_NoiseScale",float) = 1
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
            float _Thickness;
            Vector _IOR;

            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;
            float _NoiseScale;

            fixed thinFilmReflectance(fixed cosI, float lambda, float thickness, float IOR)
            {
                float PI = 3.1415926;
                fixed sin2R = saturate((1 - pow(cosI, 2)) / pow(IOR,2));
                fixed cosR = sqrt(1 - sin2R);
                float phi = 2.0*IOR*thickness*cosR / lambda + 0.5; //计算光程差
                fixed reflectionRatio = 1 - pow(cos(phi * PI*2.0)*0.5+0.5, 1.0);  //反射系数

                fixed  refRatio_min = pow((1 - IOR) / (1 + IOR), 2.0);

                reflectionRatio = refRatio_min + (1.0 - refRatio_min) * reflectionRatio;

                return reflectionRatio;
            }

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
                float2 noiseUV = TRANSFORM_TEX(i.uv,_NoiseMap);
                float4 noise = tex2D(_NoiseMap,float2(noiseUV));
                float3 n = normalize(i.n + noise*_NoiseScale);
                float3 l = _WorldSpaceLightPos0.xyz;
                float3 v = UnityWorldSpaceViewDir(i.worldPos);
                float3 h = normalize(l+v);

                float nl = saturate(dot(n,l));
                float nv = saturate(dot(n,v));
                float nh = dot(n,h);

                float r = thinFilmReflectance(nh,650,_Thickness,_IOR.x);
                float g = thinFilmReflectance(nh,510,_Thickness,_IOR.y);
                float b = thinFilmReflectance(nh,470,_Thickness,_IOR.z);
                return float4(r,g,b,1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
