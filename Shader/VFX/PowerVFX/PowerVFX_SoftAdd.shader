// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZX/FX/PowerVFX_SoftAdd"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Main Color",Color) = (1,1,1,1)

		// [Header(BlendMode)]
		// [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("Src Mode",int) = 5
		// [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("Dst Mode",int) = 1
		
        [Header(CullMode)]
	    [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 2

		[Header(Distortion)]
		[Toggle(DISTORTION_ON)]_DistortionOn("Distortion On?",int)=1
		[noscaleoffset]_NoiseTex("Noise Texture",2D) = "white" {}
		_DistortionIntensity("Distortion Intensity",Range(0,1)) = 0.5
		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)


        [Header(Dissolve)]
        [Toggle(DISSOLVE_ON)]_DissolveOn("Dissolve On?",int)=0
		_DissolveTex("Dissolve Tex",2d)=""{}
		[Toggle]_DissolveTexUseR("_DisolveTexUse (R,or A) ?",int)=0

        [Toggle]_DissolveByVertexColor("Dissolve By Vertex Color",int)=0 
	    _Cutoff ("AlphaTest cutoff", Range(0,1)) = 0.5

        [Header(DissolveEdge)]
        [Toggle(DISSOLVE_EDGE_ON)]_DissolveEdgeOn("Dissolve Edge On?",int)=0
        [HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)
        _EdgeWidth("EdgeWidth",range(0,0.3)) = 0.1

		[Header(Offset)]
		[Toggle(OFFSET_ON)] _OffsetOn("Offset On?",int) = 0
		[Toggle]_OffsetBlend2Layers("Offset blend 2 Layers",int) = 0
		_OffsetTex("Offset Tex",2d) = ""{}
		_OffsetTile("Offset Tile",vector) = (1,1,1,1)
		_OffsetDir("Offset Dir",vector) = (1,1,0,0)
		_BlendIntensity("Blend Intensity",range(0,10)) = 4
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

			Pass
			{
				//Tags{ "LightMode" = "ForwardBase" }
				Cull Off Lighting Off ZWrite Off
				//Blend [_SrcMode][_DstMode]
			Blend SrcAlpha One
			Cull[_CullMode]
			CGPROGRAM
			
			#pragma shader_feature DISTORTION_ON
			#pragma shader_feature DISSOLVE_ON
			#pragma shader_feature DISSOLVE_EDGE_ON
			#pragma shader_feature DISSOVLE_VERTEX_COLOR
			#pragma shader_feature OFFSET_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "PowerVFX.cginc"

			ENDCG
		}
		}
}