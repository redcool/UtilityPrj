// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "T4MShaders/Specular/T4M 4 Textures Spec" {
  Properties {
    [Toggle(SPLAT_NORMAL_ON)] _Is_Normal("_Is_Normal ?",float) = 0

    [Header(Specular)]
    _SpecDir("Specular Direction",Vector)=(0,0,0,0)
    _SpecColor ("Specular Color(RGB); diff(A)", Color) = (1, 1, 1, 1)

    // [Toggle]_CustomLightOn("Custom Light?",int)=0
    // _LightDir("Light Dir",vector) = (0,1,0,0)
    // _LightColor("Light Color",color) = (0,0,0,1)

    [Header(Splat0)]
    _Splat0 ("Layer 1", 2D) = "white" {}
		[NoScaleOffset]_BumpSplat0 ("Layer1Normalmap", 2D) = "bump" {}
		_NormalRange("NormalRange",Range(0.1,2))=1
    _ShininessL0 ("Layer1Shininess", Range (0.03, 1)) = 0.078125
    _GlossIntensity0("_GlossIntensity0",Range (0,10)) = 1

    [Header(Splat1)]
    _Splat1 ("Layer 2", 2D) = "white" {}
    [NoScaleOffset]_BumpSplat1 ("Layer2Normalmap", 2D) = "bump" {}
    _NormalRange1("NormalRange1",Range(0.1,2))=1
    _ShininessL1 ("Layer2Shininess", Range (0.03, 1)) = 0.078125
    _GlossIntensity1("_GlossIntensity1",range(0,10)) = 1

    [Header(Splat2)]
    _Splat2 ("Layer 3", 2D) = "white" {}
    [NoScaleOffset]_BumpSplat2 ("Layer3Normalmap", 2D) = "bump" {}
    _NormalRange2("NormalRange2",Range(0.1,2))=1
    _ShininessL2 ("Layer3Shininess", Range (0.03, 10)) = 0.078125
	  _GlossIntensity2("_GlossIntensity3",range(0,10)) = 1
    
    [Header(Splat3)]
    _Splat3 ("Layer 4", 2D) = "white" {}
    [NoScaleOffset]_BumpSplat3 ("Layer4Normalmap", 2D) = "bump" {}
    _NormalRange3("NormalRange3",Range(0.1,2))=1
    _ShininessL3 ("Layer4Shininess", Range (0.03, 1)) = 0.078125
	  _GlossIntensity3("_GlossIntensity4",range(0,10)) = 1
	
    [Header(ControlMap)]
    // _Tiling3("_Tiling4 x/y", Vector)=(1,1,0,0)
    _Control ("Control (RGBA)", 2D) = "white" {}
    _MainTex ("Never Used", 2D) = "white" {}
    
    
    [Header(Snow)] 
    // 积雪是否有方向?
    [Toggle(DISABLE_SNOW_DIR)] _DisableSnowDir("Disable Snow Dir ?",float) = 0
    _DefaultSnowRate("Default Snow Rate",float) = 1.5
    //是否使用杂点扰动?
    [Toggle(SNOW_NOISE_MAP_ON)]_SnowNoiseMapOn("SnowNoiseMapOn",float) = 0
    [noscaleoffset]_SnowNoiseMap("SnowNoiseMap",2d) = "bump"{}
    _NoiseDistortNormalIntensity("NoiseDistortNormalIntensity",range(0,1)) = 0

    _SnowDirection("Direction",vector) = (1,0,0,0)
    _SnowColor("Snow Color",color) = (1,1,1,1)
    _SnowAngleIntensity("SnowAngleIntensity",range(0.1,1)) = 1
    _SnowTile("tile",vector) = (1,1,1,1)
    _BorderWidth("BorderWidth",range(-0.2,0.4)) = 0.01
    _ToneMapping("ToneMapping",range(0,1)) = 0
    _SplatSnowIntensity("积雪分层强度",vector) = (1,1,1,1)

    [Space(10)]
    [Header(Rain Specular)]
    _RainSpecDir("Rain Specular Direction",Vector)=(1,1,0,0)
    _RainSpecColor ("Rain Specular Color(RGB); diff(A)", Color) = (1, 1, 1, 1)
    _RainTerrainShininess("RainTerrainShininess",vector)=(1,1,1,1)

    [Space(20)]
    [Header(SurfaceWave)]
    _WaveLayerIntensity("流水(涟漪)分层强度",vector) = (1,1,1,1)
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
    _EnvLayerIntensity("环境反射分层强度",vector) = (1,1,1,1)

    [Header(Ripple)]
    [Toggle(RIPPLE_ON)]_RippleOn("RippleOn?",int) = 0
    _RippleTex("RippleTex",2d)=""{}
    _RippleScale("RippleScale",range(1,100)) = 1
    _RippleIntensity("RippleIntensity",range(0,1)) = 1
    _RippleColorTint("RippleColorTint",color) = (0.8,0.8,0.8,1)
    _RippleSpeed("RippleSpeed",range(0,2.4)) = 1
	[Header(Daytime)]
	[Toggle]_DaytimeOn("Daytime On?",int) = 0
  }
  
  SubShader {
    Tags {
      "SplatCount" = "4"
      "RenderType" = "Opaque"
    }

    // ------------------------------------------------------------
    // Surface shader code generated out of a CGPROGRAM block:
    

    // ---- forward rendering base pass:
    Pass {
      Name "FORWARD"
      Tags { "LightMode" = "ForwardBase" }
      
      CGPROGRAM
      // compile directives
      #pragma target 3.0
      #pragma vertex vert_surf
      #pragma fragment frag_surf
      #pragma exclude_renderers xbox360 ps3
      #pragma multi_compile_fog
      #pragma multi_compile_fwdbase
      #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
      // #pragma skip_variants POINT POINT_COOKIE SHADOWS_SCREEN VERTEXLIGHT_ON FOG_EXP FOG_EXP2 INSTANCING_ON
      // #pragma skip_variants  DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON  LIGHTMAP_SHADOW_MIXING SHADOWS_SCREEN SHADOWS_SHADOWMASK 
    

      #pragma multi_compile _FEATURE_NONE _FEATURE_SNOW _FEATURE_SURFACE_WAVE
      #pragma shader_feature SNOW_NOISE_MAP_ON
      #pragma shader_feature DISABLE_SNOW_DIR
      #pragma shader_feature RIPPLE_ON
	    #pragma shader_feature SPLAT_NORMAL_ON
      #pragma multi_compile _ RAIN_REFLECTION
	  //#if !defined(SPLAT_NORMAL_ON)
	//  #else
	 // #endif
      #include "HLSLSupport.cginc"
	    #include "Assets/Game/GameRes/Shader/PWIM_CG.cginc"
      #include "UnityShaderVariables.cginc"
	    //#include "Assets/Game/GameRes/Shader/PWIM_CG.cginc"
      // Surface shader code generated based on:
      // writes to per-pixel normal: no
      // writes to emission: no
      // needs world space reflection vector: no
      // needs world space normal vector: no
      // needs screen space position: no
      // needs world space position: no
      // needs view direction: no
      // needs world space view direction: no
      // needs world space position for lighting: no
      // needs world space view direction for lighting: YES
      // needs world space view direction for lightmaps: no
      // needs vertex color: no
      // needs VFACE: no
      // passes tangent-to-world matrix to pixel shader: no
      // reads from normal: no
      // 4 texcoords actually used
      //   float2 _Control
      //   float2 _Splat0
      //   float2 _Splat1
      //   float2 _Splat2
      //#define UNITY_PASS_FORWARDBASE
      #include "UnityCG.cginc"
      #include "Lighting.cginc"
      #include "AutoLight.cginc"
      #include "UnityStandardUtils.cginc"

      #define TERRAIN_WEATHER

      #include "../../NatureLibMacro.cginc"
      #include "Assets/Game/GameRes/Shader/Weather/Nature/CustomLight.cginc"

      #define INTERNAL_DATA
      #define WorldReflectionVector(data,normal) data.worldRefl
      #define WorldNormalVector(data,normal) normal

      #define LIGHTMAP_OFF
      #define UNITY_SHOULD_SAMPLE_SH

      // Original surface shader snippet:
      #ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
      #endif

      //#pragma surface surf T4MBlinnPhong
      //#pragma exclude_renderers xbox360 ps3

      sampler2D _Control;
      sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
      fixed _ShininessL0;
      fixed _ShininessL1;
      fixed _ShininessL2;
      fixed _ShininessL3;
      float4 _Tiling3;
      fixed4 _SpecDir;
      fixed _GlossIntensity0,_GlossIntensity1;
      fixed _GlossIntensity2,_GlossIntensity3;
      fixed4 _SnowNoiseTile;
      float4 _SplatSnowIntensity;
	    sampler2D _BumpSplat0, _BumpSplat1;
	    sampler2D _BumpSplat2, _BumpSplat3;

      half4 _RainSpecColor;
      half4 _RainSpecDir;
      half4 _RainTerrainShininess;
      half3 _SunFogDir;
      half _NormalRange;
      half _NormalRange1;
      half _NormalRange2;
      half _NormalRange3;
      half4 _WaveLayerIntensity;
      half4 _EnvLayerIntensity;
/*
      inline fixed4 LightingT4MBlinnPhong (SurfaceOutput s, UnityLight light, fixed3 viewDir, fixed atten)
      {
        half3 lightDir = normalize(light.dir + _SpecDir);
        half4 specColor = _SpecColor;

        #if defined(_FEATURE_SURFACE_WAVE)
          lightDir = _RainSpecDir;
          specColor *= ApplyWeather(_RainSpecColor);
        #endif
        // specColor.a *= 0.03;

        fixed diff = max (0, dot (s.Normal, lightDir));
        
        float h = normalize(viewDir + lightDir);
        fixed nh = max (0, dot (normalize(s.Normal), normalize(h + lightDir.xyz)));
        fixed spec = pow (nh, s.Specular*128) * s.Gloss;
        
        fixed4 c;
        c.rgb = (s.Albedo * light.color.rgb * diff + _SpecColor.rgb * spec) * (atten*2);
        
        c.a = 0.0;
        return c;
      }
*/
      struct Input {
        float2 uv_Control : TEXCOORD0;
        float2 uv_Splat0 : TEXCOORD1;
        float2 uv_Splat1 : TEXCOORD2;
        float2 uv_Splat2 : TEXCOORD3;
        float2 uv_Splat3 : TEXCOORD4;

        float3 worldPos:TEXCOORD5;
        float3 wn:TEXCOORD6;
        
        #ifdef _FEATURE_SURFACE_WAVE
          float4 normalUV:TEXCOORD7;
        #endif
		    float2 fog :TEXCOORD8;

      };
      
      void surf (Input IN, inout SurfaceOutput o) {
        fixed4 splat_control = tex2D (_Control, IN.uv_Control);
        
        #if defined(SPLAT_NORMAL_ON)
          float3 n1 = splat_control.r * UnpackScaleNormal(tex2D(_BumpSplat0, IN.uv_Splat0),_NormalRange);
          float3 n2 = splat_control.g * UnpackScaleNormal(tex2D(_BumpSplat1, IN.uv_Splat1),_NormalRange1);
          float3 n3 = splat_control.b * UnpackScaleNormal(tex2D(_BumpSplat2, IN.uv_Splat2),_NormalRange2);
          float3 n4 = splat_control.a * UnpackScaleNormal(tex2D(_BumpSplat3, IN.uv_Splat3),_NormalRange3);
          o.Normal = normalize(n1 + n2+n3+n4);
          // o.Normal = length(o.Normal)<0.001f? float3(0,0,0.1):o.Normal;
        #endif

        fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);  
        fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
        fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
        fixed4 lay4 = tex2D (_Splat3, IN.uv_Splat3);

        half4 shininess = half4(_ShininessL0,_ShininessL1,_ShininessL2,_ShininessL3);
        half4 gloss = float4(_GlossIntensity0,_GlossIntensity1,_GlossIntensity2,_GlossIntensity3);

        #ifdef _FEATURE_SNOW
          fixed4 c = (lay1 * splat_control.r * _SplatSnowIntensity.x + lay2 * splat_control.g * _SplatSnowIntensity.y + lay3 * splat_control.b * _SplatSnowIntensity.z + lay4 * splat_control.a * _SplatSnowIntensity.w);
          SNOW_FRAG_FUNCTION(IN.uv_Control,c,IN.wn,IN.worldPos);
        #else
          fixed4 c = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
	      #endif
        
        #ifdef _FEATURE_SURFACE_WAVE
          half4 originalCol = c;
          WATER_FRAG_TERRAIN(c,IN.normalUV,IN.worldPos,IN.wn,IN.uv_Control,splat_control,IN.uv_Splat0,IN.uv_Splat1,IN.uv_Splat2,IN.uv_Control*_Tiling3.xy,_Splat0,_Splat1,_Splat2,_Splat3);
          c = TintTerrainColorByLayers(originalCol,c,envColor,splat_control,_WaveLayerIntensity,_EnvLayerIntensity,_RippleColorTint);

          shininess = _RainTerrainShininess;
        #endif
		
        o.Alpha = c.a;
        o.Albedo.rgb = ApplyThunder(c.rgb);

        o.Gloss = dot(float4(lay1.a,lay2.a,lay3.a,lay4.a) * gloss,splat_control);
        o.Specular = saturate(dot(shininess,normalize(splat_control)));
        // o.Gloss = (lay1.a * splat_control.r + lay2.a * splat_control.g + lay3.a * splat_control.b + lay4.a * splat_control.a);
        //o.Specular = (shininess.x * splat_control.r + shininess.y * splat_control.g + shininess.z * splat_control.b + shininess.w * splat_control.a);
      }
      

      // vertex-to-fragment interpolation data
      struct v2f_surf {
        float4 pos : SV_POSITION;
        float2 uv:TEXCOORD0;
        fixed4 tSpace0 : TEXCOORD1;
        fixed4 tSpace1 : TEXCOORD2;
        fixed4 tSpace2 : TEXCOORD3;
        fixed3 vlight : TEXCOORD4; // ambient/SH/vertexlights
        SHADOW_COORDS(5)
        UNITY_FOG_COORDS(6)
        float4 lmap : TEXCOORD7;

        float4 normalUV:TEXCOORD8;
        float2 fog :TEXCOORD9;
      };

      float4 _Control_ST;
      float4 _Splat0_ST;
      float4 _Splat1_ST;
      float4 _Splat2_ST;
      float4 _Splat3_ST;

      // vertex shader
      v2f_surf vert_surf (appdata_full v) {
        v2f_surf o;
        UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
        o.pos = UnityObjectToClipPos (v.vertex);
        o.uv = v.texcoord;

        //传递,切线空间变换阵
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
        fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
        fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
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
        TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader

		    HeightFog(v.vertex,worldPos.y,o.fog);
        UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader

        #ifdef _FEATURE_SURFACE_WAVE
          WATER_VERT_FUNCTION(v.texcoord,o.normalUV);
        #endif
        return o;
      }

      // fragment shader
      fixed4 frag_surf (v2f_surf IN) : SV_Target {
        // prepare and unpack data
        Input surfIN;
        UNITY_INITIALIZE_OUTPUT(Input,surfIN);
        surfIN.uv_Control = TRANSFORM_TEX(IN.uv, _Control);
        surfIN.uv_Splat0 = TRANSFORM_TEX(IN.uv, _Splat0);
        surfIN.uv_Splat1 = TRANSFORM_TEX(IN.uv, _Splat1);
        surfIN.uv_Splat2 = TRANSFORM_TEX(IN.uv, _Splat2);
        surfIN.uv_Splat3 = TRANSFORM_TEX(IN.uv, _Splat3);

        UnityLight light = GetLight();
        float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
        float3 worldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
        half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
        half3 halfDir = SafeNormalize(light.dir + viewDir);
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
// return float4(o.Normal,1);
        // 使用 surf里的法线
        #if defined(SPLAT_NORMAL_ON)
        fixed3 worldN;
        worldN.x = dot(IN.tSpace0.xyz, o.Normal);
        worldN.y = dot(IN.tSpace1.xyz, o.Normal);
        worldN.z = dot(IN.tSpace2.xyz, o.Normal);
        o.Normal = worldN;
        #endif
		// return float4(o.Normal,1);
    // o.Normal = worldNormal;
        // compute lighting & shadowing factor
        UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)

        fixed4 c = 0;

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
        // realtime lighting: call lighting function
        #if defined(_FEATURE_SURFACE_WAVE)
          gi.light.dir = _RainSpecDir;
          _SpecColor *= ApplyWeather(_RainSpecColor);
        #endif

        float3 specColor = _SpecColor.rgb * smoothstep(0,0.9,o.Alpha);
        c += LightingBlinn(o,halfDir,gi,atten,specColor);

		    float3 lightDirection = normalize(_SunFogDir.xyz);
				float sunFog =saturate( dot(-viewDir,lightDirection));
				float3 sunFogColor  = lerp(_HeightFogColor,_sunFogColor,pow(sunFog,2));
				unity_FogColor.rgb = lerp(sunFogColor, unity_FogColor.rgb, IN.fog.y*IN.fog.y);
				c.rgb= lerp(c.rgb  ,unity_FogColor.rgb, IN.fog.x);
        UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
		    c.rgb *= DayIntensity(true);
        UNITY_OPAQUE_ALPHA(c.a);
        return c;
      }

      ENDCG

    }

    // ---- forward rendering additive lights pass:
    	Pass {
      		Name "FORWARD"
      		Tags { "LightMode" = "ForwardAdd" }
      		ZWrite Off Blend One One

      CGPROGRAM
      // compile directives
      #pragma vertex vert_surf
      #pragma fragment frag_surf
      #pragma exclude_renderers xbox360 ps3
      #pragma multi_compile_fog
      #pragma multi_compile_fwdadd
      #include "HLSLSupport.cginc"
      #include "UnityShaderVariables.cginc"
      // Surface shader code generated based on:
      // writes to per-pixel normal: no
      // writes to emission: no
      // needs world space reflection vector: no
      // needs world space normal vector: no
      // needs screen space position: no
      // needs world space position: no
      // needs view direction: no
      // needs world space view direction: no
      // needs world space position for lighting: no
      // needs world space view direction for lighting: YES
      // needs world space view direction for lightmaps: no
      // needs vertex color: no
      // needs VFACE: no
      // passes tangent-to-world matrix to pixel shader: no
      // reads from normal: no
      // 4 texcoords actually used
      //   float2 _Control
      //   float2 _Splat0
      //   float2 _Splat1
      //   float2 _Splat2
      #define UNITY_PASS_FORWARDADD
      #include "UnityCG.cginc"
      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      #define INTERNAL_DATA
      #define WorldReflectionVector(data,normal) data.worldRefl
      #define WorldNormalVector(data,normal) normal

      // Original surface shader snippet:
      #line 21 ""
      #ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
      #endif

      //#pragma surface surf T4MBlinnPhong
      //#pragma exclude_renderers xbox360 ps3

      sampler2D _Control;
      sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
      fixed _ShininessL0;
      fixed _ShininessL1;
      fixed _ShininessL2;
      fixed _ShininessL3;
      float4 _Tiling3;
      fixed4 _SpecDir;

      inline fixed4 LightingT4MBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
      {
          float3 h = normalize(lightDir + viewDir);

        	fixed diff = max (0, dot (s.Normal, lightDir));
        	//fixed nh = max (0, dot (s.Normal, halfDir));
        	fixed nh = max (0, dot (normalize(s.Normal),h));
        	fixed spec = pow (nh, s.Specular*128) * s.Gloss;
        
        	fixed4 c;
        	//c.rgb = (s.Albedo * _LightColor0.rgb * diff + _SpecColor.rgb * spec) * (atten*2);
        	c.rgb = (s.Albedo* _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb*spec)*(atten);
        	c.a = s.Alpha;
        	return c;
      }

      struct Input {
        	float2 uv_Control : TEXCOORD0;
        	float2 uv_Splat0 : TEXCOORD1;
        	float2 uv_Splat1 : TEXCOORD2;
        	float2 uv_Splat2 : TEXCOORD3;
        	float2 uv_Splat3 : TEXCOORD4;
      };
      
      void surf (Input IN, inout SurfaceOutput o) {
        	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
        
        	fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);
        	fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
        	fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
        	fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);
        	o.Alpha = 0.0;
        	o.Albedo.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
        	o.Gloss = (lay1.a * splat_control.r + lay2.a * splat_control.g + lay3.a * splat_control.b + lay4.a * splat_control.a);
        	o.Specular = (_ShininessL0 * splat_control.r + _ShininessL1 * splat_control.g + _ShininessL2 * splat_control.b + _ShininessL3 * splat_control.a);
      }


      // vertex-to-fragment interpolation data
      struct v2f_surf {
         float4 pos : SV_POSITION;
         float4 pack0 : TEXCOORD0; // _Control _Splat0
         float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
         half3 worldNormal : TEXCOORD2;
         float3 worldPos : TEXCOORD3;
         SHADOW_COORDS(4)
         UNITY_FOG_COORDS(5)
      };
      float4 _Control_ST;
      float4 _Splat0_ST;
      float4 _Splat1_ST;
      float4 _Splat2_ST;

      // vertex shader
      v2f_surf vert_surf (appdata_full v) {
         v2f_surf o;
         UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
         o.pos = UnityObjectToClipPos (v.vertex);
         o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
         o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
         o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
         o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
         float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
         fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
         o.worldPos = worldPos;
         o.worldNormal = worldNormal;

         TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
         UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
         return o;
      }

      // fragment shader
      fixed4 frag_surf (v2f_surf IN) : SV_Target {
         // prepare and unpack data
         Input surfIN;
         UNITY_INITIALIZE_OUTPUT(Input,surfIN);
         surfIN.uv_Control.x = 1.0;
         surfIN.uv_Splat0.x = 1.0;
         surfIN.uv_Splat1.x = 1.0;
         surfIN.uv_Splat2.x = 1.0;
         surfIN.uv_Splat3.x = 1.0;
         surfIN.uv_Control = IN.pack0.xy;
         surfIN.uv_Splat0 = IN.pack0.zw;
         surfIN.uv_Splat1 = IN.pack1.xy;
         surfIN.uv_Splat2 = IN.pack1.zw;
         float3 worldPos = IN.worldPos;
         #ifndef USING_DIRECTIONAL_LIGHT
           fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
         #else
           fixed3 lightDir = _WorldSpaceLightPos0.xyz;
         #endif
         fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
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
         fixed3 normalWorldVertex = fixed3(0,0,1);
         o.Normal = IN.worldNormal;
         normalWorldVertex = IN.worldNormal;

         // call surface function
         surf (surfIN, o);
         UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
         fixed4 c = 0;
         c += LightingT4MBlinnPhong (o, lightDir, worldViewDir, atten);
         c.a = 0.0;
         UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
         UNITY_OPAQUE_ALPHA(c.a);
         return c;
      }

      ENDCG

    }

    //	// ---- meta information extraction pass:
    //	Pass {
      //		Name "Meta"
      //		Tags { "LightMode" = "Meta" }
      //		Cull Off

      //CGPROGRAM
      //// compile directives
      //#pragma vertex vert_surf
      //#pragma fragment frag_surf
      //#pragma exclude_renderers xbox360 ps3
      //#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
      //#include "HLSLSupport.cginc"
      //#include "UnityShaderVariables.cginc"
      //// Surface shader code generated based on:
      //// writes to per-pixel normal: no
      //// writes to emission: no
      //// needs world space reflection vector: no
      //// needs world space normal vector: no
      //// needs screen space position: no
      //// needs world space position: no
      //// needs view direction: no
      //// needs world space view direction: no
      //// needs world space position for lighting: no
      //// needs world space view direction for lighting: YES
      //// needs world space view direction for lightmaps: no
      //// needs vertex color: no
      //// needs VFACE: no
      //// passes tangent-to-world matrix to pixel shader: no
      //// reads from normal: no
      //// 4 texcoords actually used
      ////   float2 _Control
      ////   float2 _Splat0
      ////   float2 _Splat1
      ////   float2 _Splat2
      //#define UNITY_PASS_META
      //#include "UnityCG.cginc"
      //#include "Lighting.cginc"

      //#define INTERNAL_DATA
      //#define WorldReflectionVector(data,normal) data.worldRefl
      //#define WorldNormalVector(data,normal) normal

      //// Original surface shader snippet:
      //#line 21 ""
      //#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
      //#endif

      ////#pragma surface surf T4MBlinnPhong
      ////#pragma exclude_renderers xbox360 ps3

      //sampler2D _Control;
      //sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
      //fixed _ShininessL0;
      //fixed _ShininessL1;
      //fixed _ShininessL2;
      //fixed _ShininessL3;
      //float4 _Tiling3;
      //fixed4 _SpecDir;

      //inline fixed4 LightingT4MBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
      //{
        //	fixed diff = max (0, dot (s.Normal, lightDir));
        //	//fixed nh = max (0, dot (s.Normal, halfDir));
        //	fixed nh = max (0, dot (normalize(s.Normal), normalize(halfDir+_SpecDir.xyz)));
        //	fixed spec = pow (nh, s.Specular*128) * s.Gloss;
        
        //	fixed4 c;
        //	//c.rgb = (s.Albedo * _LightColor0.rgb * diff + _SpecColor.rgb * spec) * (atten*2);
        //	c.rgb = (s.Albedo*_SpecColor.a+_SpecColor.rgb*spec)*(atten*2);
        //	c.a = 0.0;
        //	return c;
      //}

      //struct Input {
        //	float2 uv_Control : TEXCOORD0;
        //	float2 uv_Splat0 : TEXCOORD1;
        //	float2 uv_Splat1 : TEXCOORD2;
        //	float2 uv_Splat2 : TEXCOORD3;
        //	float2 uv_Splat3 : TEXCOORD4;
      //};
      
      //void surf (Input IN, inout SurfaceOutput o) {
        //	fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
        
        //	fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);
        //	fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
        //	fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);
        //	fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);
        //	o.Alpha = 0.0;
        //	o.Albedo.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
        //	o.Gloss = (lay1.a * splat_control.r + lay2.a * splat_control.g + lay3.a * splat_control.b + lay4.a * splat_control.a);
        //	o.Specular = (_ShininessL0 * splat_control.r + _ShininessL1 * splat_control.g + _ShininessL2 * splat_control.b + _ShininessL3 * splat_control.a);
      //}

      //#include "UnityMetaPass.cginc"

      //// vertex-to-fragment interpolation data
      //struct v2f_surf {
        //  float4 pos : SV_POSITION;
        //  float4 pack0 : TEXCOORD0; // _Control _Splat0
        //  float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
      //};
      //float4 _Control_ST;
      //float4 _Splat0_ST;
      //float4 _Splat1_ST;
      //float4 _Splat2_ST;

      //// vertex shader
      //v2f_surf vert_surf (appdata_full v) {
        //  v2f_surf o;
        //  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
        //  o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
        //  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
        //  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
        //  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
        //  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
        //  float3 worldPos = mul(_Object2World, v.vertex).xyz;
        //  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
        //  return o;
      //}

      //// fragment shader
      //fixed4 frag_surf (v2f_surf IN) : SV_Target {
        //  // prepare and unpack data
        //  Input surfIN;
        //  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
        //  surfIN.uv_Control.x = 1.0;
        //  surfIN.uv_Splat0.x = 1.0;
        //  surfIN.uv_Splat1.x = 1.0;
        //  surfIN.uv_Splat2.x = 1.0;
        //  surfIN.uv_Splat3.x = 1.0;
        //  surfIN.uv_Control = IN.pack0.xy;
        //  surfIN.uv_Splat0 = IN.pack0.zw;
        //  surfIN.uv_Splat1 = IN.pack1.xy;
        //  surfIN.uv_Splat2 = IN.pack1.zw;
        //  #ifdef UNITY_COMPILER_HLSL
        //  SurfaceOutput o = (SurfaceOutput)0;
        //  #else
        //  SurfaceOutput o;
        //  #endif
        //  o.Albedo = 0.0;
        //  o.Emission = 0.0;
        //  o.Specular = 0.0;
        //  o.Alpha = 0.0;
        //  o.Gloss = 0.0;
        //  fixed3 normalWorldVertex = fixed3(0,0,1);

        //  // call surface function
        //  surf (surfIN, o);
        //  UnityMetaInput metaIN;
        //  UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
        //  metaIN.Albedo = o.Albedo;
        //  metaIN.Emission = o.Emission;
        //  return UnityMetaFragment(metaIN);
      //}

      //ENDCG

    //}

    // ---- end of surface shader generated code
    
  }
  CustomEditor "WeatherSpecTerrainInspector"
  FallBack "Specular"
}