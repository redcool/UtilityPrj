Shader "Unlit/TestCircle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		a("a",range(0,1)) = 0
			b("b",range(0,1)) = 0
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
			float a, b;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{

				float t = _Time.y;
				float2 pos = float2(sin(t), cos(t)) * 0.1;

				float2 uv = i.uv - .5;
				float2 d = uv - pos;
				float l = length(d);
				float m = smoothstep(0.07, 0.0, l);
				d *= m * a;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv + d);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
