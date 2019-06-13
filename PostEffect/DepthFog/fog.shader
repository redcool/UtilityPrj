// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_FogParams("FogParams",vector) = (0,10,1,1)
		_FogColor("FogColor",color) =(1,0,0,1)
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
				float4 scrPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _FogParams;
			float4 _FogColor;

			sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.scrPos = ComputeScreenPos(o.vertex);
				//o.scrPos.y = 1 - o.scrPos.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.scrPos.xy);
				//float d = LinearEyeDepth(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(i.scrPos)).r);
			float d = LinearEyeDepth(depth);
			//return float4(d, d, d, 1);
				float range = (_FogParams.y - _FogParams.x);
				float x = (d - _FogParams.x);
				float fog = clamp( (x/ range),0,1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return lerp(col,  _FogColor,fog);
            }
            ENDCG
        }
    }
}
