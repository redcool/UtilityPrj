Shader "Unlit/GaussTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OffsetScale("_OffsetScale",float) = 1
        [Toggle]_GaussOn("_GaussOn",float) = 0
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
            float4 _MainTex_TexelSize;
            float _GaussOn;
            float _OffsetScale;

            const static float gaussWeights[4]={0.00038771,0.01330373,0.11098164,0.22508352};

            float3 GaussBlur(sampler2D tex,float2 uv,float2 offset){
                float3 c = 0;
                    c += tex2D(tex,uv) * gaussWeights[3];
                    c += tex2D(tex,uv + offset) * gaussWeights[2];
                    c += tex2D(tex,uv - offset) * gaussWeights[2];

                    c += tex2D(tex,uv + offset * 2) * gaussWeights[1];
                    c += tex2D(tex,uv - offset * 2) * gaussWeights[1];

                    c += tex2D(tex,uv + offset * 3) * gaussWeights[0];
                    c += tex2D(tex,uv - offset * 3) * gaussWeights[0];
                return c;
            }

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
                if(!_GaussOn)
                    return tex2D(_MainTex,i.uv);

                float3 c = GaussBlur(_MainTex,i.uv,float2(1,0) * _MainTex_TexelSize.xy * _OffsetScale);
                c += GaussBlur(_MainTex,i.uv,float2(0,1) * _MainTex_TexelSize.xy * _OffsetScale);
                return float4(c,1);
            }
            ENDCG
        }
    }
}
