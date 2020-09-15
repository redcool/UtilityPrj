// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "TestTerrainInstanced" {
    Properties {
        // used in fallback on old cards & base map
        [HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
        [HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)
    }

    SubShader{
        Pass{
            CGPROGRAM
                #pragma vertex vert
                #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd
                #pragma multi_compile_instancing
                #pragma fragment frag
                #include "UnityCG.cginc"

                #define UNITY_ASSUME_UNIFORM_SCALING
                #define UNITY_DONT_INSTANCE_OBJECT_MATRICES
                #define UNITY_INSTANCED_LOD_FADE

                sampler2D _Control;
                float4 _Control_ST;
                float4 _Control_TexelSize;
                sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
                float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
                sampler2D _MainTex;

                #if defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
                    sampler2D _TerrainHeightmapTexture;
                    sampler2D _TerrainNormalmapTexture;
                    float4    _TerrainHeightmapRecipSize;   // float4(1.0f/width, 1.0f/height, 1.0f/(width-1), 1.0f/(height-1))
                    float4    _TerrainHeightmapScale;       // float4(hmScale.x, hmScale.y / (float)(kMaxHeight), hmScale.z, 0.0f)
                #endif

                UNITY_INSTANCING_BUFFER_START(Terrain)
                    UNITY_DEFINE_INSTANCED_PROP(float4, _TerrainPatchInstanceData) // float4(xBase, yBase, skipScale, ~)
                UNITY_INSTANCING_BUFFER_END(Terrain)

                struct v2f{
                    float4 pos:SV_POSITION;
                    float2 uv:TEXCOORD;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                v2f vert(appdata_full v){
                    UNITY_SETUP_INSTANCE_ID(v);
                    v2f o = (v2f)0;
                    UNITY_TRANSFER_INSTANCE_ID(v,o);

                    #if defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
                        float2 patchVertex = v.vertex.xy;
                        float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);

                        float4 uvscale = instanceData.z * _TerrainHeightmapRecipSize;
                        float4 uvoffset = instanceData.xyxy * uvscale;
                        uvoffset.xy += 0.5f * _TerrainHeightmapRecipSize.xy;
                        float2 sampleCoords = (patchVertex.xy * uvscale.xy + uvoffset.xy);

                        float hm = UnpackHeightmap(tex2Dlod(_TerrainHeightmapTexture, float4(sampleCoords, 0, 0)));
                        v.vertex.xz = (patchVertex.xy + instanceData.xy) * _TerrainHeightmapScale.xz * instanceData.z;  //(x + xBase) * hmScale.x * skipScale;
                        v.vertex.y = hm * _TerrainHeightmapScale.y;
                        v.vertex.w = 1.0f;

                        v.texcoord.xy = (patchVertex.xy * uvscale.zw + uvoffset.zw);
                        v.texcoord3 = v.texcoord2 = v.texcoord1 = v.texcoord;
                    #endif
                    v.tangent.xyz = cross(v.normal, float3(0,0,1));
                    v.tangent.w = -1;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texcoord;
                    return o;
                }

                float4 frag(v2f i):SV_Target{

                    float4 splat_control = tex2D(_Control,i.uv);
                    float2 uvSplat0 = TRANSFORM_TEX(i.uv.xy, _Splat0);
                    float2 uvSplat1 = TRANSFORM_TEX(i.uv.xy, _Splat1);
                    float2 uvSplat2 = TRANSFORM_TEX(i.uv.xy, _Splat2);
                    float2 uvSplat3 = TRANSFORM_TEX(i.uv.xy, _Splat3);
                    float4 mixedDiffuse = (float4)0;
                    mixedDiffuse += splat_control.r * tex2D(_Splat0, uvSplat0);
                    mixedDiffuse += splat_control.g * tex2D(_Splat1, uvSplat1);
                    mixedDiffuse += splat_control.b * tex2D(_Splat2, uvSplat2);
                    mixedDiffuse += splat_control.a * tex2D(_Splat3, uvSplat3);
                    return mixedDiffuse*5;
                }

            ENDCG
        }
    }

}
