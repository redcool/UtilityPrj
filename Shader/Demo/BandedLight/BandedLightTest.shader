Shader "Unlit/BandedLightTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bright("bright",float) = 1
        _Base("base",float) = 1
        _Step("step",int) = 1

        [Toggle(_Mode)]_Mode("BandedLight Mode 2?",int) = 0
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
            #include "BandedLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 n:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Bright,_Base;
            int _Step;
            int _Mode;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.n = UnityObjectToWorldNormal(v.n);
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float bandedLight = SmoothBandedLight(i.n,_WorldSpaceLightPos0.xyz,_Base,_Bright);
                float bandedLight2 = StepBandedLight(i.n,_WorldSpaceLightPos0.xyz,_Base,_Step);
                float l = lerp(bandedLight,bandedLight2,_Mode);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= l;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
