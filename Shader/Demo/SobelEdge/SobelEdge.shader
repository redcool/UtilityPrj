Shader "Unlit/SobelEdge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
        #include "UnityCG.cginc"

            const static half2 UVOffsets[9]={
                half2(-1,1),half2(0,1),half2(1,1),
                half2(-1,0),half2(0,0),half2(1,0),
                half2(-1,-1),half2(0,-1),half2(1,-1)
            };
            const static half sobels[9]={
                -1,0,1,
                -2,0,2,
                -1,0,1
            };

            half SampleEdge(sampler2D tex,half2 uv,half2 texelSize){
                half c[9];
                for(int i=0;i<9;i++){
                    half d = dot(half3(0.2,0.7,0.02),tex2D(tex,uv + UVOffsets[i] * texelSize.xy));
                    c[i] = d;
                }
                
                /**
                float GX : -1 * mc00 + mc20 + -2 * mc01 + 2 * mc21 - mc02 + mc22;
			    float GY : mc00 + 2 * mc10 + mc20 - mc02 - 2 * mc12 - mc22;
                */
                half gx = -c[0] + c[6] - 2 * c[1] + 2 * c[7] - c[2] + c[8];
                half gy = c[0] + 2*c[3]+c[6]-c[2]-2*c[5]-c[8];
                half g = abs(gx)+abs(gy);
                return g;
            }
    ENDCG
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
            float4 _MainTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return SampleEdge(_MainTex,i.uv,_MainTex_TexelSize);
            }
            ENDCG
        }
    }
}
