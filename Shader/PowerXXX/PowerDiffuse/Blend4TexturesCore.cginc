#if !defined(BLEND_4_TEXTURES_CGINC)
#define BLEND_4_TEXTURES_CGINC

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

#define LIGHTMAP_ON
#define UNITY_SHOULD_SAMPLE_SH

// Original surface shader snippet:
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
SamplerState tex_linear_repeat;

sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
float4 _Control_TexelSize;
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;
float4 _Splat3_ST;
float4 _Color0,_Color1,_Color2,_Color3;

// Texture2D _MainTex;
// float4 _Color;

float _ShininessL0;
float _ShininessL1;
float _ShininessL2;
float _ShininessL3;
float4 _Tiling3;
float4 _SpecDir;
float _GlossIntensity0,_GlossIntensity1;
float _GlossIntensity2,_GlossIntensity3;
float4 _SnowNoiseTile;
float4 _SplatSnowIntensity;
Texture2D _BumpSplat0, _BumpSplat1;
Texture2D _BumpSplat2, _BumpSplat3;

half4 _RainSpecColor;
half4 _RainSpecDir;
half4 _RainTerrainShininess;
half _NormalRange;
half _NormalRange1;
half _NormalRange2;
half _NormalRange3;
half4 _WaveLayerIntensity;
half4 _EnvLayerIntensity;

bool _NormalMapOn;

struct Input {
float2 uv_Control : TEXCOORD0;
float2 uv_Splat0 : TEXCOORD1;
float2 uv_Splat1 : TEXCOORD2;
float2 uv_Splat2 : TEXCOORD3;
float2 uv_Splat3 : TEXCOORD4;

float3 worldPos:TEXCOORD5;
float3 wn:TEXCOORD6; //顶点法线,计算反射

#ifdef _FEATURE_SURFACE_WAVE
    float4 normalUV:TEXCOORD7;
#endif
    float2 fog :TEXCOORD8;

};

void surf (Input IN, inout SurfaceOutput o) {
float4 splat_control = tex2D (_Control, IN.uv_Control);

// #if defined(NORMAL_MAP_ON)
if(_NormalMapOn){
    float3 n1 = splat_control.r * UnpackScaleNormal(_BumpSplat0.Sample(tex_linear_repeat, IN.uv_Splat0),_NormalRange);
    float3 n2 = splat_control.g * UnpackScaleNormal(_BumpSplat1.Sample(tex_linear_repeat, IN.uv_Splat1),_NormalRange1);
    float3 n3 = splat_control.b * UnpackScaleNormal(_BumpSplat2.Sample(tex_linear_repeat, IN.uv_Splat2),_NormalRange2);
    float3 n4 = splat_control.a * UnpackScaleNormal(_BumpSplat3.Sample(tex_linear_repeat, IN.uv_Splat3),_NormalRange3);
    o.Normal = normalize(n1 + n2+n3+n4);
    // IN.wn = o.Normal;
    // o.Normal = length(o.Normal)<0.001f? float3(0,0,0.1):o.Normal;
}
// #endif

float4 lay1 = tex2D (_Splat0, IN.uv_Splat0) * _Color0;
float4 lay2 = tex2D (_Splat1, IN.uv_Splat1)* _Color1;
float4 lay3 = tex2D (_Splat2, IN.uv_Splat2)* _Color2;
float4 lay4 = tex2D (_Splat3, IN.uv_Splat3)* _Color3;

half4 shininess = half4(_ShininessL0,_ShininessL1,_ShininessL2,_ShininessL3);
half4 gloss = float4(_GlossIntensity0,_GlossIntensity1,_GlossIntensity2,_GlossIntensity3);

#ifdef _FEATURE_SNOW
    float4 c = (lay1 * splat_control.r * _SplatSnowIntensity.x + lay2 * splat_control.g * _SplatSnowIntensity.y + lay3 * splat_control.b * _SplatSnowIntensity.z + lay4 * splat_control.a * _SplatSnowIntensity.w);
    SNOW_FRAG_FUNCTION(IN.uv_Control,c,IN.wn,IN.worldPos);
#else
    float4 c = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
    #endif

#ifdef _FEATURE_SURFACE_WAVE
    // 1 apply surface wave or ripple
    half4 originalCol = c;
    WATER_FRAG_TERRAIN(c,IN.normalUV,IN.worldPos,IN.wn,IN.uv_Control,splat_control,IN.uv_Splat0,IN.uv_Splat1,IN.uv_Splat2,IN.uv_Splat3,_Splat0,_Splat1,_Splat2,_Splat3);

    // 2 tint splats color
    float4 tintColor = _WaveColor;
    // #if defined(RIPPLE_ON)
    if(_RippleOn)
    tintColor = _RippleColorTint;
    // #endif
    c = TintTerrainColorByLayers(originalCol,c,envColor,splat_control,_WaveLayerIntensity,_EnvLayerIntensity,tintColor);
    // 3 apply rain splats specular 
    shininess = _RainTerrainShininess;
#endif

o.Alpha = c.a;
o.Albedo = c.rgb;
o.Albedo.rgb = ApplyThunder(c.rgb);

o.Gloss = dot(float4(lay1.a,lay2.a,lay3.a,lay4.a) * gloss,splat_control);
o.Specular = saturate(dot(shininess,normalize(splat_control)));
}


// vertex-to-fragment interpolation data
struct v2f_surf {
float4 pos : SV_POSITION;
float2 uv:TEXCOORD0;
float4 tSpace0 : TEXCOORD1;
float4 tSpace1 : TEXCOORD2;
float4 tSpace2 : TEXCOORD3;
float3 vlight : TEXCOORD4; // ambient/SH/vertexlights
UNITY_LIGHTING_COORDS(5,6)
UNITY_FOG_COORDS(7)
float4 lmap : TEXCOORD8;

float4 normalUV:TEXCOORD9;
float2 fog :TEXCOORD10;
UNITY_VERTEX_INPUT_INSTANCE_ID
};



//for terrain rendering instenced
#if defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
    Texture2D _TerrainHeightmapTexture;
    Texture2D _TerrainNormalmapTexture;
    float4    _TerrainHeightmapRecipSize;   // float4(1.0f/width, 1.0f/height, 1.0f/(width-1), 1.0f/(height-1))
    float4    _TerrainHeightmapScale;       // float4(hmScale.x, hmScale.y / (float)(kMaxHeight), hmScale.z, 0.0f)
#endif

UNITY_INSTANCING_BUFFER_START(Terrain)
    UNITY_DEFINE_INSTANCED_PROP(float4, _TerrainPatchInstanceData) // float4(xBase, yBase, skipScale, ~)
UNITY_INSTANCING_BUFFER_END(Terrain)

// vertex shader
v2f_surf vert_surf (appdata_full v) {
UNITY_SETUP_INSTANCE_ID(v);
v2f_surf o = (v2f_surf)0;
UNITY_TRANSFER_INSTANCE_ID(v,o);

#if defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
    float2 patchVertex = v.vertex.xy;
    float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);

    float4 uvscale = instanceData.z * _TerrainHeightmapRecipSize;
    float4 uvoffset = instanceData.xyxy * uvscale;
    uvoffset.xy += 0.5f * _TerrainHeightmapRecipSize.xy;
    float2 sampleCoords = (patchVertex.xy * uvscale.xy + uvoffset.xy);

    float hm = UnpackHeightmap(_TerrainHeightmapTexture.SampleLevel(tex_linear_repeat, sampleCoords,1));
    v.vertex.xz = (patchVertex.xy + instanceData.xy) * _TerrainHeightmapScale.xz * instanceData.z;  //(x + xBase) * hmScale.x * skipScale;
    v.vertex.y = hm * _TerrainHeightmapScale.y;
    v.vertex.w = 1.0f;

    v.texcoord.xy = (patchVertex.xy * uvscale.zw + uvoffset.zw);
    v.texcoord3 = v.texcoord2 = v.texcoord1 = v.texcoord;

    float3 nor = _TerrainNormalmapTexture.Sample(tex_linear_repeat, sampleCoords, 0).xyz;
    v.normal = 2.0f * nor - 1.0f;

    v.tangent.xyz = cross(v.normal,float3(0,0,1));
    v.tangent.w = -1;
#endif


UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
o.pos = UnityObjectToClipPos (v.vertex);
o.uv = v.texcoord;


float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
float3 worldNormal = UnityObjectToWorldNormal(v.normal);
float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

// #ifndef DYNAMICLIGHTMAP_OFF
//   o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
// #endif
#ifdef LIGHTMAP_ON
    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

// SH/ambient and vertex lights
#if defined(UNITY_SHOULD_SAMPLE_SH)
    float3 shlight = ShadeSH9 (float4(worldNormal,1.0));
    o.vlight = shlight;
#else
    o.vlight = 0.0;
#endif
#ifdef VERTEXLIGHT_ON
    o.vlight += Shade4PointLights (
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    unity_4LightAtten0, worldPos, worldNormal );
#endif // VERTEXLIGHT_ON

    //	HeightFog(v.vertex,o.worldPos.y,o.fog);
// TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
 UNITY_TRANSFER_LIGHTING(o,v.texcoord1.xy); // pass shadow and, possibly, light cookie coordinates to pixel shader

    o.fog = GetHeightFog(worldPos);
UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader

#ifdef _FEATURE_SURFACE_WAVE
    WATER_VERT_FUNCTION(v.texcoord,o.normalUV);
#endif
return o;
}

// fragment shader
float4 frag_surf (v2f_surf IN) : SV_Target {
// prepare and unpack data
Input surfIN;
UNITY_INITIALIZE_OUTPUT(Input,surfIN);
surfIN.uv_Control = TRANSFORM_TEX(IN.uv, _Control);
//surfIN.uv_Control.x =1-surfIN.uv_Control.x;
surfIN.uv_Splat0 = TRANSFORM_TEX(IN.uv, _Splat0);
surfIN.uv_Splat1 = TRANSFORM_TEX(IN.uv, _Splat1);
surfIN.uv_Splat2 = TRANSFORM_TEX(IN.uv, _Splat2);
surfIN.uv_Splat3 = TRANSFORM_TEX(IN.uv, _Splat3);

UnityLight light = GetLight();
float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
float3 worldNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
half3 halfDir = normalize(light.dir + viewDir);
#ifdef UNITY_COMPILER_HLSL
    SurfaceOutput o = (SurfaceOutput)0;
#else
    SurfaceOutput o;
#endif
o.Albedo = 0.0;
o.Emission = 0.0;
o.Specular = 0.0;
o.Alpha = 0.0;
o.Gloss = 0.0;
o.Normal = worldNormal;

// weather code
surfIN.worldPos = worldPos;
surfIN.wn = worldNormal;

#ifdef _FEATURE_SURFACE_WAVE
    surfIN.normalUV = IN.normalUV;
#endif
// call surface function
surf (surfIN, o);
#if defined(LOW_SETTING)
    return LightingOnlyLightmap(o,IN.lmap,light);
#else
    // #if defined(NORMAL_MAP_ON)
    if(_NormalMapOn){
        float3 worldN;
        worldN.x = dot(IN.tSpace0.xyz, o.Normal);
        worldN.y = dot(IN.tSpace1.xyz, o.Normal);
        worldN.z = dot(IN.tSpace2.xyz, o.Normal);
        o.Normal = worldN;
    }
    // #endif
    // compute lighting & shadowing factor
    UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
    
    float4 c = 0;

    float4 lmap = (float4)0;
    float3 sh = (float3)0;

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        lmap = IN.lmap;
    #else
        #if defined(UNITY_SHOULD_SAMPLE_SH)
        sh = 0;//IN.sh;
        #endif
    #endif

    UnityGI gi;
    UnityGIInput giInput = SetupGIInput(light,worldPos,atten,lmap,sh,/*out*/gi);
    
    float3 bakedColor = 0;
    #if defined(LIGHTMAP_ON)
        bakedColor = BlendNightLightmap(IN.lmap);
    #endif

    CalcGI(o, giInput,bakedColor, gi,/*out*/atten);
    // return float4(gi.indirect.diffuse,1);
    // return atten;
    // return float4(o.Albedo * bakedColor,1); // ok

    #if defined(_FEATURE_SURFACE_WAVE)
        gi.light.dir += normalize(_RainSpecDir);
        _SpecColor *= ApplyWeather(_RainSpecColor);
    #endif

    float3 specColor = _SpecColor.rgb * smoothstep(0,0.9,o.Alpha);
    c += LightingBlinn(o,halfDir,gi,atten,specColor);

    
    #if defined(FOG_LINEAR)
        BlendFinalFog(IN.fog,IN.fogCoord,viewDir,worldPos,/**/c);
    #endif

    c.rgb *= DayIntensity(true);
    UNITY_OPAQUE_ALPHA(c.a);
    return c;
#endif
}

#endif //BLEND_4_TEXTURES_CGINC