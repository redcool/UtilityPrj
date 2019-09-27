﻿Shader "Unlit/ShowDepth"
{
    Properties
    {
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float depth : DEPTH;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float d = i.depth;
				return d;
            }
            ENDCG
        }
    }
}
