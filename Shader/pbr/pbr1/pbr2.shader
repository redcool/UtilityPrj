Shader "Hidden/pbr2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("_Smoothness",range(0,1)) = 0.5
    }
    SubShader
    {

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityLib.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 tSpace0:TEXCOORD1;
                float4 tSpace1:TEXCOORD2;
                float4 tSpace2:TEXCOORD3;
                // float3 viewWorldSpace:TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = TransformObjectToWorld(v.vertex);
                o.vertex = TransformWorldToHClip(worldPos);
                o.uv = v.uv;
                half3 normal = TransformObjectToWorldNormal(v.normal);
                o.tSpace0 = float4(0,0,normal.x,worldPos.x);
                o.tSpace1 = float4(0,0,normal.y,worldPos.y);
                o.tSpace2 = float4(0,0,normal.z,worldPos.z);
                
                return o;
            }

            sampler2D _MainTex;
            half _Smoothness,_Metallic;

            samplerCUBE unity_SpecCube0;
            float4 unity_SpecCube0_HDR;

            half4 frag (v2f i) : SV_Target
            {
                half4 mainTex = tex2D(_MainTex, i.uv);
                half3 albedo = mainTex.xyz;
                half alpha= mainTex.w;

                float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
                half3 n = normalize(float3(i.tSpace0.z,i.tSpace1.z,i.tSpace2.z));
                half3 v = normalize(GetWorldSpaceViewDir(worldPos));
                half3 l = GetWorldSpaceLightDir(worldPos);
                half3 h = normalize(v+l);
                half3 reflectDir = reflect(-v,n);

                half nl = saturate(dot(n,l));
                half nv = saturate(dot(n,v));
                half nh = saturate(dot(n,h));
                half lh = saturate(dot(l,h));

                half metallic =_Metallic;
                half smoothness = _Smoothness;
                half roughness = 1 - smoothness;

#define HALF_MIN 6.103515625e-5  // 2^-14, the same value for 10, 11 and 16-bit: https://www.khronos.org/opengl/wiki/Small_Float_Formats
#define HALF_MIN_SQRT 0.0078125  // 2^-7 == sqrt(HALF_MIN), useful for ensuring HALF_MIN after x^2

                half a = max(roughness * roughness,HALF_MIN_SQRT);
                half a2 = max(a * a,HALF_MIN);


                half3 diffColor = albedo * (1 - metallic);
                half3 specColor = lerp(0.04,albedo,metallic);

                half fresnel = Pow4(1 - nv);
                half3 sh = SampleSH(n) ;
                half3 giDiff = sh * diffColor;

                half mip = roughness * (1.7 - 0.7*roughness) * 6;
                half4 envColor = texCUBElod(unity_SpecCube0,float4(reflectDir,mip));
                envColor.xyz = DecodeHDREnvironment(envColor, unity_SpecCube0_HDR);
 
                half surfaceReduction = 1/(a2+1);
                half grazingTerm = saturate(smoothness + metallic);
                half3 giSpec = envColor * surfaceReduction * lerp(specColor,grazingTerm,fresnel);

                float4 col = 0;
                col.xyz = giDiff + giSpec;

                half specTerm = MinimalistCookTorrance(nh,lh,a,a2);//D_GGXNoPI(nh,a2);
                
                half3 radiance = nl * _MainLightColor.xyz;
                col.xyz += (diffColor + specColor*specTerm) * radiance;
                return col;
            }
            ENDHLSL
        }
    }
}
