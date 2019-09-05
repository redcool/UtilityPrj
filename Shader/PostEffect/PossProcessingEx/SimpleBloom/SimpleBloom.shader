Shader "Hidden/Custom/SimpleBloom"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		float4 _MainTex_TexelSize;

		float4 SampleBox(Texture2D tex,SamplerState state,float4 texel,float2 uv, float delta) {
			float2 p = texel.xy * delta;
			float4 c = SAMPLE_TEXTURE2D(tex, state, uv + float2(-p.x, -p.y)) +
				SAMPLE_TEXTURE2D(tex, state, uv + float2(-p.x, p.y)) +
				SAMPLE_TEXTURE2D(tex, state, uv + float2(p.x, -p.y)) +
				SAMPLE_TEXTURE2D(tex, state, uv + float2(p.x, p.y));
			return c * 0.25;
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
				float _Threshold;

				float4 Frag(VaryingsDefault i) : SV_Target
				{
					float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
					/*float g = Max3(color.r, color.g, color.b);
					g -= _Threshold;*/
					
					float g = dot(color.rgb, float3(0.2126729, 0.7151522, 0.0721750));
					g = saturate(g - _Threshold);
					return color * g;
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
				float4 col = SampleBox(_MainTex,sampler_MainTex,_MainTex_TexelSize,i.texcoord,_BlurSize);
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

			float4 Frag(VaryingsDefault i) :SV_Target{
				float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_BloomTex,i.texcoord);
				//float3 bloom = SAMPLE_TEXTURE2D(_BloomTex, sampler_BloomTex, i.texcoord).rgb;
				float3 bloom = SampleBox(_BloomTex, sampler_BloomTex, _BloomTex_TexelSize, i.texcoord, 0.5);
				bloom += pow(bloom, _Intensity)*2;

				col.rgb += bloom * _BloomColor.rgb;
				return col;
			}

			ENDHLSL
		}
    }
}