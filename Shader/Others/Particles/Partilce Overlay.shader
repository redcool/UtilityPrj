Shader "Unlit/Overlay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _OcclusionAlpha("OcclusionAlpha",range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        ztest off
        //zwrite off
        blend srcAlpha oneMinusSrcAlpha

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
                float4 pos : SV_POSITION;
                float4 screen:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float _OcclusionAlpha;

			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.screen = ComputeScreenPos(o.pos);
				COMPUTE_EYEDEPTH(o.screen.z);

                return o;
            }

            float SampleDepthTexture(float4 screenPos){
                float d = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(screenPos));
                d = LinearEyeDepth(d);
                return d;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float d = SampleDepthTexture(i.screen);

                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                 
                fixed zRate = saturate(d - i.screen.z);
                col.a = lerp(_OcclusionAlpha,col.a,zRate);
                return col;
            }
            ENDCG
        }
    }
}
