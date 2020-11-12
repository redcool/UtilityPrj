Shader "Unlit/Mandelbrot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Len("_Len",float) = 0
        _Area("Area",vector) = (0,0,4,4)
        _Angle("_Angle",float) = 0
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
            float4 _Area;
            float _Angle;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2 Rot(float2 p,float2 pivot,float a){
                float c = cos(a);
                float s = sin(a);

                p -= pivot;
                p = float2(p.x*c-p.y*s,p.x*s+p.y*c);
                p+= pivot;
                return p;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 startPos = Rot(_Area.xy,float2(0,0),_Angle);
                float2 c = startPos + (i.uv-0.5)*_Area.zw;
                c = Rot(c,startPos,_Angle);
                float2 z;
                float iter;
                for(iter =0;iter<255;iter++){
                    z = c + float2(z.x*z.x-z.y*z.y,2*z.x*z.y);
                    if(length(z) > _Len)break;
                }
                return iter/255;
            }
            ENDCG
        }
    }
}
