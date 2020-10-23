Shader "Unlit/ScanLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)

        _Value("value",range(0,1)) = 0
        _Width("width",range(0.01,1)) = 0.02
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex:SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Value;
            float _Width;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float ScannLine(float width,float u,float t){
                float halfWidth = width * 0.5;
                return saturate(abs(u - t)/halfWidth);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float uv = ScannLine(_Width,i.uv.x,_Value);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= (uv);
                return col;
            }
            ENDCG
        }
    }
}
