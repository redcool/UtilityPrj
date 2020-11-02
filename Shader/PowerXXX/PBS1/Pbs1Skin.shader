// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
/**
    法线图
    阴影
    高光,漫射

*/
Shader "Unlit/Pbs1 skin"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainTexIntensity("_MainTexIntensity",float) = 1
        _Color("_Color",color) = (1,1,1,1)
        _NormalMap("_NormalMap",2d) = "bump"{}
        _NormalMapIntensity("_NormalMapIntensity",float) = 1
        _Metallic("_Metallic",range(0,1)) = 0.04
        _Smoothness("_Smoothness",range(0,1)) = 0.5
        _Occlusion("_Occlusion",range(0,1)) = 1

        _DetailNormalMap("_DetailNormalMap",2d) = "bump"{}
        _DetailNormalMapIntensity("_DetailNormalMapIntensity",float) = 1
        _NormalBlendIntensity("_NormalBlendIntensity",range(0,1)) = 0

        _SkinLUT("_SkinLUT(R)",2d) = ""{}
        _SkinIntensity("_SkinIntensity",range(0,1)) = 1

        _SSSThickMap("_SSSThickMap(R)",2d) = ""{}
        _SSSColor("_SSSColor",color) = (1,1,1,1)
        _FrontSSSIntensity("_FrontSSSIntensity",range(0,1)) = 1
        _BackSSSIntensity("_BackSSSIntensity",range(0,1)) = 1

        _LipSpecMap("_LipSpecMap",2d) = ""{}
        _LipSpecMask("_LipSpecMask(B)",2d) =""{}
        _SpecIntensity("_SpecIntensity",float) = 1

        _FlowNormalMap("_FlowNormalMap",2d) = ""{}
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
            #pragma target 3.0
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbase_fullshadows
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "UnityStandardUtils.cginc"
            #include "UnityStandardBRDF.cginc"

            #include "UnityImageBasedLighting.cginc"
            #include "UnityGlobalIllumination.cginc"

            #define PI 3.1415
            #define SKIN_DIFFUSE
            #define LIP_SPEC

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1:TEXCOORD1;
                float2 uv2:TEXCOORD2;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 uv2 : TEXCOORD2;
                float4 tSpace0 : TEXCOORD3;
                float4 tSpace1 : TEXCOORD4;
                float4 tSpace2 : TEXCOORD5;
                LIGHTING_COORDS(6,7)
                float4 lightmapOrSH:TEXCOORD8;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MainTexIntensity;
            float4 _Color;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float _NormalMapIntensity;
            sampler2D _DetailNormalMap;
            float4 _DetailNormalMap_ST;
            float _DetailNormalMapIntensity;
            float _NormalBlendIntensity;

            float _Smoothness;
            float _Metallic;
            float _Occlusion;
// skin
            sampler2D _SkinLUT;
            float _SkinIntensity;
            sampler2D _SSSThickMap;
            float3 _SSSColor;
            float _BackSSSIntensity;
            float _FrontSSSIntensity;

            sampler2D _LipSpecMask;
            sampler2D _LipSpecMap;
            float4 _LipSpecMap_ST;
            float _SpecIntensity;

            sampler2D _FlowNormalMap;
//------------ gi
            void VertexGI(inout v2f o,appdata v,float3 worldPos,float3 worldNormal){
                #ifdef LIGHTMAP_ON
                o.lightmapOrSH.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                #ifdef DYNAMICLIGHTMAP_ON
                o.lightmapOrSH.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif

                #if !defined(LIGHTMAP_ON)
                    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    o.lightmapOrSH = 0;
                        #if VERTEXLIGHT_ON
                        o.lightmapOrSH += Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
                            unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
                            unity_4LightAtten0,worldPos,worldNormal);
                        #endif
                    o.lightmapOrSH.xyz = ShadeSHPerVertex(worldNormal,o.lightmapOrSH);
                    #endif
                #endif
            }
            UnityGI FragGI(float3 lightDir,float3 lightColor,float3 worldPos,float atten,float3 viewDir,float3 normal,float4 lightmapOrSH,float rough,float occlusion){
                UnityGI gi = (UnityGI)0;
                gi.light.dir = lightDir;
                gi.light.color = lightColor;

                UnityGIInput giInput = (UnityGIInput)0;
                giInput.light = gi.light;
                giInput.worldPos = worldPos;
                giInput.worldViewDir = viewDir;
                giInput.atten = atten;
                giInput.lightmapUV = lightmapOrSH;
                giInput.ambient = lightmapOrSH.xyz;
                giInput.probeHDR[0] = unity_SpecCube0_HDR;
                giInput.probeHDR[1] = unity_SpecCube1_HDR;
                #if defined(UNITY_SPECCUBE_BLENDING)
                    giInput.boxMin[0]=unity_SpecCube0_BoxMin;
                #endif
                #if defined(UNITY_SPECCUBE_BOX_PROJECTION)
                giInput.boxMin[1] = unity_SpecCube1_BoxMin;
                giInput.boxMax[0] = unity_SpecCube0_BoxMax;
                giInput.boxMax[1] = unity_SpecCube1_BoxMax;
                giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
                giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
                #endif
                
                Unity_GlossyEnvironmentData envData = (Unity_GlossyEnvironmentData)0;
                envData.roughness = rough;
                envData.reflUVW = reflect(-viewDir,normal);

                gi = UnityGlobalIllumination(giInput,occlusion,normal,envData);
                return gi;
            }
//---------------------
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = v.uv1;
                o.uv2.xy = v.uv2;

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float3 n = mul(v.normal,unity_WorldToObject);
                float3 t = mul(unity_ObjectToWorld,v.tangent.xyz);
                float3 bt = normalize(cross(n,t) * v.tangent.w);
                o.tSpace0 = float4(t.x,bt.x,n.x,worldPos.x);
                o.tSpace1 = float4(t.y,bt.y,n.y,worldPos.y);
                o.tSpace2 = float4(t.z,bt.z,n.z,worldPos.z);

                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                VertexGI(/**/o,v,worldPos,n);
                return o;
            }

            void DiffuseSpecularColor(inout float3 albedo,inout float3 specColor,float metallic){
                specColor = lerp(0.04,albedo,metallic);
                albedo *= (1 - metallic);
            }

            float SmithJoingGGX(float nl,float nv,float rough){
                float l = nl * (nv *(1-rough)+rough);
                float v = nv *(nl * (1-rough)+rough);
                return 0.5/(l+v+0.0001);
            }
            float GGXSilk(float nh,float rough){
                float a2 = rough * rough;
                float b = (nh * a2 -nh*2) + 1;
                return a2/(b*b);
            }
            float GGX(float nh,float rough){
                float a2 = rough * rough;
                float d = (nh * a2 - nh) * nh + 1;
                return a2/((d*d+0.0000001) * 3.14);
            }

            float Fresnel(float f0,float nh){
                return f0+(1-f0)*pow(1-nh,5);
            }

            UnityLight MainLight(float worldPos){
                UnityLight l = {_LightColor0.xyz,UnityWorldSpaceLightDir(worldPos),0};
                return l;
            }

            float3 FastSSS(float3 lightDir,float3 viewDir){
                float sss = saturate(-dot(lightDir,viewDir));
                return sss * _SSSColor;
            }

            inline float SkinDiffuse(float nl){
                return tex2D(_SkinLUT,float2(nl*0.5+0.5,_SkinIntensity));
            }

            inline float3 LipSpecColor(float2 uv,float3 specColor){
                float3 lipSpec = tex2D(_LipSpecMap,TRANSFORM_TEX(uv,_LipSpecMap));
                float3 lipSpecMask = tex2D(_LipSpecMask,uv);
                return lerp(specColor,lipSpec,lipSpecMask.x+lipSpecMask.y+lipSpecMask.z);
            }
            inline float N21(float2 uv){
                return frac(sin(dot(uv,float2(100,789)))*56789);
            }

            half3 BRDF_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
                float3 normal, float3 viewDir,
                UnityLight light, UnityIndirect gi)
            {
                float rough = 1 - smoothness;
                float rough2 = rough * rough;
                rough2 = max(rough2,0.002);

                float3 h = normalize(light.dir + viewDir);
                float nl = saturate(dot(normal,light.dir));
                // skin
                #if defined(SKIN_DIFFUSE)
                nl = SkinDiffuse(nl);
                #endif
                // nl = smoothstep(0.1,0.6,nl)*0.5+.4;
                // return nl;
                float nh = saturate(dot(normal,h));
                float nv = abs(dot(normal,viewDir));
                float lv = saturate(dot(light.dir,viewDir));
                float lh = saturate(dot(light.dir,h));

                float V = SmithJoingGGX(nl,nv,rough);
                float D = GGX(nh,rough2);
                float3 F = FresnelTerm(specColor,lh);
                
                float spec = V * D * PI;
                spec = max(0,spec * nl);
                spec *= any(specColor)?1:0;
                float3 specDirect = spec * light.color * F;
                float3 diffuseTerm= diffColor * (gi.diffuse + light.color * nl);
                
                float grazingTerm = saturate(smoothness + (1- oneMinusReflectivity));
                float surfaceReduction = 1.0 / (rough2 + 1.0);
                float3 specTerm = specDirect + surfaceReduction * gi.specular * FresnelLerp(specColor,grazingTerm,nv);
                return diffuseTerm + specTerm;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);

                //normal map
                float3 tn = UnpackScaleNormal(tex2D(_NormalMap,TRANSFORM_TEX(i.uv.xy,_NormalMap)),_NormalMapIntensity);
                float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap,TRANSFORM_TEX(i.uv.xy,_DetailNormalMap)),_DetailNormalMapIntensity);
                tn = lerp(tn,BlendNormals(tn,detailNormal),_NormalBlendIntensity);
                float3 t1 = tex2D(_NormalMap,i.uv.xy);
                float3 t2 = tex2D(_FlowNormalMap,i.uv.xy);
                tn = normalize((t1+t2));
                // return tn.xyzx;

                float3 n = normalize(float3(
                    dot(i.tSpace0.xyz,tn),
                    dot(i.tSpace1.xyz,tn),
                    dot(i.tSpace2.xyz,tn)
                ));
                float3 v = normalize(UnityWorldSpaceViewDir(worldPos));

                // 
                float smoothness = _Smoothness;
                float rough = 1 - smoothness;
                float metallic = _Metallic;
                float occlusion = _Occlusion;

                // shadow
                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);
                // gi
                UnityLight light = MainLight(worldPos);
                // UnityLight light = {_LightColor0.rgb,_WorldSpaceLightPos0.xyz,0};
                UnityGI gi = FragGI(light.dir,light.color,worldPos,atten,v,n,i.lightmapOrSH,rough,occlusion);
                
                // sample the texture
                float4 diffColor = tex2D(_MainTex, i.uv.xy) * _MainTexIntensity * _Color;
  
                float3 specColor = 0;
                // DiffuseSpecularColor(diffColor.rgb,specColor,metallic);

                float oneMinusReflectivition;
                diffColor.rgb = DiffuseAndSpecularFromMetallic(diffColor.rgb,metallic,/**/specColor,/**/oneMinusReflectivition);
// return BRDF1_Unity_PBS(diffColor,specColor,oneMinusReflectivition,smoothness,n,v,gi.light,gi.indirect);
                
                #if defined(LIP_SPEC)
                    specColor = LipSpecColor(i.uv,specColor);
                #endif

                float4 col = float4(0,0,0,1);
                col.rgb = BRDF_PBS(diffColor,specColor,oneMinusReflectivition,smoothness,n,v,gi.light,gi.indirect);

                float sssMask = tex2D(_SSSThickMap,i.uv.xy);
                float3 sss = FastSSS(light.dir,v) * sssMask * _BackSSSIntensity;
                float3 sss2 = FastSSS(-light.dir,v) * sssMask * _FrontSSSIntensity;
                
                col.rgb += sss2 + sss;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}

