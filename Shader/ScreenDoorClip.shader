﻿Shader "Unlit/ScreenDoorClip"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Alpha("Alpha",float) = 0.3
		_Threshold("Threshold",float) = 0.5
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Alpha;
			float _Threshold;

            v2f vert (appdata v,out float4 vertex : SV_POSITION)
            {
                v2f o;
                vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE vPos:VPOS) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
			const float4x4 thresholdMatrix =
			{
			1.0 / 17.0,   9.0 / 17.0,   3.0 / 17.0,11.0 / 17.0,
			 13.0 / 17.0,   5.0 / 17.0,15.0 / 17.0,   7.0 / 17.0,
			 4.0 / 17.0,12.0 / 17.0,   2.0 / 17.0,10.0 / 17.0,
			 16.0 / 17.0,   8.0 / 17.0,14.0 / 17.0,   6.0 / 17.0
			};
				
				clip(_Alpha - thresholdMatrix[vPos.x % 4][vPos.y % 4]);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
