Shader "Unlit/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Width("Width",range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
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
			float4 _MainTex_TexelSize;
            float _Width;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

				static int weights[9] = {-1,-1,-1,-1,8,-1,-1,-1,-1};
				static int2 coords[9] = {int2(-1,-1),int2(0,-1),int2(1,-1),int2(-1,0),int2(0,0),int2(1,0),int2(-1,1),int2(0,1),int2(1,1)};

            fixed4 frag (v2f i) : SV_Target
            {
				float4 c = (float4)0;
				for (int x = 0; x < 9; x++)
				{
					c += tex2D(_MainTex,i.uv + coords[x] * _MainTex_TexelSize.xy) * weights[x];
				}
                //c/=9;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return length(smoothstep(c,c-0.01,_Width)) * col;
            }
            ENDCG
        }
    }
}
