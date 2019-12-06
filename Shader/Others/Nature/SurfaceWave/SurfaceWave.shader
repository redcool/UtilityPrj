// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Transparent/Wave/SurfaceWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color)=(1,1,1,1)
        _NormalMap("NormalMap",2d) = ""{}

        [Header(Color Adjust)]
        [Toggle(_COLOR_ADJUST_ON)]_ColorAdjustOn("调色?",float) = 0
        _Saturate("饱和度",float) = 1
        _Brightness("亮度",float) = 1

        [Header(Clip)]
        [Toggle(_CLIP_ON)]_Clip("开启alpha剔除?",float) = 0
        _Culloff("alpha值",range(0,1)) = 0.5

        [Header(Wave)]
        _WaveMask("水流遮罩(r)",2d) = "white"{}
        _Tile("平铺(xy:1,zw:2)",vector) = (5,5,10,10)
        _Direction("水流方向(xy:1,zw:2)",vector) = (0,1,0,-1)
        
        [Header(Reflection)]
        [Toggle(_REFLECTION_ON)]_RefelctionOn("_RefelctionOn",float) = 0
        _ReflectionTex("环境图",Cube) = ""{}
        _FakeReflectionTex("平面反射图",2d) = "black"{}
        _ReflectionIntensity("反射强度",range(0.01,1)) = 0.2
        _ReflectionMask("反射遮罩(g)",2d) = "white"{}

        [Header(Fresnal)]
        _FresnalWidth("轮廓光宽度",float) = 1

        [Header(VertexWave)]
        [Toggle(_VERTEX_WAVE_ON)]_VertexWave("顶点动画 ?",float) = 0
        _VertexWaveNoiseTex("动画杂点图",2d) = ""{}
        _VertexWaveIntensity("动画强度",float) = 0.1
        _VertexWaveSpeed("动画速度",float) = 1

        [Header(Specular)]
        [Toggle(_SPEC_ON)]_SpecOn("开启高光?",float) = 0
        _SpecPower("高光强度",range(0.001,1)) = 10
        _Glossness("平滑度",range(0,1)) = 1
        _SpecWidth("高光边缘宽度",range(0,1)) = 0.2
    }

    CGINCLUDE
#define UNITY_INSTANCING_BUFFER_START(Props) UNITY_INSTANCING_CBUFFER_START(Props)
#define UNITY_INSTANCING_BUFFER_END(Props) UNITY_INSTANCING_CBUFFER_END
#define ACCESS_INSTANCED_PROP(arr,var) UNITY_ACCESS_INSTANCED_PROP(var)

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 color:COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 normalUV:COLOR;
                float3 worldPos:TEXCOORD2;
                float3 normal:TEXCOORD3;
                float4 screenPos:TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Tile)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Direction)
                UNITY_DEFINE_INSTANCED_PROP(float, _FresnalWidth)
                UNITY_DEFINE_INSTANCED_PROP(float, _VertexWaveIntensity)
                UNITY_DEFINE_INSTANCED_PROP(float, _VertexWaveSpeed)
                UNITY_DEFINE_INSTANCED_PROP(float, _SpecPower)
                UNITY_DEFINE_INSTANCED_PROP(float, _Glossness)
                UNITY_DEFINE_INSTANCED_PROP(float, _SpecWidth)
                #if defined(_CLIP_ON)
                    UNITY_DEFINE_INSTANCED_PROP(float, _Culloff)
                #endif

                #if defined(_REFLECTION_ON)
                    UNITY_DEFINE_INSTANCED_PROP(float, _ReflectionIntensity)
                #endif
                #if defined(_COLOR_ADJUST_ON)
                    UNITY_DEFINE_INSTANCED_PROP(float, _Saturate)
                    UNITY_DEFINE_INSTANCED_PROP(float, _Brightness)
                #endif

            UNITY_INSTANCING_BUFFER_END(Props)

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            sampler2D _WaveMask;

        #if defined(_REFLECTION_ON)
            samplerCUBE _ReflectionTex;
            sampler2D _FakeReflectionTex;
            sampler2D _ReflectionMask;
        #endif

        #if defined(_VERTEX_WAVE_ON)
            sampler2D _VertexWaveNoiseTex;
        #endif


            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o = (v2f)0;
                UNITY_TRANSFER_INSTANCE_ID(v, o); 

                // get instancing props.
                float4 tile = ACCESS_INSTANCED_PROP(Props,_Tile);
                float4 direction = ACCESS_INSTANCED_PROP(Props,_Direction);
                float vertexWaveIntensity = ACCESS_INSTANCED_PROP(Props,_VertexWaveIntensity);
                float vertexWaveSpeed = ACCESS_INSTANCED_PROP(Props,_VertexWaveSpeed);

				// random vertex motion.
#if _VERTEX_WAVE_ON
				float3 n = tex2Dlod(_VertexWaveNoiseTex, float4(o.uv + _Time.xx * vertexWaveSpeed, 0, 1));
				float3 fv = v.color * v.normal * (n) * 0.1 * vertexWaveIntensity;
				o.vertex = UnityObjectToClipPos(v.vertex + fv);
#else
				o.vertex = UnityObjectToClipPos(v.vertex);
#endif

                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalUV = o.uv.xyxy * tile + _Time.xxxx* direction;
                o.normal = v.normal;
                o.screenPos = ComputeScreenPos(o.vertex);


                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        blend one oneMinusSrcAlpha

        Pass
        {
            Tags{ "LightMode"="ForwardBase"}



            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature _VERTEX_WAVE_ON
            #pragma shader_feature _CLIP_ON
            #pragma shader_feature _SPEC_ON
            #pragma shader_feature _REFLECTION_ON
            #pragma shader_feature _COLOR_ADJUST_ON
            #pragma multi_compile_instancing

            

            fixed4 frag (v2f i) : SV_Target
            {
                //for instancing props
                UNITY_SETUP_INSTANCE_ID(i); 
                float4 color = ACCESS_INSTANCED_PROP(Props,_Color);
                float fresnalWidth =  ACCESS_INSTANCED_PROP(Props,_FresnalWidth);
                float specPower = ACCESS_INSTANCED_PROP(Props,_SpecPower);
                float glossness = ACCESS_INSTANCED_PROP(Props,_Glossness);
                float specWidth = ACCESS_INSTANCED_PROP(Props,_SpecWidth);

                //--------------- waveMask
                float waveMask = tex2D(_WaveMask,i.uv).r;

                //float2 uv = i.worldPos.xz;
                float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 h = normalize(l+v);

                float3 n = UnpackNormal(tex2D(_NormalMap,i.normalUV.xy));
                n += UnpackNormal(tex2D(_NormalMap,i.normalUV.zw));
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv + (n.xy * 0.02) * waveMask);

            #if defined(_CLIP_ON)
                clip(col.a - _Culloff);
            #endif

                //-------------- diffuse
				float nl = saturate(dot(worldNormal, l));
                fixed3 diffCol = nl * col.rgb;

                //--------------- fresnal
                float nv = dot(worldNormal,v);
                float invertNV = 1-nv;
                fixed3 fresnal = pow(invertNV ,fresnalWidth);//smoothstep(invertNV,invertNV*0.9,_FresnalWidth);

                //--------------specular
            #if defined(_SPEC_ON)
                float nh = saturate(dot(worldNormal,h));
                float spec = pow(nh,specPower * 128) * glossness;
                spec += smoothstep(spec,spec*0.9,specWidth);
				float3 specCol = spec * _LightColor0.rgb;
                col.rgb += specCol * waveMask;
            #endif

                //--------------- reflection
            #if defined(_REFLECTION_ON)
                float3 r = reflect(-v,worldNormal);
                float3 reflCol = texCUBE(_ReflectionTex,r + n * waveMask );
                reflCol += tex2D(_FakeReflectionTex,i.uv + n.xy * 2 * waveMask);

                float reflectionMask = tex2D(_ReflectionMask,i.uv).g;
                reflCol *= reflectionMask;

                col.rgb = lerp(col.rgb,col.rgb * reflCol,_ReflectionIntensity );
            #endif
                
//return float4(col + specCol,1);
				col.rgb += (diffCol + fresnal) * waveMask;
                col *= _Color;

                //---------------- color
            #if defined(_COLOR_ADJUST_ON)
                col.rgb = lerp(dot(float3(0.2,0.7,0.07),col.rgb),col.rgb,_Saturate);
                col.rgb = lerp(dot(float3(0,0,0),col.rgb),col.rgb,_Brightness);
            #endif
//				return col;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }


    pass{
        Tags{"LightMode"="ShadowCaster"}

        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma shader_feature _VERTEXWAVE_ON
            #pragma multi_compile_instancing

            float4 frag(v2f i):SV_Target{
                return 0;
            }

        ENDCG
    }

    }
}
