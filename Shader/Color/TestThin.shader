Shader "Unlit/TestThin"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Scale("_Scale",float) = 1
        _Offset("_Offset",float) = 0
        _Saturate("_Saturate",float) = 1
        _Brightness("_Brightness",float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)]_Src("_Src",float) = 4
        [Enum(UnityEngine.Rendering.BlendMode)]_Dst("_Dst",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            blend [_Src][_Dst]
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
                float3 normal:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Offset,_Scale;
            float _Saturate,_Brightness;

// Hue, Saturation, Value
// Ranges:
//  Hue [0.0, 1.0]
//  Sat [0.0, 1.0]
//  Lum [0.0, HALF_MAX]
half3 RgbToHsv(half3 c)
{
    const half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
    half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));
    half d = q.x - min(q.w, q.y);
    const half e = 1.0e-4;
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

half3 HsvToRgb(half3 c)
{
    const half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

            half3 HUEToRGB(half h){
                h = frac(h);
                half r = abs(h * 6 -3) - 1;
                half g = 2 - abs(h * 6 - 2);
                half b = 2 - abs(h * 6 -4);
                return saturate(half3(r,g,b));
            }

            half3 HSVToRGB(half3 hsv){
                half3 rgb = HUEToRGB(hsv.x);
                return ((rgb-1) * hsv.y + 1) * hsv.z;
            }


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 worldPos = i.worldPos;
                float3 l = _WorldSpaceLightPos0;
                float3 n = i.normal;
                float3 v = normalize(_WorldSpaceCameraPos - worldPos);
                
                float nv = saturate(dot(n,v));
                float inv = 1 - nv;

                float h = inv * _Scale + _Offset;
                float s = _Saturate;
                float b = _Brightness;

                float3 hsv = HSVToRGB(half3(h,s,b));
                // hsv = pow(hsv,2.2);

                return float4(hsv,1);
            }
            ENDCG
        }
    }
}
