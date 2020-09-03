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
        _BakedColorMin("_BakedColorMin",range(0,1)) = 0.1
        _BakedColorScale("_BakedColorScale",range(1,10)) = 1

        // [Header(GrassSpecular)]
        // [Toggle(SPEC_ON)]_SpecMaskOn("SpecMask On?",int) = 0
        // [Toggle]_SpecMaskR("Spec Mask R?",int) = 0
        // _SpecMaskMap("SpecMaskMap",2d) = "White"{}
        // _Gloss("_Gloss",range(0,1)) = 0

        [Header(Wind)]
        _WaveSpeed("WaveSpeed",float) = 1
        _GrassWaveIntensity("WaveIntensity",float) = 1

        [Header(Interactive)]
        _PushRadius("Radius",float) = 0.5
        _PushIntensity("Push Intensity",float) = 1
        //_PlayerPos("playerPos",vector) = (0,0,0,0)
        // _GlobalWindDir("Global WindDir",vector)=(1,0,0,0)
        // _GlobalWindIntensity("Global WindIntensity",float)=1
        // _LightmapST("_LightmapST",Vector)=(0,0,0,0)
    
    [Header(WeatherController)]
    //[KeywordEnum(None,Snow,Surface_Wave)]_Feature("Features",float) = 0
    [Toggle(_FEATURE_NONE)]_DisableWeather("Disable Weather ?",int) = 1

    [Header(Snow)]
    // 积雪是否有方向?
    [Toggle(DISABLE_SNOW_DIR)] _DisableSnowDir("Disable Snow Dir ?",float) = 0
    _DefaultSnowRate("Default Snow Rate",float) = 1.5
    //是否使用杂点扰动?
    [Toggle(SNOW_NOISE_MAP_ON)]_SnowNoiseMapOn("SnowNoiseMapOn",float) = 0
    [noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
    _NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0
    
    _SnowDirection("Direction",vector) = (.1,1,0,0)
    _SnowColor("Snow Color",color) = (1,1,1,1)
    _SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
    _SnowTile("tile",vector) = (1,1,1,1)
    _BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
    _ToneMapping("ToneMapping",range(0,1)) = 0
    
    [Space(20)]
    [Header(SurfaceWave)]
    _WaveColor("Color",color)=(1,1,1,1)
    _Tile("Tile",vector) = (5,5,10,10)
    _Direction("Direction",vector) = (0,1,0,-1)
    [noscaleoffset]_WaveNoiseMap("WaveNoiseMap",2d) = "bump"{}
    
    [Header(WaterEdge)]
    _WaveBorderWidth("WaveBorderWidth",range(0,1)) = 0.2
    _DirAngle("DirAngle",range(0,1)) = 0.8
    _WaveIntensity("WaveIntensity",range(0,1)) = 0.8

    [Header(Env Reflection)]
    _EnvTex("Env Tex",Cube) = ""{}
    _EnvColor("Env Color",color) = (1,1,1,1)
    _EnvNoiseMap("Env Noise Map",2d) = ""{}
    _EnvIntensity("Env Intensity",float) = 1
    _EnvTileOffset("Env Tile(xy),Offset(zw)",vector) = (1,1,0.1,0.1)		
    
    [Header(Ripple)]
    [Toggle(RIPPLE_ON)]_RippleOn("RippleOn?",int)=0
    _RippleTex("RippleTex",2d)=""{}
    _RippleScale("RippleScale",range(1,100)) = 1
    _RippleIntensity("RippleIntensity",range(0,1)) = 1
    _RippleColorTint("RippleColorTint",color) = (0.8,0.8,0.8,1)
    _RippleSpeed("RippleSpeed",range(0,2.4)) = 1
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "../NodeLib.cginc"
    #include "../CustomLight.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float2 uv1:TEXCOORD1;
        float4 color:COLOR;
        float3 normal:NORMAL;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    float _GrassWaveIntensity;
    float _WaveSpeed;

    float3 _PlayerPos;
    float _PushRadius;
    float _PushIntensity;

    //float3 _GlobalWindDir;
    //float _GlobalWindIntensity;

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
            #pragma multi_compile_fog
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdbase nodynlightmap nodirlightmap
            #pragma skip_variants DIRECTIONAL_COOKIE POINT_COOKIE SPOT VERTEXLIGHT_ON 
            #pragma multi_compile_instancing
            
            #pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
            // #pragma shader_feature SNOW_NOISE_MAP_ON
            // #pragma shader_feature RIPPLE_ON
            // #pragma multi_compile _ RAIN_REFLECTION

            #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "../NatureLibMacro.cginc"
            #include "../FogLib.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 lmap:TEXCOORD2;
                LIGHTING_COORDS(3,4)
                float3 diff:TEXCOORD5;
                float3 normal:TEXCOORD6;
                float3 worldPos:TEXCOORD7;
                float3 ambient:TEXCOORD8;                
				float2 fog : TEXCOORD9;
                float4 normalUV:TEXCOORD10;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float _ColorScale;
            float _Gloss;
            //float4 _Color;
            sampler2D _SpecMaskMap;
            float _BakedColorMin;
            float _BakedColorScale;

            int _SpecMaskR;
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

                //o.pos = UnityObjectToClipPos( WaveVertex(v,_WaveSpeed,_GrassWaveIntensity) );
                float4 worldPos = WaveVertex(v,_WaveSpeed,_GrassWaveIntensity);
                o.pos = mul(UNITY_MATRIX_VP,worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                #if defined(LIGHTMAP_ON)
                    // float4 lightmapST = UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST);
                    // lightmapST = length(lightmapST) ==0? unity_LightmapST : lightmapST;
                    o.lmap.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif

                TRANSFER_VERTEX_TO_FRAGMENT(o)
      
                //float3 normal = UnityObjectToWorldNormal(v.normal);
                UnityLight light = GetLight();

                float3 normal = UnityObjectToWorldNormal(v.normal);
                float nl = dot(normal,light.dir) * 0.5 + 0.5;
                o.diff = nl;
                o.diff *=  light.color;

                // ambient light
                o.ambient = 0;
                #if defined(VERTEXLIGHT_ON)
                    o.ambient +=  Shade4PointLights (
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0, worldPos.xyz, normal);
                #else
                    o.ambient += _AmbientColor;
                #endif

                o.normal = normal;
                o.worldPos = worldPos.xyz;
				o.fog = GetHeightFog(o.worldPos);
                UNITY_TRANSFER_FOG(o,o.pos);

                #ifdef _FEATURE_SNOW 
                SNOW_VERT_FUNCTION(v.vertex,v.normal,o.normal);
                #endif
                
                #ifdef _FEATURE_SURFACE_WAVE
                WATER_VERT_FUNCTION(v.uv,o.normalUV);
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 tintColor = UNITY_ACCESS_INSTANCED_PROP(Props,_Color);
                clip(col.a - _Cutoff);
                col *= tintColor * _ColorScale;
                // ao 
                fixed atten = LIGHT_ATTENUATION(i);
//return atten;
                //float diff = max(_BaseAO,smoothstep(0.2,0.4,i.diff));
                float4 attenColor = lerp(0.2,1,atten);
                col.rgb *= i.diff * attenColor + i.ambient;

                #if defined(LIGHTMAP_ON)
                    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap.xy);
                    half3 bakedColor = DecodeLightmap(bakedColorTex);
                    bakedColor = max(_BakedColorMin,bakedColor);
// return float4(bakedColor,1);
                    col.rgb *= bakedColor * _BakedColorScale;
                #endif

                // weather code
                #ifdef _FEATURE_SNOW
                SNOW_FRAG_FUNCTION(i.uv,col,i.normal.xyz,i.worldPos);
                #endif

                #if defined(_FEATURE_SURFACE_WAVE)
                WATER_FRAG_FUNCTION_INSTANCE(col,i.normalUV,i.normal,i.uv,i.worldPos,_MainTex,tintColor);
                #endif

                // apply fog
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos ));
				BlendFog(viewDir,i.fog,/*inout*/col.rgb);
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
                
                o.pos = UnityWorldToClipPos( WaveVertex(v,_WaveSpeed,_GrassWaveIntensity) );
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
            
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma skip_variants INSTANCING_ON
            #pragma multi_compile_fwdadd nodynlightmap nodirlightmap
            #pragma skip_variants POINT_COOKIE DIRECTIONAL_COOKIE
            // #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 lmap:TEXCOORD2;
                LIGHTING_COORDS(3,4)
                float3 worldPos:TEXCOORD5;
                float3 normal:TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float _ColorScale;

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

                float3 worldPos = WaveVertex(v,_WaveSpeed,_GrassWaveIntensity);
                o.pos = UnityWorldToClipPos(worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                UNITY_TRANSFER_LIGHTING(o,v.uv.xy);

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
                float3 l = UnityWorldSpaceLightDir(i.worldPos);

                // ao 
                fixed atten = LIGHT_ATTENUATION(i);
                // return atten;
                col *= atten * _LightColor0 * saturate(dot(n,l));

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }


    }
}
