Shader "Hidden/Custom/SimpleBloom"
{
    HLSLINCLUDE

        
		#include "../PostLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		float4 _MainTex_TexelSize;

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
				float _Threshold;

				float4 Frag(VaryingsDefault i) : SV_Target
				{
					float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
					
					float g = dot(color.rgb, float3(0.2126729, 0.7151522, 0.0721750));
					g = saturate(g - _Threshold);
					return color *g;
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
				float4 col = SampleBox(_MainTex,sampler_MainTex,_MainTex_TexelSize,i.texcoord,_BlurSize,.25,0);
				return col;
			}
			ENDHLSL
		}
//2 
		Pass{
			HLSLPROGRAM
			#pragma vertex VertDefault
			#pragma fragment Frag

			TEXTURE2D_SAMPLER2D(_BloomTex,sampler_BloomTex);
			float4 _BloomTex_TexelSize;

			float4 _BloomColor;
			float _Intensity;
			float _Power;

			float4 Frag(VaryingsDefault i) :SV_Target{
				float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.texcoord);
				//float4 col2 = SampleBox(_MainTex, sampler_MainTex, _MainTex_TexelSize, i.texcoord,2,0.17,0.0);
				//float3 bloom = SAMPLE_TEXTURE2D(_BloomTex, sampler_BloomTex, i.texcoord).rgb;
				float4 bloom = SampleBox(_BloomTex, sampler_BloomTex, _BloomTex_TexelSize, i.texcoord, 0.5,0.25,0);
				bloom *= _Intensity;
				//bloom *= pow(bloom, _Power);
				bloom = smoothstep(bloom, bloom - 0.02, _Power);
				//return mainBloom;

				col.rgb += bloom.rgb * _BloomColor.rgb;
				return col;
			}

			ENDHLSL
		}
    }
}