Shader "Unlit/PBRTest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    CGINCLUDE
    #include "UnityStandardBRDF.cginc"

    half4 PBS(half3 diffColor,half3 specColor,half oneMinusReflectivity,half smoothness,
        float3 normal,float3 viewDir,UnityLight light,UnityIndirect gi)
    {
        
        float a = 1 - smoothness;
        float a2 = a * a;
        a2 = max(a2,0.002);

        float3 v = normalize(viewDir);
        float3 l = normalize(light.dir);
        float3 n = normalize(normal);
        float3 h = normalize(l+v);

        float nl = saturate(dot(n,l));
        float nv = saturate(dot(n,v));
        float nh = saturate(dot(n,h));
        float lh = saturate(dot(l,h));
        float lv = saturate(dot(l,v));

        half diffuseTerm = DisneyDiffuse(nv,nl,lh,a) * nl;
        float V = SmithJointGGXVisibilityTerm(nl,nv,a2);
        float D = GGXTerm(nh,a2);
        float3 F = FresnelTerm(specColor,lh);

        float surfaceReduction = 1/(a2*a2+1);

        float specularTerm = V*D*UNITY_PI * nl;
        specularTerm = max(0,specularTerm);
        specularTerm *= any(specColor) ? 1 : 0;

        float grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
        half3 color = diffColor * (gi.diffuse + light.color * diffuseTerm)
            + specularTerm * light.color * F
            + surfaceReduction * gi.specular * FresnelLerp(specColor,grazingTerm,nv);
        return float4(color,1);
        /*
    float a = 1 - (smoothness);
    float3 halfDir = normalize (float3(light.dir) + viewDir);

#define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

#if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
    // The amount we shift the normal toward the view vector is defined by the dot product.
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    // A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
    //normal = normalize(normal);

    float nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
#else
    half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
#endif

    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse term
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, a) * nl;

    // Specular term
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    float a2 = a*a;
    a2 = max(a2, 0.002);
    float V = SmithJointGGXVisibilityTerm (nl, nv, a2);
    float D = GGXTerm (nh, a2);
    float3 F = FresnelTerm (specColor, lh);

    float specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(a2^2+1)
    half surfaceReduction;
        surfaceReduction = 1.0 / (a2*a2 + 1.0);           // fade \in [0.5;1]

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * F
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);

    return half4(color, 1);
    */
    }

    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"
            
            struct v2f
            {
                UNITY_POSITION(pos);
                float2 uv : TEXCOORD0; // _MainTex
                float3 worldNormal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                #if UNITY_SHOULD_SAMPLE_SH
                half3 sh : TEXCOORD3; // SH
                #endif
                UNITY_LIGHTING_COORDS(4,5)
                #if SHADER_TARGET >= 30
                float4 lmap : TEXCOORD6;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

        //---------------------------------------

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct Input
            {
                float2 uv_MainTex;
            };

            half _Glossiness;
            half _Metallic;
            fixed4 _Color;

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // //#pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                // Albedo comes from a texture tinted by color
                fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = c.a;
            }
        //----------------------------------------------------------

            inline half4 Lighting (SurfaceOutputStandard s, float3 viewDir, UnityGI gi)
            {
                s.Normal = normalize(s.Normal);

                half oneMinusReflectivity;
                half3 specColor;
                s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);
                // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
                // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
                half outputAlpha;
                s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

                half4 c = PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
                c.a = outputAlpha;
                return c;
            }

            v2f vert (appdata_full v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                UNITY_TRANSFER_INSTANCE_ID(v,o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
                #endif
                #if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED) && !defined(UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS)
                o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                #endif
                o.worldPos.xyz = worldPos;
                o.worldNormal = worldNormal;
                #ifdef DYNAMICLIGHTMAP_ON
                o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                #ifdef LIGHTMAP_ON
                o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif

                // SH/ambient and vertex lights
                #ifndef LIGHTMAP_ON
                    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    o.sh = 0;
                    // Approximated illumination from non-important point lights
                    #ifdef VERTEXLIGHT_ON
                        o.sh += Shade4PointLights (
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, worldPos, worldNormal);
                    #endif
                    o.sh = ShadeSHPerVertex (worldNormal, o.sh);
                    #endif
                #endif // !LIGHTMAP_ON

                UNITY_TRANSFER_LIGHTING(o,v.texcoord1.xy); // pass shadow and, possibly, light cookie coordinates to pixel shader
                #ifdef FOG_COMBINED_WITH_TSPACE
                    UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(o,o.pos); // pass fog coordinates to pixel shader
                #elif defined (FOG_COMBINED_WITH_WORLD_POS)
                    UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(o,o.pos); // pass fog coordinates to pixel shader
                #else
                    UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
                #endif
                return o;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                // prepare and unpack data
                Input surfIN;
                #ifdef FOG_COMBINED_WITH_TSPACE
                    UNITY_EXTRACT_FOG_FROM_TSPACE(IN);
                #elif defined (FOG_COMBINED_WITH_WORLD_POS)
                    UNITY_EXTRACT_FOG_FROM_WORLD_POS(IN);
                #else
                    UNITY_EXTRACT_FOG(IN);
                #endif
                UNITY_INITIALIZE_OUTPUT(Input,surfIN);
                surfIN.uv_MainTex.x = 1.0;
                surfIN.uv_MainTex = IN.uv.xy;
                float3 worldPos = IN.worldPos.xyz;
                #ifndef USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                #else
                    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                #endif
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                #ifdef UNITY_COMPILER_HLSL
                SurfaceOutputStandard o = (SurfaceOutputStandard)0;
                #else
                SurfaceOutputStandard o;
                #endif
                o.Albedo = 0.0;
                o.Emission = 0.0;
                o.Alpha = 0.0;
                o.Occlusion = 1.0;
                fixed3 normalWorldVertex = fixed3(0,0,1);
                o.Normal = IN.worldNormal;
                normalWorldVertex = IN.worldNormal;

                // call surface function
                surf (surfIN, o);

                // compute lighting & shadowing factor
                UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
                fixed4 c = 0;

                // Setup lighting environment
                UnityGI gi;
                UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
                gi.indirect.diffuse = 0;
                gi.indirect.specular = 0;
                gi.light.color = _LightColor0.rgb;
                gi.light.dir = lightDir;
                // Call GI (lightmaps/SH/reflections) lighting function
                UnityGIInput giInput;
                UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
                giInput.light = gi.light;
                giInput.worldPos = worldPos;
                giInput.worldViewDir = worldViewDir;
                giInput.atten = atten;
                #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                    giInput.lightmapUV = IN.lmap;
                #else
                    giInput.lightmapUV = 0.0;
                #endif
                #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    giInput.ambient = IN.sh;
                #else
                    giInput.ambient.rgb = 0.0;
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
                LightingStandard_GI(o, giInput, gi);
                // realtime lighting: call lighting function
                c += Lighting(o, worldViewDir, gi);
                UNITY_APPLY_FOG(_unity_fogCoord, c); // apply fog
                UNITY_OPAQUE_ALPHA(c.a);
                return c;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
