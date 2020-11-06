Shader "Unlit/ValueNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float N21(float2 p){
                return frac(sin(p.x*100+p.y*7890)*10000);
            }

            float SmoothNoise(float2 p){
                float2 lv = frac(p * 10);
                float2 id = floor(p * 10);

                float bl = N21(id);
                float br = N21(id+float2(1,0));
                float b = lerp(bl,br,lv.x);

                float tl = N21(id+float2(0,1));
                float tr = N21(id+float2(1,1));
                float t = lerp(tl,tr,lv.x);
                
                float n = lerp(b,t,lv.y);
                return n;
            }

            float SmoothNoise2(float2 p){
                float c = SmoothNoise(p*4);
                c += SmoothNoise(p * 8) * .5;
                c += SmoothNoise(p * 16) * .25;
                c += SmoothNoise(p * 32) * .125;
                c += SmoothNoise(p * 65) * .0625;
                return c/2;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float c = SmoothNoise2(i.uv + _Time.x*0.1);
                return c;
            }
            ENDCG
        }
    }
}
