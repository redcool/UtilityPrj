Shader "Custom/Wave/WaveStandard"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
//wave1
			_WaveColor("WaveColor",color) = (0,0.8,0,0)
			_WaveColorSaturation("WaveColorSaturation",float) = 1
			_WaveTex("_WaveTex",2d) = ""{}
			_WaveSpeed("WaveSpeed",float) = 2
			_Bright("Bright",float) = 1
			_BrightThreshold("BrightThreshold",range(0,1))= 0.1
			_RimPower("RimPower",float) = 2
//wave2
			_WaveColor2("WaveColor2",color) = (0,0.8,0,0)
			_WaveTex2("_WaveTex2",2d) = ""{}
			_WaveSpeed2("WaveSpeed2",float) = 2
	}
		SubShader
			{
				Tags { "RenderType" = "Opaque" }
				LOD 200
				//blend one one

				CGPROGRAM
				#include "WaveInclude.cginc"
				// Physically based Standard lighting model, and enable shadows on all light types
				#pragma surface surf Standard fullforwardshadows

				// Use shader model 3.0 target, to get nicer looking lighting
				#pragma target 3.0
				sampler2D _MainTex;

				struct Input
				{
					float2 uv_MainTex;
					float3 worldPos;
					float3 worldNormal;
				};

				UNITY_INSTANCING_BUFFER_START(Props1)
    				UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
					UNITY_DEFINE_INSTANCED_PROP(float, _Glossiness)
					UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				UNITY_INSTANCING_BUFFER_END(Props1)


				void surf(Input IN, inout SurfaceOutputStandard o)
				{
					float metallic = UNITY_ACCESS_INSTANCED_PROP(Props1, _Metallic);
					float glossiness = UNITY_ACCESS_INSTANCED_PROP(Props1,_Glossiness);
					float4 color = UNITY_ACCESS_INSTANCED_PROP(Props1, _Color);

					fixed3 finalWaveCol = BlendWave(IN.worldNormal,IN.worldPos,IN.uv_MainTex);
					// Albedo comes from a texture tinted by color
					fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * color;
					o.Albedo = c.rgb + finalWaveCol;
					// Metallic and smoothness come from slider variables
					o.Metallic = metallic;
					o.Smoothness = glossiness;
					o.Alpha = c.a;
				}
				ENDCG
			}
				FallBack "Diffuse"
}
