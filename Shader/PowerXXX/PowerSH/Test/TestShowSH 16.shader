Shader "Unlit/ShowSH 16"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    CGINCLUDE
    #define PI 3.14159265358
    #define Y0(v) (1.0 / 2.0) * sqrt(1.0 / PI)
    #define Y1(v) sqrt(3.0 / (4.0 * PI)) * v.z
    #define Y2(v) sqrt(3.0 / (4.0 * PI)) * v.y
    #define Y3(v) sqrt(3.0 / (4.0 * PI)) * v.x
    #define Y4(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.x * v.z
    #define Y5(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.z * v.y
    #define Y6(v) 1.0 / 4.0 * sqrt(5.0 / PI) * (-v.x * v.x - v.z * v.z + 2 * v.y * v.y)
    #define Y7(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.y * v.x
    #define Y8(v) 1.0 / 4.0 * sqrt(15.0 / PI) * (v.x * v.x - v.z * v.z)
    #define Y9(v) 1.0 / 4.0 * sqrt(35.0 / (2.0 * PI)) * (3 * v.x * v.x - v.z * v.z) * v.z
    #define Y10(v) 1.0 / 2.0 * sqrt(105.0 / PI) * v.x * v.z * v.y
    #define Y11(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.z * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
    #define Y12(v) 1.0 / 4.0 * sqrt(7 / PI) * v.y * (2 * v.y * v.y - 3 * v.x * v.x - 3 * v.z * v.z)
    #define Y13(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.x * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
    #define Y14(v) 1.0 / 4.0 * sqrt(105.0 / PI) * (v.x * v.x - v.z * v.z) * v.y
    #define Y15(v) 1.0 / 4.0 * sqrt(35.0 / (2 * PI)) * (v.x * v.x - 3 * v.z * v.z) * v.x
    #define DEGREE 16

    StructuredBuffer<float4> _SHBuffer;

    float3 GetSH(float3 n){
        float coefs[DEGREE] = {Y0(n),Y1(n),Y2(n),Y3(n),Y4(n),Y5(n),Y6(n),Y7(n),Y8(n),Y9(n),Y10(n),Y11(n),Y12(n),Y13(n),Y14(n),Y15(n)};
        float3 c = 0;
        for(int i=0;i<DEGREE;i++){
            c += _SHBuffer[i] * coefs[i];
        }
        return c;
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.normal);
                return float4(GetSH(n),1);
            }
            ENDCG
        }
    }
}
