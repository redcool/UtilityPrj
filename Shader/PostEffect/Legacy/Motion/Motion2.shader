Shader "Hidden/Motion2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	sampler2D _CameraDepthTexture;
	float _Blur;
	float4x4 _VPInvert;
	float4x4 _LastVP;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float2 uvDepth:TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o =(v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.uvDepth = v.uv;
                return o;
            }



            fixed4 frag (v2f i) : SV_Target
            {
				float depth = tex2D(_CameraDepthTexture,i.uv);

				float4 ndc = float4(float3(i.uv.x, i.uv.y, depth) * 2 - 1, 1);
				float4 worldPos = mul(_VPInvert, ndc);
				worldPos /= worldPos.w;

				float4 lastNdc = mul(_LastVP, worldPos);
				lastNdc /= lastNdc.w;

				float2 speed = (ndc.xy - lastNdc.xy)*0.5;
				float4 c = float4(0,0,0,1);
				for (int x = 0; x < 4; x++)
				{
					float2 uv = i.uv + x * speed * _Blur;
					c.rgb += tex2D(_MainTex, uv).rgb;
				}
				c.rgb *= 0.25;
                return c;
            }
            ENDCG
        }
    }
}
