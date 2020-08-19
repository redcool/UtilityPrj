Shader "Custom/SkinShader"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Int) = 2

		_MainTex ("Albedo", 2D) = "white" {}
		_BumpTex ("Normal Map", 2D) = "bump" {}
		_DetailBumpTex ("Detail Normal Map", 2D) = "grey" {}
		_MixMap ("Mix Map", 2D) = "black" {}
		_Roughness ("Roughness", Range(0,2)) = 1.0
		_LUT ("Skin LUT", 2D) = "grey" {}

		[Header(VirtualLit)]
		[Toggle(VIRTUAL_LIT)] _VirtualLit_On ("Virtual Lit", Int) = 1.0

		[Header(DualSpecular)]
		[Toggle(DUAL_SPECULAR)] _DualSpecular_On("Dual Specular", Int) = 1.0
		_RoughnessOffset ("Roughness Offset", Range(0,1)) = 0.7
		_SpecularIntensity ("Specular Intensity", Range(0,3)) = 1

		[Header(SSS)]
		_SSSIntensity ("SSS Intensity (LUT)", Range(0,2)) = 1.0
		_SSSColor ("SSS Color", Color) = (0.0,0.0,0.0,1.0)
		[Header(SSSFront)]
		_SSSFront ("SSS Front Intensity", Range(0,2)) = 1
		[Header(SSSBack)]
		_SSSBack ("SSS Back Intensity", Range(0,3)) = 1
		_SSSPower ("SSS Power", Range(0.1,5)) = 3
		_SSSBackRange ("SSS Back Range", Range(0,1)) = 0.3

		[Header(Pore)]
		_PoreIntensity ("Pore Intensity", Range(0,1)) = 0.5
		_DetailUVScale ("Pore uv Scale", Float) = 20.0

		[Header(Crystal)]
		_CrystalRange ("Crystal Range", Range(0,1)) = 0.3
		_CrystalMask("Crystal Mask", 2D) = "white" {}
		_CrystalMap01 ("Crystal Map 01", 2D) = "white" {}
		_CrystalMap02 ("Crystal Map 02", 2D) = "white" {}
		_CrystalMap03 ("Crystal Map 03", 2D) = "white" {}
		_CrystalUVTile01 ("Crystal UV Tile 01", Float) = 1
		_CrystalUVTile02 ("Crystal UV Tile 02", Float) = 1
		_CrystalUVTile03 ("Crystal UV Tile 03", Float) = 1
		_CrystalColor01 ("Crystal Color 01", Color) = (1,1,1,1)
		_CrystalColor02 ("Crystal Color 02", Color) = (1,1,1,1)
		_CrystalColor03 ("Crystal Color 03", Color) = (1,1,1,1)

		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}

		CGINCLUDE

		// Include CGs
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
		#include "UnityStandardConfig.cginc"
		#include "UnityStandardUtils.cginc"

		half _SSSIntensity;
		half4 _SSSColor;
		half _SSSPower;
		half _SSSBackRange;
		half _SSSFront;
		half _SSSBack;
		half4 _VirtualLitDir;
		half4 _VirtualLitColor;
		half _RoughnessOffset;
		half _SpecularIntensity;

		sampler2D _LUT;

		// Light Functions
		UnityLight MainLight()
		{
			UnityLight l;
			l.color = _LightColor0.rgb;
			l.dir = _WorldSpaceLightPos0.xyz;
			return l;
		}

		// GI Functions
		inline half4 VertexGIForward( half2 uv1, half2 uv2, float3 posWorld, half3 normalWorld )
		{
			half4 ambientOrLightmapUV = 0;
			#ifdef LIGHTMAP_ON
				ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				ambientOrLightmapUV.zw = 0;
			#elif UNITY_SHOULD_SAMPLE_SH
				#ifdef VERTEXLIGHT_ON
					ambientOrLightmapUV.rgb = Shade4PointLights (
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, posWorld, normalWorld);
				#endif
				ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
			#endif
			#ifdef DYNAMICLIGHTMAP_ON
				ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
			#endif
			return ambientOrLightmapUV;
		}

		inline UnityGIInput UnityGIInputSetup( UnityLight light, float3 posWorld, half3 viewDir, half atten, half4 i_ambientOrLightmapUV )
		{
			UnityGIInput data;
			data.light = light;
			data.worldPos = posWorld;
			data.worldViewDir = viewDir;
			data.atten = atten;
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
				data.ambient = 0;
				data.lightmapUV = i_ambientOrLightmapUV;
			#else
				data.ambient = i_ambientOrLightmapUV.rgb;
				data.lightmapUV = 0;
			#endif
			data.probeHDR[0] = unity_SpecCube0_HDR;
			data.probeHDR[1] = unity_SpecCube1_HDR;
			#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
			data.boxMin[0] = unity_SpecCube0_BoxMin;
			#endif
			#ifdef UNITY_SPECCUBE_BOX_PROJECTION
			data.boxMax[0] = unity_SpecCube0_BoxMax;
			data.probePosition[0] = unity_SpecCube0_ProbePosition;
			data.boxMax[1] = unity_SpecCube1_BoxMax;
			data.boxMin[1] = unity_SpecCube1_BoxMin;
			data.probePosition[1] = unity_SpecCube1_ProbePosition;
			#endif
			return data;
		}

		inline UnityGI FragmentGIForward( UnityGIInput d, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData g )
		{
			UnityGI gi = UnityGlobalIllumination (d, occlusion, normalWorld, g);
			return gi;
		}

		// BRDF Functions
		half D_GGX( half roughness, half nh )
		{
			half a = roughness;
			half a2 = a * a;
			half d = ( nh * a2 - nh ) * nh + 1;
			return a2 / ( d*d * UNITY_PI + 1e-4h );
		}
		
		half V_SmithJointApprox( half roughness, half nv, half nl )
		{
			half a = roughness;
			half Vis_SmithV = nl * ( nv * ( 1 - a ) + a );
			half Vis_SmithL = nv * ( nl * ( 1 - a ) + a );
			return 0.5 / ( Vis_SmithV + Vis_SmithL + 1e-4h );
		}

		half3 F_Schlick(half3 F0, half vh)
		{
			half Fc = Pow5(1 - vh);
			return saturate(50.0 * F0.g) * Fc + (1 - Fc) * F0;
		}

		half3 EnvBRDFApprox(half3 SpecularColor, half Roughness, half NoV)
		{
			const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
			const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
			half4 r = Roughness * c0 + c1;
			half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
			half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
			AB.y *= saturate(50.0 * SpecularColor.g);

			return SpecularColor * AB.x + AB.y;
		}

		inline float3 Safe_Normalize( float3 inVec )
		{
			float dp3 = max(0.001f, dot(inVec, inVec));
			return inVec * rsqrt(dp3);
		}

		// PBR Shading Function
		half4 BRDF_PBS( half3 diffColor, half3 specColor, half smoothness, half curvature, half sssIntensity, half3 normal, half3 viewDir, UnityLight light, half3 indirectDiffuse, half3 indirectSpecular)
		{
			// base PBR
			half perceptualRoughness = 1.0 - smoothness;
			perceptualRoughness = max(0.04, perceptualRoughness);
			half roughness = perceptualRoughness * perceptualRoughness;
			float3 halfDir = Safe_Normalize(light.dir + viewDir);
			half nl = dot(normal, light.dir);
			float nh = saturate(dot(normal, halfDir));
			half nv = saturate(dot(normal, viewDir));
			float lh = saturate(dot(light.dir, halfDir));
			
			// virtual light PBR
			#ifdef VIRTUAL_LIT
				half3 virtualDir = normalize(_VirtualLitDir);
				half vnl = dot(virtualDir, normal);
				float3 vHalfDir = Safe_Normalize(virtualDir + viewDir);
				float vnh = saturate(dot(normal, vHalfDir));
				float vlh = saturate(dot(virtualDir, vHalfDir));
			#endif

			// diffuse
			half3 sssnl = tex2D(_LUT, float2(nl*0.5+0.5, 1.0-sssIntensity*_SSSIntensity)).rgb;

			// virtual diffuse
			#ifdef VIRTUAL_LIT
				half3 virtualDiffuse = saturate(vnl + 0.2);
			#else
				half3 virtualDiffuse = 0.0;
			#endif

			// front sss
			#ifdef VIRTUAL_LIT
				half3 frontScatter = nh * saturate(nl + 0.5) * light.color + vnh * saturate(vnl + 0.5) * _VirtualLitColor.rgb;
			#else
				half3 frontScatter = nh * saturate(nl + 0.5) * light.color;
			#endif
			half3 frontSSS = lerp(1.0, frontScatter, 0.8) * (curvature * _SSSFront);

			// back sss
			half3 TransLightDir = light.dir + normal * 0.5;
			half TransDot = saturate(dot(-TransLightDir, viewDir));
			half WrapNoL = saturate(-nl * 0.5 + 0.5);
			half backSSSMask = saturate((curvature + _SSSBackRange - 1.0) / max(0.01, _SSSBackRange));
			half3 backSSS = pow(TransDot, _SSSPower) * WrapNoL * backSSSMask * _SSSBack * light.color;

			// specular
			#ifdef DUAL_SPECULAR
				half roughness2 = roughness * _RoughnessOffset * _RoughnessOffset;
				half D = D_GGX(roughness, nh) * 0.75 + D_GGX(roughness2, nh) * 0.25;
				D *= _SpecularIntensity;
			#else
				half D = D_GGX(roughness, nh);
			#endif
			half V = V_SmithJointApprox(roughness, nv, nl);
			half3 F = F_Schlick(specColor, lh);
			half3 specularTerm = D * V * F * UNITY_PI * saturate(nl);

			// virtual specular 
			#ifdef VIRTUAL_LIT
				#ifdef DUAL_SPECULAR
					half vD = D_GGX(roughness, vnh) * 0.75 + D_GGX(roughness2, vnh) * 0.25;
					vD *= _SpecularIntensity;
				#else
					half vD = D_GGX(roughness, vnh);
				#endif
				half vV = V_SmithJointApprox(roughness, nv, vnl);
				half3 vF = F_Schlick(specColor, vlh);
				float virtualSpecularTerm = vD * vV * vF * UNITY_PI * saturate(vnl);
			#else
				half3 virtualSpecularTerm = 0.0;
			#endif

			// env 
			half3 envBrdf = EnvBRDFApprox(specColor, perceptualRoughness, nv);
			half groudFactor = lerp(0.2, 1.0, saturate(normal.y + 0.5));

			// accumulation
			half3 color = (sssnl * light.color + indirectDiffuse) * diffColor
				+ (frontSSS + backSSS) * _SSSColor
				+ specularTerm * light.color
				+ (virtualDiffuse * diffColor + virtualSpecularTerm) * _VirtualLitColor.rgb
				+ envBrdf * indirectSpecular * groudFactor
				;
			return half4(color, 1);
		}
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		LOD 200

		Cull [_Cull]

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
			
			#pragma shader_feature VIRTUAL_LIT
			#pragma shader_feature DUAL_SPECULAR

			struct VertexInput 
			{
				float4 vertex		: POSITION;
				float3 normal		: NORMAL;
				float4 tangent		: TANGENT;
				half2 texcoord0		: TEXCOORD0;
				half2 texcoord1		: TEXCOORD1;
				half2 texcoord2		: TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 pos			: SV_POSITION;
				float2 uv0			: TEXCOORD0;
				float4 posWorld		: TEXCOORD1;
				float3 normalDir	: TEXCOORD2;
				float3 tangentDir	: TEXCOORD3;
				float3 bitangentDir : TEXCOORD4;
				half4 ambientOrLightmapUV : TEXCOORD5;
				UNITY_FOG_COORDS(6)
				UNITY_SHADOW_COORDS(7)
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _PoreIntensity;
			half _DetailUVScale;
			sampler2D _MixMap;
			sampler2D _BumpTex;
			sampler2D _DetailBumpTex;
			half _Roughness;

			sampler2D _CrystalMask;
			sampler2D _CrystalMap01;
			sampler2D _CrystalMap02;
			sampler2D _CrystalMap03;
			half _CrystalRange;
			half _CrystalUVTile01;
			half _CrystalUVTile02;
			half _CrystalUVTile03;
			half4 _CrystalColor01;
			half4 _CrystalColor02;
			half4 _CrystalColor03;
			
			VertexOutput vert (VertexInput v) 
			{
				UNITY_SETUP_INSTANCE_ID(v);
				VertexOutput o;
				UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.uv0 = TRANSFORM_TEX(v.texcoord0,_MainTex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = UnityObjectToWorldDir(v.tangent.xyz);
				o.bitangentDir = cross(o.normalDir, o.tangentDir) * v.tangent.w * unity_WorldTransformParams.w;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.ambientOrLightmapUV = VertexGIForward(v.texcoord1, v.texcoord2, o.posWorld, o.normalDir);
				UNITY_TRANSFER_SHADOW(o, v.texcoord1);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			half4 frag (VertexOutput i) : SV_Target
			{
				fixed4 _MainTex_var = tex2Dbias(_MainTex, float4(i.uv0,0,-1));
				fixed3 albedo = _MainTex_var.rgb;

				half4 ms = tex2D(_MixMap, i.uv0);
				half smoothness = clamp(lerp(1.0, _MainTex_var.a, _Roughness), 0.0, 0.97);
				half metallic = 0.0;
				half occlusion = ms.b;
				half sssIntensity = ms.g;
				half curvature = ms.r;

				half oneMinusReflectivity;
				half3 specColor;
				half3 diffColor = DiffuseAndSpecularFromMetallic(albedo, metallic, specColor, oneMinusReflectivity);

				float3 worldPos = i.posWorld.xyz;
				half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				half4 _Bump_var = tex2Dbias(_BumpTex, float4(i.uv0,0,-0.5));
				half3 normalTangent = _Bump_var.xyz * 2.0 - 1.0;
				half4 detail = tex2D(_DetailBumpTex, i.uv0 * _DetailUVScale);
				half3 detailNormalOffset = half3(detail.zw * 2.0 - 1.0, 0.0);
				half3 detailNormalTangent = normalize(normalTangent + detailNormalOffset * 0.5 * _PoreIntensity * _Bump_var.a);
				normalTangent = lerp(detailNormalTangent, normalTangent, curvature);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				half3 normalWorld = normalize(mul(normalTangent, tangentTransform));

				smoothness *= lerp(1.0, detail.x, _Bump_var.a * _PoreIntensity * (1.0 - curvature));

				half3 crystalMaskMap = tex2D(_CrystalMask, i.uv0).rgb;
				half3 crystalMap01 = tex2D(_CrystalMap01, i.uv0 * _CrystalUVTile01 * 5.0).rgb;
				half3 crystalMap02 = tex2D(_CrystalMap02, i.uv0 * _CrystalUVTile02 * 5.0).rgb;
				half3 crystalMap03 = tex2D(_CrystalMap03, i.uv0 * _CrystalUVTile03 * 5.0).rgb;
				half3 crystalMask = crystalMaskMap.x * crystalMap01 * _CrystalColor01.rgb + crystalMaskMap.y * crystalMap02 * _CrystalColor02.rgb + crystalMaskMap.z * crystalMap03 * _CrystalColor03.rgb;
				half3 crystalSpecularColor = saturate(crystalMask * 10.0);

				half crystalWeight = max(crystalSpecularColor.r, max(crystalSpecularColor.g, crystalSpecularColor.b));
				smoothness = lerp(smoothness, 1.0-_CrystalRange, crystalWeight);
				specColor = lerp(specColor, crystalSpecularColor, crystalWeight);
				
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				UnityLight mainLight = MainLight();

				UnityGIInput giData = UnityGIInputSetup(mainLight, worldPos, viewDir, atten, i.ambientOrLightmapUV);
				Unity_GlossyEnvironmentData glossEnvData = UnityGlossyEnvironmentSetup(smoothness, viewDir, normalWorld, specColor);
				UnityGI gi = FragmentGIForward (giData, occlusion, normalWorld, glossEnvData);

				half4 col = BRDF_PBS(diffColor, specColor, smoothness, curvature, sssIntensity, normalWorld, viewDir, gi.light, gi.indirect.diffuse, gi.indirect.specular);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "VertexLit"
}
