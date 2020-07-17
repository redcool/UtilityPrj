﻿Shader "Unlit/SimpleStandard"
{
    Properties
    {
        _Color("Color",color) = (1,1,1,1)	//颜色
        _MainTex("Albedo",2D) = "white"{}	//反照率
        _MetallicGlossMap("Metallic(meta:R,gloss:A)",2D) = "white"{} //金属图，r通道存储金属度，a通道存储光滑度
        _BumpMap("Normal Map",2D) = "bump"{}//法线贴图
        _OcclusionMap("Occlusion(G)",2D) = "white"{}//环境光遮挡纹理
        _MetallicStrength("MetallicStrength",Range(0,1)) = 1 //金属强度
        _GlossStrength("Smoothness",Range(0,1)) = 0.5 //光滑强度
        _BumpScale("Normal Scale",float) = 1 //法线影响大小
        _EmissionColor("Emission Color",color) = (0,0,0) //自发光颜色
        _EmissionMap("Emission Map",2D) = "white"{}//自发光贴图
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "HLSLSupport.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "Lighting.cginc"
            #include "PBSCore.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent :TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                half4 ambientOrLightmapUV : TEXCOORD1;//存储环境光或光照贴图的UV坐标
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;//xyz 存储着 从切线空间到世界空间的矩阵，w存储着世界坐标
                SHADOW_COORDS(5) //定义阴影所需要的变量，定义在AutoLight.cginc
                UNITY_FOG_COORDS(6) //定义雾效所需要的变量，定义在UnityCG.cginc
            };

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MetallicGlossMap;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _OcclusionMap;
            float _MetallicStrength;
            float _GlossStrength;
            float4 _EmissionColor;
            sampler2D _EmissionMap;

            //计算环境光照或光照贴图uv坐标
            inline half4 VertexGI(float2 uv1,float2 uv2,float3 worldPos,float3 worldNormal)
            {
                half4 ambientOrLightmapUV = 0;

                //如果开启光照贴图，计算光照贴图的uv坐标
                #ifdef LIGHTMAP_ON
                    ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    //仅对动态物体采样光照探头,定义在UnityCG.cginc
                #elif UNITY_SHOULD_SAMPLE_SH
                    //计算非重要的顶点光照
                    #ifdef VERTEXLIGHT_ON
                        //计算4个顶点光照，定义在UnityCG.cginc
                        ambientOrLightmapUV.rgb = Shade4PointLights(
                        unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
                        unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
                        unity_4LightAtten0,worldPos,worldNormal);
                    #endif
                    //计算球谐光照，定义在UnityCG.cginc
                    //ambientOrLightmapUV.rgb += ShadeSHPerVertex(worldNormal,ambientOrLightmapUV.rgb);
                    ambientOrLightmapUV.rgb += ShadeSH9(half4(worldNormal,1));
                #endif

                //如果开启了 动态光照贴图，计算动态光照贴图的uv坐标
                #ifdef DYNAMICLIGHTMAP_ON
                    ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif

                return ambientOrLightmapUV;
            }

            //计算间接光漫反射
            inline half3 ComputeIndirectDiffuse(half4 ambientOrLightmapUV,half occlusion)
            {
                half3 indirectDiffuse = 0;

                //如果是动态物体，间接光漫反射为在顶点函数中计算的非重要光源
                #if UNITY_SHOULD_SAMPLE_SH
                    indirectDiffuse = ambientOrLightmapUV.rgb;	
                #endif

                //对于静态物体，则采样光照贴图或动态光照贴图
                #ifdef LIGHTMAP_ON
                    //对光照贴图进行采样和解码
                    //UNITY_SAMPLE_TEX2D定义在HLSLSupport.cginc
                    //DecodeLightmap定义在UnityCG.cginc
                    indirectDiffuse = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,ambientOrLightmapUV.xy));
                #endif
                #ifdef DYNAMICLIGHTMAP_ON
                    //对动态光照贴图进行采样和解码
                    //DecodeRealtimeLightmap定义在UnityCG.cginc
                    indirectDiffuse += DecodeRealtimeLightmap(UNITY_SAMPLE_TEX2D(unity_DynamicLightmap,ambientOrLightmapUV.zw));
                #endif

                //将间接光漫反射乘以环境光遮罩，返回
                return indirectDiffuse * occlusion;
            }
            //重新映射反射方向
            inline half3 BoxProjectedDirection(half3 worldRefDir,float3 worldPos,float4 cubemapCenter,float4 boxMin,float4 boxMax)
            {
                //使下面的if语句产生分支，定义在HLSLSupport.cginc中
                UNITY_BRANCH
                if(cubemapCenter.w > 0.0)//如果反射探头开启了BoxProjection选项，cubemapCenter.w > 0
                {
                    half3 rbmax = (boxMax.xyz - worldPos) / worldRefDir;
                    half3 rbmin = (boxMin.xyz - worldPos) / worldRefDir;

                    half3 rbminmax = (worldRefDir > 0.0f) ? rbmax : rbmin;

                    half fa = min(min(rbminmax.x,rbminmax.y),rbminmax.z);

                    worldPos -= cubemapCenter.xyz;
                    worldRefDir = worldPos + worldRefDir * fa;
                }
                return worldRefDir;
            }
            //采样反射探头
            //UNITY_ARGS_TEXCUBE定义在HLSLSupport.cginc,用来区别平台
            inline half3 SamplerReflectProbe(UNITY_ARGS_TEXCUBE(tex),half3 refDir,half roughness,half4 hdr)
            {
                roughness = roughness * (1.7 - 0.7 * roughness);
                half mip = roughness * 6;
                //对反射探头进行采样
                //UNITY_SAMPLE_TEXCUBE_LOD定义在HLSLSupport.cginc，用来区别平台
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex,refDir,mip);
                //采样后的结果包含HDR,所以我们需要将结果转换到RGB
                //定义在UnityCG.cginc
                return DecodeHDR(rgbm,hdr);
            }
            //计算间接光镜面反射
            inline half3 ComputeIndirectSpecular(half3 refDir,float3 worldPos,half roughness,half occlusion)
            {
                half3 specular = 0;
                //重新映射第一个反射探头的采样方向
                half3 refDir1 = BoxProjectedDirection(refDir,worldPos,unity_SpecCube0_ProbePosition,unity_SpecCube0_BoxMin,unity_SpecCube0_BoxMax);
                //对第一个反射探头进行采样
                half3 ref1 = SamplerReflectProbe(UNITY_PASS_TEXCUBE(unity_SpecCube0),refDir1,roughness,unity_SpecCube0_HDR);
                //如果第一个反射探头的权重小于1的话，我们将会采样第二个反射探头，进行混合
                //使下面的if语句产生分支，定义在HLSLSupport.cginc中
                UNITY_BRANCH
                if(unity_SpecCube0_BoxMin.w < 0.99999)
                {
                    //重新映射第二个反射探头的方向
                    half3 refDir2 = BoxProjectedDirection(refDir,worldPos,unity_SpecCube1_ProbePosition,unity_SpecCube1_BoxMin,unity_SpecCube1_BoxMax);
                    //对第二个反射探头进行采样
                    half3 ref2 = SamplerReflectProbe(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0),refDir2,roughness,unity_SpecCube1_HDR);

                    //进行混合
                    specular = lerp(ref2,ref1,unity_SpecCube0_BoxMin.w);
                }
                else
                {
                    specular = ref1;
                }
                return specular * occlusion;
            }

            //计算间接光镜面反射菲涅尔项
            inline half3 ComputeFresnelLerp(half3 c0,half3 c1,half cosA)
            {
                //half t = pow(1 - cosA,5);
                float f0 = 1-cosA;
                float f1 = f0*f0;
                float t = f1 * f1* f0;
                return lerp(c0,c1,t);
            }
            //计算Smith-Joint阴影遮掩函数，返回的是除以镜面反射项分母的可见性项V
            inline half ComputeSmithJointGGXVisibilityTerm(half nl,half nv,half roughness)
            {
                half ag = roughness * roughness;
                half lambdaV = nl * (nv * (1 - ag) + ag);
                half lambdaL = nv * (nl * (1 - ag) + ag);
                
                return 0.5f/(lambdaV + lambdaL + 1e-5f);
            }
            //计算法线分布函数
            inline half ComputeGGXTerm(half nh,half roughness)
            {
                half a = roughness * roughness;
                half a2 = a * a;
                half d = (a2 - 1.0f) * nh * nh + 1.0f;
                //UNITY_INV_PI定义在UnityCG.cginc  为1/π
                return a2 * UNITY_INV_PI / (d * d + 1e-5f);
            }
            //计算菲涅尔
            inline half3 ComputeFresnelTerm(half3 F0,half cosA)
            {
                return F0 + (1 - F0) * pow(1 - cosA, 5);
            }
            //计算漫反射项
            inline half3 ComputeDisneyDiffuseTerm(half nv,half nl,half lh,half roughness,half3 baseColor)
            {
                half Fd90 = 0.5f + 2 * roughness * lh * lh;
                return baseColor * UNITY_INV_PI * (1 + (Fd90 - 1) * pow(1-nl,5)) * (1 + (Fd90 - 1) * pow(1-nv,5));
            }


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);//初始化结构体数据，定义在HLSLSupport.cginc

                o.pos = UnityObjectToClipPos(v.vertex);//将模型空间转换到裁剪空间，定义在UnityShaderUtilities.cginc
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);//计算偏移后的uv坐标,定义在UnityCG.cginc

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = UnityObjectToWorldDir(v.tangent);
                half3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                //计算环境光照或光照贴图uv坐标
                o.ambientOrLightmapUV = VertexGI(v.texcoord1,v.texcoord2,worldPos,worldNormal);

                //前3x3存储着从切线空间到世界空间的矩阵，后3x1存储着世界坐标
                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                //填充阴影所需要的参数,定义在AutoLight.cginc
                TRANSFER_SHADOW(o);
                //填充雾效所需要的参数，定义在UnityCG.cginc
                UNITY_TRANSFER_FOG(o,o.pos);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //数据准备
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);//世界坐标
                half3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;//反照率
                half2 metallicGloss = tex2D(_MetallicGlossMap,i.uv).ra;
                half metallic = metallicGloss.x * _MetallicStrength;//金属度
                half roughness = 1 - metallicGloss.y * _GlossStrength;//粗糙度
                half occlusion = tex2D(_OcclusionMap,i.uv).g;//环境光遮挡

                //计算世界空间中的法线
                half3 normalTangent = UnpackScaleNormal(tex2D(_BumpMap,i.uv),_BumpScale);
                //normalTangent.xy *= _BumpScale;
                normalTangent.z = sqrt(1.0 - saturate(dot(normalTangent.xy,normalTangent.xy)));
                half3 worldNormal = normalize(half3(dot(i.TtoW0.xyz,normalTangent),
                dot(i.TtoW1.xyz,normalTangent),dot(i.TtoW2.xyz,normalTangent)));

                half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));//世界空间下的灯光方向,定义在UnityCG.cginc
                half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));//世界空间下的观察方向,定义在UnityCG.cginc
                half3 refDir = reflect(-viewDir,worldNormal);//世界空间下的反射方向

                half3 emission = tex2D(_EmissionMap,i.uv).rgb * _EmissionColor;//自发光颜色

                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);//计算阴影和衰减,定义在AutoLight.cginc

                //计算BRDF需要用到一些项
                half3 halfDir = normalize(lightDir + viewDir);
                half nv = saturate(dot(worldNormal,viewDir));
                half nl = saturate(dot(worldNormal,lightDir));
                half nh = saturate(dot(worldNormal,halfDir));
                half lv = saturate(dot(lightDir,viewDir));
                half lh = saturate(dot(lightDir,halfDir));
                //计算镜面反射率
                half3 specColor = lerp(unity_ColorSpaceDielectricSpec.rgb,albedo,metallic);
                //计算1 - 反射率,漫反射总比率
                half oneMinusReflectivity = (1- metallic) * unity_ColorSpaceDielectricSpec.a;
                //计算漫反射率
                half3 diffColor = albedo * oneMinusReflectivity;
                //计算间接光
                half3 indirectDiffuse = ComputeIndirectDiffuse(i.ambientOrLightmapUV,occlusion);//计算间接光漫反射
                half3 indirectSpecular = ComputeIndirectSpecular(refDir,worldPos,roughness,occlusion);//计算间接光镜面反射
                //计算掠射角时反射率
                half grazingTerm = saturate((1 - roughness) + (1-oneMinusReflectivity));
                //计算间接光镜面反射
                indirectSpecular *= ComputeFresnelLerp(specColor,grazingTerm,nv);
                //计算间接光漫反射
                indirectDiffuse *= diffColor;
                half V = ComputeSmithJointGGXVisibilityTerm(nl,nv,roughness);//计算BRDF高光反射项，可见性V
                half D = ComputeGGXTerm(nh,roughness);//计算BRDF高光反射项,法线分布函数D
                // float V = GSF1(nl,nv);
                // float D = BlinnPhongNormalDistribution(nh,_GlossStrength*32,_GlossStrength);
                half3 F = ComputeFresnelTerm(specColor,lh);//计算BRDF高光反射项，菲涅尔项F

                half3 specularTerm = V * D * F;//计算镜面反射项
                half3 diffuseTerm = ComputeDisneyDiffuseTerm(nv,nl,lh,roughness,diffColor);//计算漫反射项

                //计算最后的颜色
                half3 color = UNITY_PI * (diffuseTerm + specularTerm) * _LightColor0.rgb * nl * atten
                + indirectDiffuse + indirectSpecular + emission;

                //设置雾效,定义在UnityCG.cginc
                UNITY_APPLY_FOG(i.fogCoord, color.rgb);
                return float4(color,1);
            }
            ENDCG
        }
    }
    fallback "Diffuse"
}
