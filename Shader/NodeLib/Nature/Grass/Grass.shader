// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Nature/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _ColorScale("ColorScale",range(0,3)) = 1
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        _BaseAO("Base Ao",range(0,2)) = 1
        _ShadowColor("ShadowColor",color) = (1,1,1,1)

        [Header(GrassSpecular)]
        [Toggle(SPEC_ON)]_SpecMaskOn("SpecMask On?",int) = 0
        [Toggle]_SpecMaskR("Spec Mask R?",int) = 0
        _SpecMaskMap("SpecMaskMap",2d) = "White"{}
        _Gloss("_Gloss",range(0,1)) = 0

        [Header(Wind)]
        _WaveSpeed("WaveSpeed",float) = 1
        _WaveIntensity("WaveIntensity",float) = 1

        [Header(Interactive)]
        _PushRadius("Radius",float) = 0.5
        _PushIntensity("Push Intensity",float) = 1
        //_PlayerPos("playerPos",vector) = (0,0,0,0)
        // _GlobalWindDir("Global WindDir",vector)=(1,0,0,0)
        // _GlobalWindIntensity("Global WindIntensity",float)=1
        // _LightmapST("_LightmapST",Vector)=(0,0,0,0)

    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "../NodeLib.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float2 uv1:TEXCOORD1;
        float4 color:COLOR;
        float3 normal:NORMAL;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    float _WaveIntensity;
    float _WaveSpeed;

    float3 _PlayerPos;
    float _PushRadius;
    float _PushIntensity;

    float3 _GlobalWindDir;
    float _GlobalWindIntensity;
    float _BaseAO;

    float3 CalcForce(float3 pos,float2 uv,float3 color){
        //---interactive
        float3 dir = pos - _PlayerPos;
        
        float dist = length(dir);
        float circle = saturate(_PushRadius - dist);
        float atten = uv.y * circle * color * _PushIntensity;

        dir.xz = normalize(dir.xz)*0.5;
        dir.y = -0.5;
        return dir * saturate(atten);
    }


    float4 WaveVertex(appdata v,float waveSpeed,float waveIntensity){
        float4 pos = mul(unity_ObjectToWorld,v.vertex);

        float2 timeOffset = _Time.y * waveSpeed;
        float2 uv = pos.xz + timeOffset;

        float noise = 0;
        Unity_GradientNoise_float(uv,1,noise);
        noise -= 0.5;
        noise = noise * v.uv.y * v.color.x * 0.2 * waveIntensity ;
        
        pos.x += noise;
        pos.xyz += CalcForce(pos.xyz,v.uv,v.color);
        //apply weather
        float3 windDir = _GlobalWindDir * _GlobalWindIntensity;
        pos.xyz += noise * 0.4 * windDir;

        //return mul(unity_WorldToObject,pos);
        return pos;
    }
    ENDCG

    SubShader
    {
        LOD 100
        cull off

        Pass
        {
            Tags {"Queue"="AlphaTest" "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            // #pragma multi_compile_fog
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdbase 
            #pragma multi_compile_instancing
            #pragma multi_compile _ SPEC_ON

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 lmap:TEXCOORD2;
                // UNITY_SHADOW_COORDS(3)
                SHADOW_COORDS(3)
                float3 diff:TEXCOORD4;
                float3 normal:TEXCOORD5;
                float3 worldPos:TEXCOORD6;
                float3 ambient:TEXCOORD7;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float _ColorScale;
            float _Gloss;
            //float4 _Color;
            sampler2D _SpecMaskMap;
            int _SpecMaskR;
            float4 _ShadowColor;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				//UNITY_DEFINE_INSTANCED_PROP(float4,_PlayerPos)
                UNITY_DEFINE_INSTANCED_PROP(float4, _LightmapST)
            UNITY_INSTANCING_BUFFER_END(Props)


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                //o.pos = UnityObjectToClipPos( WaveVertex(v,_WaveSpeed,_WaveIntensity) );
                float4 worldPos = WaveVertex(v,_WaveSpeed,_WaveIntensity);
                o.pos = mul(UNITY_MATRIX_VP,worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                #if defined(LIGHTMAP_ON)
                    // float4 lightmapST = UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST);
                    // lightmapST = length(lightmapST) ==0? unity_LightmapST : lightmapST;
                    o.lmap.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif

                //UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o,o.pos);
                //float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = length(_WorldSpaceLightPos0.xyz) > 0 ? _WorldSpaceLightPos0.xyz : float3(0.1,.35,0.02);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float nl = dot(normal,lightDir) * 0.5 + 0.5;
                o.diff = nl * _LightColor0.rgb;//smoothstep(0,.32,nl);

                // ambient light
                o.ambient = 0;
                #if defined(VERTEXLIGHT_ON)
                    o.ambient +=  Shade4PointLights (
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0, worldPos.xyz, normal);
                #else
                    o.ambient += ShadeSH9(float4(normal,1));
                #endif

                o.normal = normal;
                o.worldPos = worldPos.xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff);
                col *= UNITY_ACCESS_INSTANCED_PROP(Props,_Color) * _ColorScale;
                
                // ao 
                fixed atten = SHADOW_ATTENUATION(i);
//return atten;
                //float diff = max(_BaseAO,smoothstep(0.2,0.4,i.diff));
                float4 attenColor = lerp(UNITY_LIGHTMODEL_AMBIENT * _BaseAO,1,atten);
                col.rgb *= i.diff * attenColor + i.ambient;

                #if defined(LIGHTMAP_ON)
                    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap.xy);
                    half3 bakedColor = DecodeLightmap(bakedColorTex);
//return float4(bakedColor,1);
                    col.rgb *= bakedColor;
                #endif
                
                //Specular
                #if defined(SPEC_ON)
                    float4 specMaskMap = tex2D(_SpecMaskMap,i.uv);
                    float specMask = _SpecMaskR? specMaskMap.r : specMaskMap.a;

                    float3 n = normalize(i.normal);
                    float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                    float3 h = normalize(l+v);
                    float spec = pow(dot(n,h),_Gloss * 128);
                    col += spec * specMask;
                #endif

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Cutoff;

            struct v2f { 
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                
                o.pos = UnityWorldToClipPos( WaveVertex(v,_WaveSpeed,_WaveIntensity) );
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a- _Cutoff);

                SHADOW_CASTER_FRAGMENT(i)
                
            }
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            ZWrite Off Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdadd 
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 lmap:TEXCOORD2;
                // UNITY_SHADOW_COORDS(3)
                SHADOW_COORDS(3)
                float3 worldPos:TEXCOORD4;
                float3 normal:TEXCOORD5;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float _ColorScale;
            //float4 _Color;
            float4 _LightColor0;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				//UNITY_DEFINE_INSTANCED_PROP(float4,_PlayerPos)
                UNITY_DEFINE_INSTANCED_PROP(float4, _LightmapST)
            UNITY_INSTANCING_BUFFER_END(Props)

            float CalcAtten(float3 worldPos,out float3 lightDir){
                if(_WorldSpaceLightPos0.w == 0){
                    lightDir = normalize(_WorldSpaceLightPos0);
                    return 1;
                }else{
                    lightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
                    float dist = length(_WorldSpaceLightPos0.xyz - worldPos);
                    return 1/(dist*+dist);
                }
            }

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 worldPos = WaveVertex(v,_WaveSpeed,_WaveIntensity);
                o.pos = UnityWorldToClipPos(worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o,o.pos);
                o.worldPos = worldPos;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff);

                col *= UNITY_ACCESS_INSTANCED_PROP(Props,_Color) * _ColorScale;
                
                float3 n = normalize(i.normal);
                float3 l = (float3)0;
                // ao 
                fixed atten =  CalcAtten(i.worldPos,l);
                col *= atten * _LightColor0 * saturate(dot(n,l));

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }


    }
}
