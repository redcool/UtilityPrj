// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestMie"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Power("_Power",float) = 1
        _SunSize("_SunSize",range(0,1)) = 0.04

        _Color0("_Color0",color) = (0,0,0.4,0)
        _Color1("_Color1",color) = (.2,0.4,0.3,0)
    }
    SubShader
    {
        cull off
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float3 normal:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Power;
            float _SunSize;
            float4 _Color1,_Color0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = v.vertex;//mul(unity_ObjectToWorld,v.vertex);
                o.normal = UnityObjectToWorldDir(v.normal);
                return o;
            }
            #define MIE_G -0.99
            #define MIE_G2 0.98
            // half getMiePhase(half eyeCos, half eyeCos2,float sunSize)
            // {
            //     half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
            //     temp = pow(temp, pow(sunSize,0.65) * 10);
            //     temp = max(temp,1.0e-4); // prevent division by zero, esp. in half precision
            //     temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;
            //     // #if defined(UNITY_COLORSPACE_GAMMA) && SKYBOX_COLOR_IN_TARGET_COLOR_SPACE
            //     //     temp = pow(temp, .454545);
            //     // #endif
            //     return temp;
            // }
float getMiePhase(float fCos, float fCos2, float g, float g2)
{
	return _SunSize * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos2) / pow(1.0 + g2 - 2.0 * g * fCos, 1.5);
}

// Calculates the Rayleigh phase function
float getRayleighPhase(float fCos2)
{
	return 0.75 + 0.75 * fCos2;
}
            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 pos = normalize(i.worldPos);

                float pv = saturate(dot(pos,lightDir));
                float eyeCos = pow(pv,_Power);

                float up = saturate(dot(float3(0,1,0),pos));
                float4 scatter = getMiePhase(-eyeCos,eyeCos*eyeCos,MIE_G,MIE_G2) * _Color1 + getRayleighPhase(pos.y * pos.y) * _Color0;
                return scatter * pos.y;
                // return sin((i.worldPos.x*i.worldPos.z * _Time.x*0.1)) * 100;
            }
            ENDCG
        }
    }
}
