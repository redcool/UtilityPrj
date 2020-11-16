Shader "Unlit/FractalTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Len("Len",float) = 0
        _Angle("_Angle",float) = 0.1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Len;
            float _Angle;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv-0.5;
                // uv *= 4;
return length(uv - float2(uv.x,-0.5));
                float a =  length(uv - float2(uv.x,0));
                return smoothstep(0.05,0,a);

                float3 col = (float3)0;

                float angle = _Angle * 3.14;
                float2 n = float2(sin(angle),cos(angle));
                // float d = dot(uv,n);
                // d = smoothstep(0.0,.02,abs(d));


                uv = abs(uv);
                uv.x -= .5;
                uv -= n * min(0,dot(uv,n)) * 2;

                float d = length(uv - float2(clamp(uv.x,-1,1),0));
                d = smoothstep(0.05,0.0,d);
                col += d;
                col.xy += uv;
                return float4(col,1);
            }
            ENDCG
        }
    }
}
