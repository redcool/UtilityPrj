#if !defined(BLEND_4_TEXTURES_ADD_PASS_CGINC)
#define BLEND_4_TEXTURES_ADD_PASS_CGINC

      #define INTERNAL_DATA
      #define WorldReflectionVector(data,normal) data.worldRefl
      #define WorldNormalVector(data,normal) normal

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
      
      void surf_add (Input IN, inout SurfaceOutput o) {
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
         surf_add (surfIN, o);
         UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
         fixed4 c = 0;
         c += LightingT4MBlinnPhong (o, lightDir, worldViewDir, atten);
         c.a = 0.0;
         UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
         UNITY_OPAQUE_ALPHA(c.a);
         return c;
      }

#endif //BLEND_4_TEXTURES_ADD_PASS_CGINC