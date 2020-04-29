Shader "Unlit/LightmapTemplate"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
            Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
            #pragma multi_compile_fwdbase 
			#include "UnityCG.cginc"
            #include "UnityShadowLibrary.cginc"
			#include "Lighting.cginc"
			// #include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
				float2 uv1:TEXCOORD1;
				
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 pos : SV_POSITION; //must pos
				float4 lmap:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
				float3 worldNormal:TEXCOORD4;
                UNITY_SHADOW_COORDS(5)
				//SHADOW_COORDS(5)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.pos);
				#if defined(LIGHTMAP_ON)
					o.lmap.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
                //TRANSFER_SHADOW(o)
				return o;
			}

			float3 MixShadowLightmap(half3 lightmap, half attenuation, half4 bakedColorTex, half3 normalWorld){
				    // Let's try to make realtime shadows work on a surface, which already contains
				// baked lighting and shadowing from the main sun light.
				half3 shadowColor = unity_ShadowColor.rgb ;
				half shadowStrength = _LightShadowData.x;

				// Summary:
				// 1) Calculate possible value in the shadow by subtracting estimated light contribution from the places occluded by realtime shadow:
				//      a) preserves other baked lights and light bounces
				//      b) eliminates shadows on the geometry facing away from the light
				// 2) Clamp against user defined ShadowColor.
				// 3) Pick original lightmap value, if it is the darkest one.


				// 1) Gives good estimate of illumination as if light would've been shadowed during the bake.
				//    Preserves bounce and other baked lights
				//    No shadows on the geometry facing away from the light
				half ndotl = LambertTerm (normalWorld, _WorldSpaceLightPos0.xyz);
				half3 estimatedLightContributionMaskedByInverseOfShadow = ndotl * (1- attenuation) * _LightColor0.rgb;
				half3 subtractedLightmap = lightmap - estimatedLightContributionMaskedByInverseOfShadow;

				// 2) Allows user to define overall ambient of the scene and control situation when realtime shadow becomes too dark.
				half3 realtimeShadow = max(subtractedLightmap, shadowColor);
				realtimeShadow = lerp(realtimeShadow, lightmap, shadowStrength);

				// 3) Pick darkest color
				return min(lightmap, realtimeShadow);
			}

			fixed4 frag (v2f i) : SV_Target
			{   
				fixed4 col = tex2D(_MainTex, i.uv);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                //fixed atten = SHADOW_ATTENUATION(i);
				
				#if defined(LIGHTMAP_ON)
                    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap.xy);
                    half3 bakedColor = DecodeLightmap(bakedColorTex);
                    half bakedAtten = UnitySampleBakedOcclusion(i.lmap.xy, i.worldPos); // shadowm mast
                    //return float4(bakedColor+bakedAtten,1);
				    float zDist = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
					float fadeDist = UnityComputeShadowFadeDistance(i.worldPos, zDist);
					float finalAtten = UnityMixRealtimeAndBakedShadows(atten, bakedAtten, UnityComputeShadowFade(fadeDist));
					//return bakedAtten;
					float3 indirectDiffuse = MixShadowLightmap(bakedColor,finalAtten,bakedColorTex,normalize(i.worldNormal)); //(half3 lightmap, half attenuation, half4 bakedColorTex, half3 normalWorld)
                    return float4(indirectDiffuse,1) ;//+ col *0.7;
                #endif
				// sample the texture
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		//no shaderCaster no shadow
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}
