Shader "Unlit/DitherTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DitherTex("_DitherTex",2d) ="white"{}
        _Color1("_Color1",color) = (0,0,0,0)
        _Color2("_Color2",color) = (1,1,1,1)
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
            
            sampler2D _DitherTex;
            float4 _DitherTex_TexelSize;

            float4 _Color2,_Color1;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);

                half2 suv = i.vertex.xy * _DitherTex_TexelSize.xy;
                half4 ditherTex = tex2D(_DitherTex,suv);

                half dither = step(ditherTex.x,col.x);

                half4 c = lerp(_Color1,_Color2,dither);
                return c;
            }
            ENDCG
        }
    }
}
