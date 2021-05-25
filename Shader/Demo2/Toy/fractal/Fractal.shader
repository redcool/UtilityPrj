Shader "Hidden/Fractal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	_Area("area",vector) = (0,0,4,4)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _Area;

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = _Area.xy + (0.5-i.uv) * _Area.zw;
				uv.x *= 2;

				float2 z;
				float iter;
				for (iter = 0; iter < 255; iter++) {
					z = uv + float2(z.x*z.x-z.y*z.y,2*z.x*z.y);
					if (length(z) > 2) break;
				}

                return iter/255;
            }
            ENDCG
        }
    }
}
