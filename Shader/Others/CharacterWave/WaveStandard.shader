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

				half _Glossiness;
				half _Metallic;
				fixed4 _Color;



				// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
				// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
				// #pragma instancing_options assumeuniformscaling
				UNITY_INSTANCING_BUFFER_START(Props)
					// put more per-instance properties here
				UNITY_INSTANCING_BUFFER_END(Props)


				void surf(Input IN, inout SurfaceOutputStandard o)
				{
					fixed3 finalWaveCol = BlendWave(IN.worldNormal,IN.worldPos,IN.uv_MainTex);
					// Albedo comes from a texture tinted by color
					fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
					o.Albedo = c.rgb + finalWaveCol;
					// Metallic and smoothness come from slider variables
					o.Metallic = _Metallic;
					o.Smoothness = _Glossiness;
					o.Alpha = c.a;
				}
				ENDCG
			}
				FallBack "Diffuse"
}
