Shader "Skybox/Blend3TexturesSky"
{
    Properties
    {
        [HDR]_Tint ("Tint Color", Color) = (1,1,1,1)
        _DayTex("_DayTex",2d)=""{}
		_EveningTex("_EveningTex",2d)=""{}
		_NightTex("_NightTex",2d)=""{}

		_Value("_Value",float) = 0
    }
    
    SubShader
    {
        Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
        // Cull Off ZWrite Off
        
        CGINCLUDE
        #include "UnityCG.cginc"
        
        struct appdata_t
        {
            float4 vertex: POSITION;
            float2 texcoord: TEXCOORD0;
			float3 normal:NORMAL;
            //UNITY_VERTEX_INPUT_INSTANCE_ID
        };
        struct v2f
        {
            float4 vertex: SV_POSITION;
            float2 texcoord: TEXCOORD0;
			float3 normal:TEXCOORD1;
            //UNITY_VERTEX_OUTPUT_STEREO
        };
        v2f vert(appdata_t v)
        {
            v2f o;
            //UNITY_SETUP_INSTANCE_ID(v);
            //UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.texcoord = v.texcoord;
			o.normal = UnityObjectToWorldNormal(v.normal);
            return o;
        }

        ENDCG
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            sampler2D _DayTex,_EveningTex,_NightTex;
			float _Value;


			float3 SunDisk(float3 normal,float3 lightDir){
				float nl = saturate(dot(-normal,lightDir));
				return smoothstep(0.95,0.99,nl);
				// return pow(nl,128);
			}

            #define MAX_COUNT 3
			float4 Lerp4Textures(float rate,float2 uv){
				float id = floor(rate % MAX_COUNT);
                float p = frac(rate);
                float4 c0 = tex2D(_NightTex, uv);
                float4 c1 = tex2D(_EveningTex, uv);
                float4 c2 = tex2D(_DayTex, uv);
                float4 cols[MAX_COUNT] = {
                    c0, c1, c2
                };

                float lastId = (id == 0 ? 0:id-1) ;
				float4 col = lerp(cols[lastId], cols[id], p);
				return col;
			}
            
            half4 frag(v2f i): SV_Target
            {
				float3 n = normalize(i.normal);
				float3 l = normalize(_WorldSpaceLightPos0);
				float sunDisk = SunDisk(n,l);

				float sunNL = dot(l,float3(0,1,0));
				float sunRate = sunNL * 0.5+0.5;
				// return sunRate;
				float4 col = Lerp4Textures(sunRate * MAX_COUNT,i.texcoord);
				float3 sunColor = lerp(col,1,sunNL);
				// col.rgb += sunColor * sunDisk;

                return col;
            }
            ENDCG
            
        }
    }
}
