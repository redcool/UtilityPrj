Shader "Unlit/TestCloth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Rough("_Rough",range(0,1)) = 0.5
        [hdr]_SheenColor("_SheenColor",color) = (1,1,1,1)
        _Value("_Value",vector) = (0,1,0,0)
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }
#define PI 3.1415
float CharlieD(float roughness, float ndoth)
{
    float invR = 1. / roughness;
    float cos2h = ndoth * ndoth;
    float sin2h = max(1. - cos2h,0.0078125);
    return (2. + invR) * pow(sin2h, invR * .5) / (2. * PI);
}

float AshikhminV(float ndotv, float ndotl)
{
    return 1. / (4. * (ndotl + ndotv - ndotl * ndotv));
}

float D_Ashikhmin(float roughness, float NoH) {
    // Ashikhmin 2007, "Distribution-based BRDFs"
	float a2 = roughness * roughness;
	float cos2h = NoH * NoH;
	float sin2h = max(1.0 - cos2h, 0.0078125); // 2^(-14/2), so sin2h^2 > 0 in fp16
	float sin4h = sin2h * sin2h;
	float cot2 = -cos2h / (a2 * sin2h);
	return 1.0 / (PI * (4.0 * a2 + 1.0) * sin4h) * (4.0 * exp(cot2) + sin4h);
}

            float _Rough;
            float4 _SheenColor;
            float4 _Value;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 n = normalize(i.normal);
                float3 h = normalize(l+v);

                float nv = saturate(dot(n,v));
                float nl = saturate(dot(n,l));
                float nh = saturate(dot(n,h));

                float V = AshikhminV(nv,nl);
                float D = CharlieD(_Rough,nh);

                float wnl = (dot(n,l) *0.5+0.5);
                // return V+D*V;
                D = smoothstep(_Value.x,_Value.y,D);
                return 1 - D;
                return _SheenColor * 1*D * 1 * wnl;
            }
            ENDCG
        }
    }
}
