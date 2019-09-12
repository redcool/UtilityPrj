
Shader "Unlit/Snow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NormalMap("Normal map",2d) = ""{}

	[Header(Snow)]
	[noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
	_NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

	_SnowDirection("Direction",vector) = (1,0,0,0)
	_SnowColor("Snow Color",color) = (1,1,1,1)
	_SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
	_SnowTile("tile",vector) = (1,1,1,1)
	_BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
	//_Distance("Distance",vector) = (10,10,1,1)
	}

			SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100
			
			Pass
			{
				CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members worldPos)
#pragma exclude_renderers d3d11
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
					float3 worldPos;
					SNOW_V2F(1);
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D _NormalMap;

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
					o.worldPos = worldPos;
					SNOW_VERTEX(o)
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{ 
					// sample the texture
					fixed4 c = tex2D(_MainTex, i.uv);
					fixed4 snowColor = SnowColor(i.uv,c, i.n,i.worldPos,0);
					return snowColor;
				}
				ENDCG
			}
		}
}
