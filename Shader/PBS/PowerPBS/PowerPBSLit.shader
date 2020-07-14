﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

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

        _HeightMap("Height map(B)",2d) = "white"{}
        _Height("Height",float) = 0
    }

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
            #include "PowerPBSCore.cginc"

            struct appdata{
                float3 vertex:POSITION;
                float4 texcoord:TEXCOORD;
                float4 texcoord1:TEXCOORD1;
                float4 texcoord2:TEXCOORD2;
                float4 texcoord3:TEXCOORD3;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

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

            sampler2D _HeightMap;
            float _Height;


            v2f vert (appdata v)
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
                float3x3 tangentSpace = float3x3(i.t2w0.xyz,i.t2w1.xyz,i.t2w2.xyz);

                float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(worldPos));

                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);

                //parallax(height)
                float4 heightMap = tex2D(_HeightMap,i.uv);
                float height = heightMap.b;
                float3 tangentView = normalize(mul(tangentSpace,v));
                float2 offset = ParallaxOffset1Step(height,_Height,tangentView);
                //float2 offset = float2(height*(_Height) * tangentView.xy);
                float2 uv = i.uv.xy + offset;

                //normal map
                float3 n = UnpackScaleNormal(tex2D(_NormalMap,uv),_NormalScale);
                n.z = sqrt(1 - saturate(dot(n.xy,n.xy)));
                n = mul(tangentSpace,n);//float3(dot(i.t2w0.xyz,n),dot(i.t2w1.xyz,n),dot(i.t2w2.xyz,n));
                n = normalize(n);

                //occlusion
                float4 occlusionMap = tex2D(_OcclusionMap,uv);
                float occlusion = occlusionMap.g * _Occlusion;
                //metallic
                float4 metallicMap = tex2D(_MetallicMap,uv);
                float metallic = metallicMap.r * _Metallic;
                float smoothness = metallicMap.a * _Smoothness;

                
                // calculate gi
                UnityGI gi = CalcGI(l,v,worldPos,n,atten,i.shlmap,smoothness,occlusion);
                // sample the texture
                fixed4 albedo = tex2D(_MainTex, uv);
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
