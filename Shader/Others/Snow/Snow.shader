// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Snow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NormalMap("Normal map",2d) = ""{}
		_SnowDirection("Direction",vector) = (1,0,0,0)
		_SnowColor("Snow Color",color) = (1,1,1,1)
		_SnowColorPower("_SnowColorPower",float) = 1
		_Tile("tile",vector) = (1,1,1,1)
	}

			SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog

				#include "UnityCG.cginc"
			#include "../Weather.cginc"
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
					float3 n:NORMAL;
					float4 normalUV:TEXCOORD2;
				};

				sampler2D _MainTex;
				sampler2D _NormalMap;

				float4 _MainTex_ST;
				float4 _SnowDirection;
				float4 _SnowColor;
				float _SnowColorPower;
				float4 _Tile;

				float4 _GlobalSnowDirection;
				float _GlobalSnowColorPower;


				v2f vert(appdata v)
				{
					float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
					float3 worldNormal = mul(transpose(unity_WorldToObject), v.n);

					worldPos.xyz += SnowDir(worldPos.xyz, worldNormal, _SnowDirection.xyz + _GlobalSnowDirection.xyz, _SnowDirection.w + _GlobalSnowDirection.w);
					v.vertex = mul(unity_WorldToObject, worldPos);

					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					o.n = worldNormal;
					o.normalUV = o.uv.xyxy * _Tile;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float3 n = UnpackNormal(tex2D(_NormalMap,i.normalUV.xy));
					n += UnpackNormal(tex2D(_NormalMap, i.normalUV.zw));
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv);
					// apply fog
					UNITY_APPLY_FOG(i.fogCoord, col);
					return SnowColor(col ,_SnowColor,i.n + n,_SnowDirection.xyz + _GlobalSnowDirection.xyz, _SnowColorPower + _GlobalSnowColorPower);
				}
				ENDCG
			}
		}
}
