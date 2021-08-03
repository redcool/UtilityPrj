Shader "Hidden/Custom/SimpleBloom"
{
    HLSLINCLUDE

        
		#include "../PostLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		float4 _MainTex_TexelSize;

		// TEXTURE2D_SAMPLER2D(_SourceTex, sampler_SourceTex);
		TEXTURE2D_SAMPLER2D(_BloomTex,sampler_BloomTex);
		float4 _BloomTex_TexelSize;

		float3 Prefilter(float3 c,half4 filter) {
			float brightness = Gray(c);
			float soft = brightness - filter.y;
			soft = clamp(soft, 0, filter.z);
			soft = soft * soft * filter.w;
			float contribution = max(soft, brightness - filter.x);
			contribution /= max(brightness, 0.0001);
			return c * contribution;
		}

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
//0
        Pass
        {
            HLSLPROGRAM
                #pragma vertex VertDefault
                #pragma fragment Frag
				half4 _Filter;

				float4 Frag(VaryingsDefault i) : SV_Target
				{
					float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
					return float4(Prefilter(color.rgb,_Filter),1);
					
					/*float g = Gray(color.rgb);
					g = saturate(g - _Threshold);
					return color *g;*/
				}

            ENDHLSL
        }
//1
		Pass{
			HLSLPROGRAM
			#pragma vertex VertDefault
			#pragma fragment Frag
			float _BlurSize;

			float4 Frag(VaryingsDefault i) :SV_Target{
				float4 col = SampleBox(_MainTex,sampler_MainTex,_MainTex_TexelSize,i.texcoord,1);
				return col;
			}
			ENDHLSL
		}
//2
		Pass{
			// Blend one One //, error on ios

			HLSLPROGRAM
			#pragma vertex VertDefault
			#pragma fragment Frag

			float4 Frag(VaryingsDefault i) :SV_Target{
				float4 col = SampleBox(_MainTex,sampler_MainTex,_MainTex_TexelSize,i.texcoord,0.5);
				// return col;
				// float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.texcoord);
				float4 bloom = SAMPLE_TEXTURE2D(_BloomTex,sampler_BloomTex,i.texcoord);
				return col+bloom;
			}
			ENDHLSL
		}
//3
		Pass{
			HLSLPROGRAM
			#pragma vertex VertDefault
			#pragma fragment Frag

			float4 _BloomColor;
			float _Intensity;
			float _SmoothBorder;

			float4 Frag(VaryingsDefault i) :SV_Target{
				float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.texcoord);
				float4 bloom = SampleBox(_BloomTex, sampler_BloomTex, _BloomTex_TexelSize, i.texcoord, 0.5);
				bloom *= _Intensity;
				//bloom = smoothstep(bloom, bloom-0.2, _SmoothBorder);
				//bloom *= pow(bloom, _SmoothBorder);
				//return mainBloom;

				col.rgb += bloom.rgb * _BloomColor.rgb;
				return col;
			}

			ENDHLSL
		}
    }
}