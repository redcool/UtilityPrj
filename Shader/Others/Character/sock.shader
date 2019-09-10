// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/sock"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_Color2("Color2",color) = (1,1,1,1)
		_RimPower("RimPower",float) = 32
		_Alpha("Alpha",float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100
		//blend srcAlpha oneMinusSrcAlpha

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
				float4 vertex:POSITION;
                float2 uv : TEXCOORD0;
				float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
				float3 n:TEXCOORD2;
				float3 worldPos:TEXCOORD3;
				float4 screenPos:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _RimPower;
			float4 _Color2;
			float _Alpha;

            v2f vert (appdata v, out float4 vertex : SV_POSITION)
            {
                v2f o;
                vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.n = UnityObjectToWorldNormal(v.n);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

			

            fixed4 frag (v2f i, UNITY_VPOS_TYPE vPos : VPOS) : SV_Target
            {
				const float4x4 thresholdMatrix =
				{
				1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
				13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
				4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
				16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
				};
				clip(_Alpha - thresholdMatrix[vPos.x % 4][vPos.y % 4]);


				float3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 n = i.n;
				float vn = dot(v, n);
				float f = pow(1-vn,_RimPower);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

				
                return lerp(col,_Color2,f);
            }
            ENDCG
        }
    }
}
