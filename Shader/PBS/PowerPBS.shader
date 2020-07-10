// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "PowerPBS/Lit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("NormalMap",2d) = "bump"{}
        _NormalScale("NormalScale",float) = 1

        _MetallicMap("MetallicMap(Metallic:R,Smoothness:A)",2d) = "white"{}
        _Metallic("Metallic",range(0,1)) = 0.5
        _Smoothness("Smoothness",range(0,1)) = 0.5

        _OcclusionMap("OcclusionMap(G))",2d)="white"{}
        _Occlusion("Occlusion",range(0,1)) = 1
    }

    CGINCLUDE
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
            float specTerm = pow(nh,a);
            return normTerm * specTerm;
        }

        float D_GGXTerm(float nh,float a){
            float a2 = a  * a;
            float d = (nh*a2-nh)*nh + 1;
            return INV_PI * a2 / (d*d + 1e-7f);
        }

        float3 FresnelTerm(float3 F0,float lh){
            return F0 + (1-F0) * Pow5(1 - lh);
        }
        float FresnelLerp(float3 f0,float3 f90,float lh){
            float t = Pow5(1-lh);
            return lerp(f0,f90,t);
        }
        float FresnelLerpFast(float3 F0,float3 F90,float lh){
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
            float nv = saturate(dot(n,v));
            float lv = saturate(dot(l,v));
            float lh = saturate(dot(l,h));

            float diffuseTerm = DisneyDiffuse(nv,nl,lh,a) * nl;
            // float diffuseTerm = diffColor*PI * nl;
            float V = SmithJointGGXTerm(nl,nv,a2);
            //float D = NDFBlinnPhongTerm(nh,RoughnessToSpecPower(a));
            float D = D_GGXTerm(nh,a2);
            float3 F = FresnelTerm(specColor,lh);

            float3 specTerm = V * D * PI * nl ;
            specTerm = max(0,specTerm);
            specTerm *= any(specColor)?1:0;

            float surfaceReduction =1 /(a2 * a2+1);
            float grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
            float3 color = diffColor * (gi.diffuse + light.color * diffuseTerm) 
                + specTerm * light.color * F
                + surfaceReduction * gi.specular * FresnelLerp(specColor,grazingTerm,nv);
            return float4(color,1);
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

            return UnityGlobalIllumination(giInput,occlusion,normal,g);
        }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityLightingCommon.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 t2w0:TEXCOORD2;
                float4 t2w1:TEXCOORD3;
                float4 t2w2:TEXCOORD4;
                UNITY_SHADOW_COORDS(5)
                float4 shlmap:TEXCOORD6;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float _NormalScale;

            sampler2D _MetallicMap;
            float _Metallic;

            float _Smoothness;

            sampler2D _OcclusionMap;
            float _Occlusion;


            v2f vert (appdata_full v)
            {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float3 n = UnityObjectToWorldNormal(v.normal);
                float3 t = UnityObjectToWorldDir(v.tangent.xyz);
                float3 b = cross(n,t) * v.tangent.w;
                o.t2w0 = float4(t.x,b.x,n.x,worldPos.x);
                o.t2w1 = float4(t.y,b.y,n.y,worldPos.y);
                o.t2w2 = float4(t.z,b.z,n.z,worldPos.z);

                // UNITY_TRANSFER_LIGHTING(o , v.uv1);
                TRANSFER_SHADOW(o)

                o.shlmap = VertexGI(float4(v.texcoord.xy,v.texcoord1.xy),worldPos,n);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.t2w0.w,i.t2w1.w,i.t2w2.w);
                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);

                //normal map
                float3 n = UnpackScaleNormal(tex2D(_NormalMap,i.uv),_NormalScale);
                n.z = sqrt(1 - saturate(dot(n.xy,n.xy)));
                n = float3(dot(i.t2w0.xyz,n),dot(i.t2w1.xyz,n),dot(i.t2w2.xyz,n));

                float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(worldPos));
                n = normalize(n);

                //occlusion
                float4 occlusionMap = tex2D(_OcclusionMap,i.uv);
                float occlusion = occlusionMap.g * _Occlusion;
                //metallic
                float4 metallicMap = tex2D(_MetallicMap,i.uv);
                float metallic = metallicMap.r * _Metallic;
                float smoothness = metallicMap.a * _Smoothness;
                // calculate gi
                UnityGI gi = CalcGI(l,v,worldPos,n,atten,i.shlmap,smoothness,occlusion);
 
                // sample the texture
                fixed4 albedo = tex2D(_MainTex, i.uv);
                float3 specColor;
                float oneMinusReflectivity;
                albedo.rgb = DiffuseSpecularFromMetallic(albedo.rgb,metallic,specColor,oneMinusReflectivity);

                float outputAlpha;
                albedo.rgb = PreMultiplyAlpha(albedo.rgb,albedo.a,oneMinusReflectivity,outputAlpha);

                float4 c = PBS(albedo.rgb,specColor,oneMinusReflectivity,_Smoothness,n,v,gi.light,gi.indirect);
                c.a = outputAlpha;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, c);
                return c;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
