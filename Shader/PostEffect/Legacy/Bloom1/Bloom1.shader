Shader "Unlit/Bloom1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

CGINCLUDE
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

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _MainTex_TexelSize;

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	float4 SampleBox(float2 uv,float delta) {
		float2 p = _MainTex_TexelSize.xy * delta;
		float c = tex2D(_MainTex, uv + float2(-p.x, -p.y)) +
			tex2D(_MainTex, uv + float2(-p.x, p.y)) +
			tex2D(_MainTex, uv + float2(p.x, -p.y)) +
			tex2D(_MainTex, uv + float2(p.x, p.y));
		c *= 0.25;
		return c;
	}
ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
	//0
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			float _Threshold;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed g = dot(float3(0.2,0.7,0.07),col.rgb);
				g = saturate(g - _Threshold);
                return col * g;
            }
            ENDCG
        }
	//1
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			float _BlurSize;

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col = SampleBox(i.uv,_BlurSize);
				
				return col;
			}
			ENDCG
		}
	//3
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			sampler2D _BloomTex;

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb += tex2D(_BloomTex,i.uv).rgb;
				return col;
			}
			ENDCG
		}

    }
}
