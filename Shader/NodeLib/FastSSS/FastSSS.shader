Shader "Custom/FastSSS"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Distortion("distortion",range(0,1)) = 0.1
		_Power("Power",range(0,1)) = 1
		_Scale("scale",float) = 1
        _ThickMap("ThickMap",2d) = ""{}
        _Ambient("ambient",float) = 1
        _Atten("atten",float) = 1
	}
		SubShader
		{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#include "UnityPBSLighting.cginc"
        #include "../Include/FastSSS.cginc"
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf StandardTranslucent fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		float _Distortion,_Power,_Scale;

        sampler2D _MainTex;
        fixed4 _Color;

        sampler2D _ThickMap;
        float thickness;
        float _Ambient,_Atten;

		inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi) {
			fixed4 pbr = LightingStandard(s, viewDir, gi);
			
            FastSSSData data = {gi.light.dir,viewDir,s.Normal,_Distortion,_Power * 64,_Scale,_Ambient,_Atten,thickness};
			float I = FastSSS(data);

            //return I;
			pbr.rgb += _Color.rgb * I;
			return pbr;
		}

		void LightingStandardTranslucent_GI(SurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi) {
			LightingStandard_GI(s,data,gi);
		}

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // Albedo comes from a texture tinted by color
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            thickness = tex2D(_ThickMap,IN.uv_MainTex).r;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
