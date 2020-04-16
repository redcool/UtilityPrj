﻿Shader "ZX/FX/PowerVFX_SoftAdd"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		[Toggle]_MainTexOffsetStop("禁用MainTex自动滚动?",int)=0
		[HDR]_Color("Main Color",Color) = (1,1,1,1)
		_ColorScale("ColorScale",range(1,3)) = 1
		[Header(MainTexMask)]
		_MainTexMask("Main Texture Mask(R)", 2D) = "white" {}
		[Toggle]_MainTexMask_R_A("_MainTexMask_R_A",int) = 0		
		// [Header(BlendMode)]
		// [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("Src Mode",int) = 5
		// [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("Dst Mode",int) = 1

		[Header(DoubleEffect)]
		[Toggle(DOUBLE_EFFECT)]_DoubleEffectOn("双重效果?",int)=0

		[Header(CullMode)]
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 2

		[Header(Distortion)]
		[Toggle(DISTORTION_ON)]_DistortionOn("Distortion On?",int)=0
		[noscaleoffset]_NoiseTex("Noise Texture",2D) = "white" {}
		[noscaleoffset]_DistortionMaskTex("Distortion Mask Tex(R)",2d) = "white"{}
		_DistortionIntensity("Distortion Intensity",Range(0,1)) = 0.5
		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)


		[Header(Dissolve)]
		[Toggle(DISSOLVE_ON)]_DissolveOn("Dissolve On?",int)=0
		_DissolveTex("Dissolve Tex",2d)=""{}
		[Toggle]_DissolveTexUseR("_DisolveTexUse R(uncheck use A)?",int)=0
		[Toggle]_DissolveByVertexColor("Dissolve By Vertex Color ?",int)=0
		[Toggle]_DissolveByCustomData("Dissolve By Custom Data ?",int)=0		
		_Cutoff ("AlphaTest cutoff", Range(0,1)) = 0.5

		[Header(DissolveEdge)]
		[Toggle(DISSOLVE_EDGE_ON)]_DissolveEdgeOn("Dissolve Edge On?",int)=0
		[HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)
		_EdgeWidth("EdgeWidth",range(0,0.3)) = 0.1

		[Header(Offset)]
		[Toggle(OFFSET_ON)] _OffsetOn("Offset On?",int) = 0
		[NoScaleOffset]_OffsetTex("Offset Tex",2d) = ""{}
		[NoScaleOffset]_OffsetMaskTex("Offset Mask (R)",2d) = "white"{}
		[HDR]_OffsetTexColorTint("OffsetTex Color",color) = (1,1,1,1)
		_OffsetTile("Offset Tile",vector) = (1,1,1,1)
		_OffsetDir("Offset Dir",vector) = (1,1,0,0)
		_BlendIntensity("Blend Intensity",range(0,10)) = 0.5

		[Header(Fresnal)]
		[Toggle(FRESNAL_ON)]_FresnalOn("Fresnal On?",int)=0
		_FresnalColor("Fresnal Color",color) = (1,1,1,1)
		_FresnalPower("Fresnal Power",range(0,1)) = 0.5
		[Toggle]_FresnalTransparentOn("Fresnal Transparent?",range(0,1)) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			Cull Off Lighting Off ZWrite Off
			//Blend [_SrcMode][_DstMode]
			Blend SrcAlpha One
			Cull[_CullMode]
			CGPROGRAM
			
			#pragma shader_feature _ DISTORTION_ON
			#pragma shader_feature _ DISSOLVE_ON
			#pragma shader_feature _ DISSOLVE_EDGE_ON
			#pragma shader_feature _ OFFSET_ON
			#pragma shader_feature _ FRESNAL_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "PowerVFX.cginc"

			ENDCG
		}
	}

	CustomEditor "PowerVFX.PowerVFXInspector"
}