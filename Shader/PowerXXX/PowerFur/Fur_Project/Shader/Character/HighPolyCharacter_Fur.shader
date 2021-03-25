Shader "sg3/Character/HighPolyCharacter_Fur"
{
	Properties
	{
        [Header(Texture __________________________________________________________________________________)]
        _MainTex("Albedo", 2D) = "white" {}
		_SubTex("Fur Noise", 2D) = "white" {}

        [Header(Light ____________________________________________________________________________________)]
        _Color("Main Light Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _Transmission("Transmission", Range(-0.5, 0.5)) = 0.0
        _Shininess("Glossness", Range(0.01, 1.0)) = 0.1
        _SpecularColor("Specluar Color", Color) = (0.5, 0.5 ,0.5 ,1.0)
		_FresnelIntensity("Fresnel Intensity", Range(0.0, 2.0)) = 0.0
		_FresnelPower("Fresnel Power", Range(0.0, 2.0)) = 2.0

		[Header(Fur ______________________________________________________________________________________)]
		_AoColor("AO Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Spacing ("Fur Spacing", Float) = 0.5
		_UVoffset ("UV offset (xy=offset, zw=turbulence)", Vector) = (0.0, 0.0, 0.0, 0.0)
		_tming("Fur Transparency", Range(0.0, 2.0)) = 0.5
		_dming("Tip Opacity", Range(0.0, 1.0)) = 1.0

		[Header(Force ____________________________________________________________________________________)]
		_Wind("Wind (xy=offset, z=frequency, w=strengh）", Vector) = (50.0, 50.0, 5.0, 0.0)
		_Gravity("Global (xyz=offset, w=vertexAlphaStrengh)", Vector) = (0.0, 0.0, 0.0, 0.0)
	}

	SubShader
	{   
        Tags { "RenderType"="Opaque" }
	
		Pass    // fur base
		{
			// Tags { "LightMode" = "ForwardBase" }  

			CGPROGRAM
			#pragma target 3.0

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

			// #define these varys do the same as below
			float UV, FORCE, FRESNEL, SPACING, DMING;

			#pragma vertex vertFurBase
			#pragma fragment fragFurBase

			#include "Sg3Fur.cginc"
			ENDCG
		}
/*	
		Pass	// shadow
		{
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            //#pragma target 2.0

            //#pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            //#pragma shader_feature_local _METALLICGLOSSMAP
            //#pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma skip_variants SHADOWS_SOFT
            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
*/
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass    // 1 : fur 1
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.1
			#define FORCE 0.01
			// #define TURBULENCE 0.01
			#define FRESNEL 0.01
			#define SPACING 0.005
			#define DMING 0.5

			#pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 2 : fur 2
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.2
			#define FORCE 0.04
			// #define TURBULENCE 0.02
			#define FRESNEL 0.04
			#define SPACING 0.02
			#define DMING 1.0

			#pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 3 : fur 3
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.3
			#define FORCE 0.09
			// #define TURBULENCE 0.03
			#define FRESNEL 0.1
			#define SPACING 0.045
			#define DMING 1.5

		    #pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 4 : fur 4
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.4
			#define FORCE 0.16
			// #define TURBULENCE 0.04
			#define FRESNEL 0.19
			#define SPACING 0.08
			#define DMING 2.0

			#pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 5 : fur 5
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.5
			#define FORCE 0.25
			// #define TURBULENCE 0.05
			#define FRESNEL 0.31
			#define SPACING 0.125
			#define DMING 2.5

            #pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 6 : fur 6
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.6
			#define FORCE 0.36
			// #define TURBULENCE 0.06
			#define FRESNEL 0.49
			#define SPACING 0.18
			#define DMING 3.0

            #pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 7 : fur 7
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.7
			#define FORCE 0.49
			// #define TURBULENCE 0.07
			#define FRESNEL 0.73
			#define SPACING 0.245
			#define DMING 3.5

            #pragma multi_compile_fog		
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 8 : fur 8
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.8
			#define FORCE 0.64
			// #define TURBULENCE 0.08
			#define FRESNEL 1.05
			#define SPACING 0.32
			#define DMING 4.0

            #pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 9 : fur 9
		{
			ZWrite Off

			CGPROGRAM

			#define UV 0.9
			#define FORCE 0.81
			// #define TURBULENCE 0.09
			#define FRESNEL 1.47
			#define SPACING 0.405
			#define DMING 4.5

            #pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}

		Pass    // 10 : fur 10
		{
			ZWrite Off

			CGPROGRAM

			#define UV 1.0
			#define FORCE 1.0
			// #define TURBULENCE 0.1
			#define FRESNEL 1.0
			#define SPACING 0.5
			#define DMING 5.0

			#pragma multi_compile_fog
			#pragma vertex vertFur
			#pragma fragment fragFur
			
			#include "Sg3Fur.cginc"
			ENDCG
		}
	}
}
