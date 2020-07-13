#if !defined(POWER_PBS_CORE_CGINC)
#define POWER_PBS_CORE_CGINC
#include "UnityLightingCommon.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityImageBasedLighting.cginc"
#include "UnityGlobalIllumination.cginc"

#define PI 3.1415926
#define INV_PI 0.31830988618f
#define DielectricSpec 0.04

float Pow4(float a){
    float a2 = a*a;
    return a2*a2;
}
float Pow5(float a){
    float a2 = a*a;
    return a2*a2*a;
}
float DisneyDiffuse(float nv,float nl,float lh,float roughness){
    float fd90 = 0.5 + 2*roughness*lh*lh;
    float lightScatter = 1 - (fd90 - 1) * Pow5(1 - nl);
    float viewScatter = 1 - (fd90 - 1 ) * Pow5(1 - nv);
    return lightScatter * viewScatter;
}
float RoughnessToSpecPower(float a){
    float a2 = a * a;
    float sq = max(1e-4f,a2 * a2);
    float n = 2.0/sq - 2;
    n = max(n,1e-4f);
    return n;
}

float SmithJointGGXTerm(float nl,float nv,float a2){
    float v = nv * (nv * (1-a2)+a2);
    float l = nl * (nl * (1-a2)+a2);
    return 0.5f/(v + l + 1e-5f);
}

float NDFBlinnPhongTerm(float nh,float a){
    float normTerm = (a + 2)* 0.5/PI;
    float specularTerm = pow(nh,a);
    return normTerm * specularTerm;
}

float D_GGXTerm(float nh,float a){
    float a2 = a  * a;
    float d = (nh*a2-nh)*nh + 1;
    return INV_PI * a2 / (d*d + 1e-7f);
}

float3 FresnelTerm(float3 F0,float lh){
    return F0 + (1-F0) * Pow5(1 - lh);
}
float3 FresnelLerp(float3 f0,float3 f90,float lh){
    float t = Pow5(1-lh);
    return lerp(f0,f90,t);
}
float3 FresnelLerpFast(float3 F0,float3 F90,float lh){
    float t = Pow4(1 - lh);
    return lerp(F0,F90,t);
}

float3 DiffuseSpecularFromMetallic(float3 albedo,float metallic,out float3 specColor,out float oneMinusReflectivity){
    specColor = lerp(DielectricSpec,albedo,metallic);

    float diffIntensity = 1 - DielectricSpec;
    oneMinusReflectivity = diffIntensity - metallic * diffIntensity;
    // oneMinusReflectivity = 1 - metallic;

    return albedo * oneMinusReflectivity;
}

float4 PBS(float3 diffColor,half3 specColor,float oneMinusReflectivity,float smoothness,
    float3 normal,float3 viewDir,
    UnityLight light,UnityIndirect gi
){
    
    float a = 1- smoothness;
    float a2 = a * a;
    a2 = max(0.002,a2);
    
    float3 l = normalize(light.dir);
    float3 n = normalize(normal);
    float3 v = normalize(viewDir);
    float3 h = normalize(l + v);
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    // nl = smoothstep(0.1,0.12,nl);
    float nv = abs(dot(n,v));
    float lv = saturate(dot(l,v));
    float lh = saturate(dot(l,h));
    // -------------- diffuse part
    float diffuseTerm = DisneyDiffuse(nv,nl,lh,a) * nl;
    float3 directDiffuse = light.color * diffuseTerm;
    float3 indirectDiffuse = gi.diffuse;
    float3 diffuse = (directDiffuse + indirectDiffuse) * diffColor;

    // -------------- specular part
    // float diffuseTerm = diffColor*PI * nl;
    float V = SmithJointGGXTerm(nl,nv,a2);
    //float D = NDFBlinnPhongTerm(nh,RoughnessToSpecPower(a));
    float D = D_GGXTerm(nh,a2);
    float3 F = FresnelTerm(specColor,lh);

    float3 specularTerm = V * D * PI * nl;
    specularTerm = max(0,specularTerm);
    specularTerm *= any(specColor)?1:0;

    float surfaceReduction =1 /(a2 * a2+1);
    float grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));

    // float3 color = diffColor * (gi.diffuse + light.color * diffuseTerm) 
    //     + specularTerm * light.color * F
    //     + surfaceReduction * gi.specular * FresnelLerpFast(specColor,grazingTerm,nv);

    float3 directSpecular = specularTerm * light.color * F;
    float3 indirecSpecular = surfaceReduction * gi.specular * FresnelLerpFast(specColor,grazingTerm,nv);
    float3 specular = directSpecular + indirecSpecular;
    return float4(diffuse + specular,1);
}

float4 VertexGI(float4 lmapUV/*xy:lmap,zw: realtime lightmap*/,float3 worldPos,float3 worldNormal){
    float4 shlmap = (float4)0;
    #ifdef DYNAMICLIGHTMAP_ON
    shlmap.zw = lmapUV.zw * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
    #ifdef LIGHTMAP_ON
    shlmap.xy = lmapUV.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif

    // SH/ambient and vertex lights
    #ifndef LIGHTMAP_ON
        #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
            shlmap = 0;
            #ifdef VERTEXLIGHT_ON
                o.sh += Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, worldPos, worldNormal);
            #endif
            shlmap.rgb = ShadeSHPerVertex (worldNormal, shlmap);
        #endif
    #endif // !LIGHTMAP_ON
    return shlmap;
}

UnityGI CalcGIIndirectDiffuse(UnityGIInput data,float occlusion,float3 normalWorld){
    UnityGI o_gi;
    ResetUnityGI(o_gi);

    // Base pass with Lightmap support is responsible for handling ShadowMask / blending here for performance reason
    #if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
        half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
        float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
        float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
        data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
    #endif

    o_gi.light = data.light;
    o_gi.light.color *= data.atten;

    #if UNITY_SHOULD_SAMPLE_SH
        o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
    #endif

    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif

        #else // not directional lightmap
            o_gi.indirect.diffuse += bakedColor;

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif

        #endif
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        // Dynamic lightmaps
        fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
        half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
        #else
            o_gi.indirect.diffuse += realtimeColor;
        #endif
    #endif

    o_gi.indirect.diffuse *= occlusion;
    return o_gi;
}

float3 CalcBoxProjectedCubemapDirection(float3 worldRefl,float3 worldPos,float4 cubemapCenter,float4 boxMin,float4 boxMax){
    UNITY_BRANCH
    if (cubemapCenter.w > 0.0)
    {
        float3 nrdir = normalize(worldRefl);
        float3 rbmax = (boxMax.xyz - worldPos) / nrdir;
        float3 rbmin = (boxMin.xyz - worldPos) / nrdir;

        float3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

        float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

        worldPos -= cubemapCenter.xyz;
        worldRefl = worldPos + nrdir * fa;
    }
    return worldRefl;
}

float3 CalcReflectProbe(UNITY_ARGS_TEXCUBE(tex),half4 hdr,Unity_GlossyEnvironmentData glossIn){
    float a = glossIn.roughness;
    a = a * (1.7 - 0.7 * a);
    float mip = a * 6;
    float4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex,glossIn.reflUVW,mip);
    return DecodeHDR(rgbm,hdr);
}

half3 CalcGIIndirectSpecular(UnityGIInput data,float occlusion,Unity_GlossyEnvironmentData glossIn){
    half3 specular;

    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = CalcBoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
    #endif

    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else
        half3 env0 = CalcReflectProbe (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
        #ifdef UNITY_SPECCUBE_BLENDING
            const float kBlendFactor = 0.99999;
            float blendLerp = data.boxMin[0].w;
            UNITY_BRANCH
            if (blendLerp < kBlendFactor)
            {
                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    glossIn.reflUVW = CalcBoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[1], data.boxMin[1], data.boxMax[1]);
                #endif

                half3 env1 = CalcReflectProbe (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), data.probeHDR[1], glossIn);
                specular = lerp(env1, env0, blendLerp);
            }
            else
            {
                specular = env0;
            }
        #else
            specular = env0;
        #endif
    #endif

    return specular * occlusion;
}

UnityGI CalcGI(float3 lightDir,float3 viewDir,float3 worldPos,float3 normal,
    float atten,float4 shlmap,
    float smoothness,float occlusion){
    // gi(sh,lightmap,indirect specular)
    UnityLight light = (UnityLight)0;
    light.color = _LightColor0.rgb;
    light.dir = lightDir;
    
    UnityGIInput giInput = (UnityGIInput)0;
    giInput.light = light;
    giInput.worldPos = worldPos;
    giInput.worldViewDir = viewDir;
    giInput.atten = atten;
    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        giInput.lightmapUV = shlmap;
    #endif
    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
        giInput.ambient = shlmap;
    #endif
    giInput.probeHDR[0] = unity_SpecCube0_HDR;
    giInput.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
        giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        giInput.boxMax[0] = unity_SpecCube0_BoxMax;
        giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
        giInput.boxMax[1] = unity_SpecCube1_BoxMax;
        giInput.boxMin[1] = unity_SpecCube1_BoxMin;
        giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif

    Unity_GlossyEnvironmentData g = (Unity_GlossyEnvironmentData)0;
    g.roughness = 1 - smoothness;
    g.reflUVW = reflect(-viewDir,normal);

    // return UnityGlobalIllumination(giInput,occlusion,normal,g);
    UnityGI gi = CalcGIIndirectDiffuse(giInput,occlusion,normal);
    gi.indirect.specular = CalcGIIndirectSpecular(giInput,occlusion,g);
    return gi;
}
#endif //end of POWER_PBS_CORE_CGINC