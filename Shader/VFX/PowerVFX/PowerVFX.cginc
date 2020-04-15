// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#if !defined(POWER_VFX_CGINC)
    #define POWER_VFX_CGINC

    fixed4 _Color;
    float _ColorScale;
    sampler2D _MainTex;
    half4 _MainTex_ST;
    int _MainTexOffsetStop;
    int _DoubleEffectOn; //2层效果,

    #if defined(DISTORTION_ON)
        sampler2D _NoiseTex;
        half4 _NoiseTex_ST;
        sampler2D _DistortionMaskTex;
        float _DistortionIntensity;
        float4 _DistortTile,_DistortDir;
    #endif

    #if defined(DISSOLVE_ON)
        sampler2D _DissolveTex;
        int _DissolveByVertexColor;
        int _DissolveByCustomData;
        int _DissolveTexUseR;
        float4 _DissolveTex_ST;
        float _Cutoff;
        float _EdgeWidth;
        float4 _EdgeColor;
    #endif

    #if defined(OFFSET_ON)
        sampler2D _OffsetTex;
        sampler2D _OffsetMaskTex;
        float4 _OffsetTexColorTint;
        float4 _OffsetTile,_OffsetDir;
        float _BlendIntensity;
    #endif

    #if defined(_GRAB_PASS)
        sampler2D _ScreenTex;
    #endif

    #if defined(FRESNAL_ON)
    float4 _FresnalColor;
    float _FresnalPower;
    int _FresnalTransparentOn;
    #endif

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal:NORMAL;
        float4 color : COLOR;
        half4 uv : TEXCOORD0; // xy:main uv,zw : particle's customData
    };

    struct v2f
    {
        float4 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float4 color : COLOR;
        float4 distortUV : TEXCOORD1;
        float4 offsetUV:TEXCOORD2;
        float4 dissolveUV:TEXCOORD3;
        float4 grabPos:TEXCOORD4;
        float4 fresnal:TEXCOORD5;// x:fresnal,y:customData.x
    };

    v2f vert(appdata v)
    {
        v2f o = (v2f)0;
        o.color = v.color;
        o.vertex = UnityObjectToClipPos(v.vertex);
        float2 offsetScale = lerp(_Time.xx,1,_MainTexOffsetStop);
        o.uv.xy = v.uv.xy * _MainTex_ST.xy + frac(_MainTex_ST.zw * offsetScale);//TRANSFORM_TEX(v.uv, _MainTex);
        //o.uv.xy += v.uv.zw; //default zw=0
        o.uv.zw = v.uv.xy;

        #if defined(DISTORTION_ON)
            o.distortUV = v.uv.xyxy * _DistortTile + frac(_DistortDir * _Time.xxxx);
        #endif

        #if defined(DISSOLVE_ON)
            o.dissolveUV.xy = TRANSFORM_TEX(v.uv.xy,_DissolveTex);
        #endif

        #if defined(OFFSET_ON)
            o.offsetUV = v.uv.xyxy * _OffsetTile + frac(_Time.xxxx * _OffsetDir);
        #endif

        #if defined(_GRAB_PASS)
            o.grabPos = ComputeGrabScreenPos(o.vertex);
        #endif
        #if defined(FRESNAL_ON)
        float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
        float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
        float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
        o.fresnal.x = 1 - dot(worldNormal,viewDir) ;
        #endif
        o.fresnal.y = v.uv.z;// particle custom data
        return o;
    }

    float4 SampleMainTex(float2 uv,float4 vertexColor){
        #if defined(_GRAB_PASS)
            float4 mainTex = tex2D(_ScreenTex,uv);
        #else
            float4 mainTex = tex2D(_MainTex,uv);
        #endif
        return mainTex * _Color * vertexColor * _ColorScale;
    }

    void ApplyDistortion(inout float4 mainColor,float2 mainUV,float4 distortUV,float4 color){
        #if defined(DISTORTION_ON)
            half3 noise = (tex2D(_NoiseTex, distortUV.xy));

            noise += _DoubleEffectOn > 0 ? tex2D(_NoiseTex, distortUV.zw).rgb : 0;
            // center noise uv.
            noise = (noise -0.5)*2;

            half3 ramp = tex2D(_DistortionMaskTex,mainUV);
            half2 uv = mainUV + noise * 0.2 *_DistortionIntensity * ramp.r;
            mainColor = SampleMainTex(uv,color);
        #endif
    }

    void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float customData){
        half4 edgeColor = (half4)0;
        #if defined(DISSOLVE_ON)
            half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
            half dissolve = lerp(dissolveTex.a,dissolveTex.r,_DissolveTexUseR);
            half gray = 1 - dissolve;

            // select cutoff
            half cutoff = _DissolveByVertexColor>0?1 - color.a : _Cutoff; // slider or vertex color
            cutoff = _DissolveByCustomData >0 ? 1- customData :cutoff; // slider or particle's custom data
            cutoff = lerp(-0.1,1.01,cutoff);

            half a = gray - cutoff;
            clip(a);

            half edge = 0;
            #if defined(DISSOLVE_EDGE_ON)
                half edgeRate = cutoff + _EdgeWidth;
                edge = step(gray,edgeRate);
                edgeColor = edge * _EdgeColor;

                // edge color fadeout.
                edgeColor.a = exp(-_Cutoff);
                // apply mainTex alpha
                edgeColor.a *= mainColor.a;
            #endif
            mainColor = lerp(mainColor,edgeColor,edge);
        #endif

    }

    void ApplyOffset(inout float4 color,float4 offsetUV,float2 mainUV){
        half4 offsetColor = (half4)1;
        #if defined(OFFSET_ON)
            offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
            offsetColor += _DoubleEffectOn > 0 ? tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint * 0.4 : 0;

            half4 offsetMask = tex2D(_OffsetMaskTex,mainUV);

            offsetColor *= _BlendIntensity;
            offsetColor *= offsetMask.r;
        #endif
        color.rgb *= offsetColor.rgb;
    }

    void ApplyFresnal(inout float4 mainColor,float fresnal){
        #if defined(FRESNAL_ON)
        float f =  saturate(smoothstep(fresnal,0,_FresnalPower));
        float4 fresnalColor = _FresnalColor *f;
        //mainColor += fresnalColor;
        mainColor = mainColor * 0.9 + fresnalColor;
        mainColor.a = lerp( f*2,mainColor.a,step(_FresnalTransparentOn,0));
        #endif
    }

    fixed4 frag(v2f i) : SV_Target
    {
        half4 mainColor = (half4)0;
        // setup mainUV
        float2 mainUV = i.uv.xy;
        #if defined(_GRAB_PASS)
            mainUV = i.grabPos.xy/i.grabPos.w;
        #endif
        
        #if defined(DISTORTION_ON)
            ApplyDistortion(mainColor,mainUV,i.distortUV,i.color);
        #else
            mainColor = SampleMainTex(mainUV ,i.color);
        #endif
        
        #if defined(OFFSET_ON)
            ApplyOffset(mainColor,i.offsetUV,i.uv.zw);
        #endif

        //dissolve
        #if defined(DISSOLVE_ON)
            ApplyDissolve(mainColor,i.dissolveUV,i.color,i.fresnal.y);
        #endif
        #if defined(FRESNAL_ON)
        ApplyFresnal(mainColor,i.fresnal);
        #endif

        return mainColor;
    }

#endif //POWER_VFX_CGINC