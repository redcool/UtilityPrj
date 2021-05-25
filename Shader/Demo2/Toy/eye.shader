Shader "Unlit/eye"
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			float Circle(float2 uv, float2 pos, float r,float size) {
				uv = uv - 0.5 - pos;
				uv.x *= 2;
				float l = length(uv);
				float m = smoothstep(r, r - size,l);
				return m;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;
				float m = Circle(uv,float2(0,0),0.2,0.01);
				m -= Circle(uv,float2(0.04,0.05),0.05,0.01);
				m -= Circle(uv, float2(-0.04, 0.05), 0.05, 0.01);
				//
				return m;
            }
            ENDCG
        }
    }
}
