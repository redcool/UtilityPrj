
Shader "Unlit/Snow Cutoff"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NormalMap("Normal map",2d) = ""{}

		_Cutoff("Cutoff",float) = 0.5

		_SnowDirection("Direction",vector) = (1,0,0,0)
		_SnowColor("Snow Color",color) = (1,1,1,1)
		_SnowColorPower("SnowColorPower",range(0,4)) = 1
		_SnowTile("tile",vector) = (1,1,1,1)
	}

			SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue"="Transparent"}
			LOD 100
			blend srcAlpha oneMinusSrcAlpha
			Cull off

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
			#define SNOW
			#include "../NatureLib.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 n:NORMAL;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 n:NORMAL;
					SNOW_V2F(1);
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D _NormalMap;
				float _Cutoff;

				v2f vert(appdata v)
				{
					float3 worldNormal;
					float3 pos;
					SnowDir(v.vertex,v.n,pos,worldNormal);
					v.vertex.xyz = pos;

					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.n = worldNormal;
					//o.normalUV = o.uv.xyxy * _SnowTile;
					SNOW_VERTEX(o)
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);
				
					return SnowColor(_NormalMap,i.normalUV,col,i.n);
				}
				ENDCG
			}
		}
}
