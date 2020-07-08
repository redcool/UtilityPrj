// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/PBSTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // _SpecColor("SpecColor",color) = (1,1,1,1)
        _Metallic("metallic",range(0,1)) = 0.5
        _Smoothness("Smoothness",range(0,1)) = 0
    }

    CGINCLUDE
        #include "UnityLightingCommon.cginc"
        #include "UnityStandardUtils.cginc"

        #define PI 3.1415926
        #define INV_PI 0.31830988618f

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

        float LambertDiffuse(float nl){

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

        float GGXTerm(float nh,float a){
            float a2 = a  * a;
            float d = (nh*a2-nh)*nh + 1;
            return INV_PI * a2 / (d*d + 1e-7f);
        }

        float FresnelTerm(float3 F0,float lh){
            return F0 + (1-F0) * Pow5(1 - lh);
        }
        float FresnelLerpFast(float3 F0,float3 F90,float lh){
            float t = Pow4(1 - lh);
            return lerp(F0,F90,t);
        }

        float4 PBS(float3 diffColor,half3 specColor,float oneMinusReflectivity,float smoothness,
            float3 normal,float3 viewDir,
            UnityLight light,UnityIndirect gi
        ){
            float a = 1- smoothness;
            float a2 = a * a;
            
            float3 l = normalize(light.dir);
            float3 n = normalize(normal);
            float3 v = normalize(viewDir);
            float3 h = normalize(light.dir + v);
            float nh = saturate(dot(n,h));
            float nl = saturate(dot(n,l));
            // nl = smoothstep(0.1,0.12,nl);
            float nv = saturate(dot(n,v));
            float lv = saturate(dot(l,v));
            float lh = saturate(dot(l,h));

            //float diffuseTerm = DisneyDiffuse(nv,nl,lh,a) * nl;
            float diffuseTerm = diffColor * PI * nl;
            float G = SmithJointGGXTerm(nl,nv,a2);
            //float D = NDFBlinnPhongTerm(nh,RoughnessToSpecPower(a));
            float D = GGXTerm(nh,a);
            float F = FresnelTerm(specColor,lh);

            float specTerm = G * D * F * PI * nl;
            specTerm = max(0,specTerm);
            specTerm *= any(specColor)?1:0;

            float surfaceReduction =1 /(a2 * a2+1);
            float grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
            float3 color = diffColor * (gi.diffuse + light.color * diffuseTerm) 
                + specColor * specTerm * light.color 
                + surfaceReduction * gi.specular * FresnelLerpFast(specColor,grazingTerm,nv);
            return float4(color,1);
        }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 n:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Metallic;
            float _Smoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.n = UnityObjectToWorldNormal(v.n);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // kd Diff + ks(F D G)/(4*nl*nv)
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 n = normalize(i.n);
                UnityLight light;
                light.dir = l;
                light.color = _LightColor0;

                UnityIndirect gi = (UnityIndirect)0;
                gi.diffuse = 0.5;//ShadeSH9(float4(n,1));
                gi.specular = 0.1;

                // sample the texture
                fixed4 albedo = tex2D(_MainTex, i.uv);
                float3 specColor;
                float oneMinusReflectivity;
                albedo.rgb = DiffuseAndSpecularFromMetallic(albedo.rgb,_Metallic,specColor,oneMinusReflectivity);

                float4 c = PBS(albedo.rgb,specColor,oneMinusReflectivity,_Smoothness,n,v,light,gi);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, c);
                return c;
            }
            ENDCG
        }
    }
}
