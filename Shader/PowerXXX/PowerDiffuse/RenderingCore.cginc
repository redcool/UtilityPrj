#if !defined(BASE_RENDERING_CGINC)
#define BASE_RENDERING_CGINC

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

#define CAN_VERTEX_WAVE defined(PLANTS) && ! defined(PLANTS_OFF)

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_TexelSize;
half  _Gloss;
half _SpecIntensity;

fixed4 _Color;
sampler2D _BumpMap;
float4 _BumpMap_ST;
float _NormalMapScale;

sampler2D _Illum;
float4 _IllumColor;
fixed _EmissionScale;

float _Cutoff;

struct Input {
    float2 uv_MainTex;
    float2 uv_BumpMap;
    
    float3 worldPos; 
    float3 wn;

    float4 normalUV;
};

void vert(inout appdata_full v, out Input o) {
    UNITY_INITIALIZE_OUTPUT(Input, o);

    // apply wind
    #if CAN_VERTEX_WAVE
    v.vertex = ClampVertexWave(v, _Wave, _AttenField.y,_AttenField.x);
    //v.vertex = Squash(v.vertex);
    #endif

    #ifdef _FEATURE_SNOW 
    SNOW_VERT_FUNCTION(v.vertex,v.normal,o.wn);
    #endif
    
    #ifdef _FEATURE_SURFACE_WAVE
    WATER_VERT_FUNCTION(v.texcoord,o.normalUV);
    #endif
}

void surf (Input IN, inout SurfaceOutput o) {
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

    #ifdef _FEATURE_SNOW
    SNOW_FRAG_FUNCTION(IN.uv_MainTex,c,IN.wn.xyz,IN.worldPos);
    #endif

    #if defined(_FEATURE_SURFACE_WAVE)
    WATER_FRAG_FUNCTION(c,IN.normalUV,IN.wn,IN.uv_MainTex,IN.worldPos);
    #endif

    
    o.Albedo = ApplyThunder(c.rgb);
    o.Alpha = c.a;
    o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap),_NormalMapScale);
    // o.Normal = (UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)) * _NormalMapScale);

    o.Specular = _SpecIntensity;
    o.Gloss = _Gloss;

    o.Emission = ApplyThunder(c.rgb) * tex2D(_Illum, IN.uv_BumpMap).a * _EmissionScale * _IllumColor;
    o.Emission *= InverseDayIntensity(false);//emission Apply DayIntensity
    #if defined (UNITY_PASS_META)
    o.Emission *= _Emission.rrr;
    #endif
}

struct v2f_surf {
    float4 pos : SV_POSITION;
    float4 uv : TEXCOORD0; // _MainTex _BumpMap
    float4 tSpace0 : TEXCOORD1;
    float4 tSpace1 : TEXCOORD2;
    float4 tSpace2 : TEXCOORD3;
    // float3 worldNormal : TEXCOORD4; // wn
    float4 normalUV : TEXCOORD5;
    float4 lmap : TEXCOORD6;
    UNITY_SHADOW_COORDS(7)
    UNITY_FOG_COORDS(8)
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
    float2 fog :TEXCOORD9;
};


// vertex shader
v2f_surf vert_surf (appdata_full v) {
    UNITY_SETUP_INSTANCE_ID(v);
    v2f_surf o;
    UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
    UNITY_TRANSFER_INSTANCE_ID(v,o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    Input customInputData;
    vert (v, customInputData);
    
    o.normalUV = customInputData.normalUV;
    
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
    fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
    o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
    o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
    o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    // SH/ambient and vertex lights
    // #ifndef LIGHTMAP_ON
    //   #if UNITY_SHOULD_SAMPLE_SH
    //     o.sh = 0;
    //     // Approximated illumination from non-important point lights
    //     #ifdef VERTEXLIGHT_ON
    //       o.sh += Shade4PointLights (
    //       unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    //       unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    //       unity_4LightAtten0, worldPos, worldNormal);
    //     #endif
    //     o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    //   #endif
    // #endif // !LIGHTMAP_ON
    o.fog = GetHeightFog(worldPos);

    UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
    UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
    return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
    UNITY_SETUP_INSTANCE_ID(IN);
    float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
    float3 worldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);

    Input surfIN;
    UNITY_INITIALIZE_OUTPUT(Input,surfIN);
    surfIN.uv_MainTex.x = 1.0;
    surfIN.uv_BumpMap.x = 1.0;
    surfIN.worldPos.x = 1.0;
    surfIN.wn.x = 1.0;
    surfIN.uv_MainTex = IN.uv.xy;
    surfIN.uv_BumpMap = IN.uv.zw;
    surfIN.wn = worldNormal;
    surfIN.normalUV = IN.normalUV;
    surfIN.worldPos = worldPos;

    UnityLight light = GetLight();
    
    SurfaceOutput o = (SurfaceOutput)0;
    o.Normal = worldNormal;

    // call surface function
    surf (surfIN, o);
    // alpha test
    #if defined(ALPHA_TEST_ON)
    clip (o.Alpha - _Cutoff);
    #endif
    // compute lighting & shadowing factor
    UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
    fixed4 c = 0;
    fixed3 worldN;
    worldN.x = dot(IN.tSpace0.xyz, o.Normal);
    worldN.y = dot(IN.tSpace1.xyz, o.Normal);
    worldN.z = dot(IN.tSpace2.xyz, o.Normal);
    o.Normal = worldN ;
// return float4(o.Normal,1);
    half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
    half3 halfDir = normalize(light.dir + viewDir);

    float4 lmap = (float4)0;
    float3 sh = (float3)0;

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    lmap = IN.lmap;
    #else
        #if defined(UNITY_SHOULD_SAMPLE_SH)
            sh = 0;
        #endif
    #endif
    UnityGI gi;
    UnityGIInput giInput = SetupGIInput(light,worldPos,atten,lmap,sh,/*out*/gi);
    CalcGI(o, giInput,/*inout*/gi,/*inout*/atten);

    // //-------- testcase
    // return float4(gi.indirect.diffuse,1);
    // return float4(light.dir.xyzx);
    // return float4(o.Normal.xyzx);
    // return LightingSimpleLambert (o, gi);
    // return atten;

    // realtime lighting: call lighting function
    float3 specColor = _SpecColor.rgb * smoothstep(0,0.9,o.Alpha);
    c.rgb += LightingBlinn(o,halfDir,gi,atten,specColor);

    float3 lightDirection = normalize(light.dir.xyz);
    float sunFog =saturate( dot(-viewDir,lightDirection));
    float3 sunFogColor  = lerp(_HeightFogColor,_sunFogColor,pow(sunFog,2));
    // return saturate(pow(IN.fog.y,4));
    
    unity_FogColor.rgb = lerp(sunFogColor, unity_FogColor.rgb, IN.fog.y * IN.fog.y);
    c.rgb= lerp(c.rgb  ,unity_FogColor.rgb, IN.fog.x);
    c.rgb += o.Emission;

    // apply fog
    UNITY_APPLY_FOG(IN.fogCoord, c );
    
    c.rgb *= DayIntensity(true);
    c.a = o.Alpha;
    return c;
}


//--------------------------------- additive pass
void surf_add (Input IN, inout SurfaceOutput o) {
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

    o.Albedo = c.rgb;
    o.Alpha = c.a;
    o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap),_NormalMapScale);
    o.Specular = _SpecIntensity;
    o.Gloss = _Gloss;

    o.Emission = c.rgb * tex2D(_Illum, IN.uv_BumpMap).a * _EmissionScale * _IllumColor;
}
// vertex shader
v2f_surf vert_surf_add (appdata_full v) {
    UNITY_SETUP_INSTANCE_ID(v);
    v2f_surf o;
    UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
    UNITY_TRANSFER_INSTANCE_ID(v,o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    Input customInputData;
    vert (v, customInputData);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
    fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
    o.tSpace0 = fixed4(worldTangent.x, worldBinormal.x, worldNormal.x,worldPos.x);
    o.tSpace1 = fixed4(worldTangent.y, worldBinormal.y, worldNormal.y,worldPos.y);
    o.tSpace2 = fixed4(worldTangent.z, worldBinormal.z, worldNormal.z,worldPos.z);

    UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
    UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
    return o;
}

// fragment shader
fixed4 frag_surf_add (v2f_surf IN) : SV_Target {
    UNITY_SETUP_INSTANCE_ID(IN);
    float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
    float3 worldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
    // prepare and unpack data
    Input surfIN;
    UNITY_INITIALIZE_OUTPUT(Input,surfIN);
    surfIN.uv_MainTex.x = 1.0;
    surfIN.uv_BumpMap.x = 1.0;
    surfIN.worldPos.x = 1.0;
    surfIN.wn.x = 1.0;
    surfIN.uv_MainTex = IN.uv.xy;
    surfIN.uv_BumpMap = IN.uv.zw;
    surfIN.wn = worldNormal;
    #ifndef USING_DIRECTIONAL_LIGHT
        fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
    #else
        fixed3 lightDir = _WorldSpaceLightPos0.xyz;
    #endif
    SurfaceOutput o = (SurfaceOutput)0;
    o.Normal = worldNormal;

    // call surface function
    surf_add (surfIN, o);

    // alpha test
    #if defined(ALPHA_TEST_ON)
    clip (o.Alpha - _Cutoff);
    #endif

    UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
    fixed4 c = 0;
    fixed3 worldN;
    worldN.x = dot(IN.tSpace0.xyz, o.Normal);
    worldN.y = dot(IN.tSpace1.xyz, o.Normal);
    worldN.z = dot(IN.tSpace2.xyz, o.Normal);
    o.Normal = worldN;

    // Setup lighting environment
    UnityGI gi;
    UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
    gi.indirect.diffuse = 0;
    gi.indirect.specular = 0;
    gi.light.color = _LightColor0.rgb;
    gi.light.dir = lightDir;
    gi.light.color *= atten;
    c += LightingSimpleLambert (o, gi);
    c.a = 0.0;
    UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
    UNITY_OPAQUE_ALPHA(c.a);
    return c;
}

#endif //BASE_RENDERING_CGINC