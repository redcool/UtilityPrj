Shader "Unlit/RotateCircle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Progress("_Progress",float) = 0.5
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

            float _Progress;

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
                float c = cos(_Time.x*180/3.14);
                float s = sin(_Time.x*180/3.14);

                float2 uv = float2(dot(float2(c,-s),i.uv - .5),dot(float2(s,c),i.uv - .5) );
               
                uv += _Progress;
                float l = length(uv);
                return smoothstep(0.1,0.01,l);
            }
            ENDCG
        }
    }
}
