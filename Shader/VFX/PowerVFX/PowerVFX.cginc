#if !defined(POWER_VFX_CGINC)
#define POWER_VFX_CGINC

fixed4 _Color;
sampler2D _MainTex;
half4 _MainTex_ST;
int _MainTexOffsetOn;

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

struct appdata
{
    float4 vertex : POSITION;
    float3 normal:NORMAL;
    float4 color : COLOR;
    half4 uv : TEXCOORD0; // xy:main uv,zw : particle's customData
};

struct v2f
{
    half4 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    fixed4 color : COLOR;

    #if defined(DISTORTION_ON)
    fixed4 distortUV : TEXCOORD1;
    #endif

    #if defined(OFFSET_ON)
    half4 offsetUV:TEXCOORD2;
    #endif

    #if defined(DISSOLVE_ON)
    half4 dissolveUV:TEXCOORD3;
    #endif
};

v2f vert(appdata v)
{
    v2f o = (v2f)0;
    o.color = v.color;
    o.vertex = UnityObjectToClipPos(v.vertex);
    float2 offsetScale = lerp(1,_Time.xx,_MainTexOffsetOn);
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

    return o;
}

void ApplyDistortion(inout float4 mainColor,float2 mainUV,float4 distortUV,float4 color){
    #if defined(DISTORTION_ON)
        half3 noise = (tex2D(_NoiseTex, distortUV.xy));

        #if defined(DOUBLE_EFFECT)
        noise += (tex2D(_NoiseTex, distortUV.zw));
        #endif

        half3 ramp = tex2D(_DistortionMaskTex,mainUV);

        half2 uv = mainUV + noise * 0.2 *_DistortionIntensity * ramp.r;

        mainColor = tex2D(_MainTex,uv) * _Color * color;
    #endif
}

void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color){
    half4 edgeColor = (half4)0;
    #if defined(DISSOLVE_ON)
        half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
        half dissolve = lerp(dissolveTex.a,dissolveTex.r,_DissolveTexUseR);
        half gray = 1 - dissolve;

        // select cutoff
        half cutoff = lerp(_Cutoff,1 - color.a,_DissolveByVertexColor);
        cutoff = lerp(-0.1,1.01,cutoff);

        half a = gray - cutoff;
        clip(a);

        half edge = 0;
        #if defined(DISSOLVE_EDGE_ON)
            half edgeRate = cutoff + _EdgeWidth;
            //edge = smoothstep(gray,gray+0.05,edgeRate);

            edge = step(gray,edgeRate);
            edgeColor = edge * _EdgeColor;

            //edge fade out
            edgeColor.a = exp(-_Cutoff);
        #endif
        mainColor = lerp(mainColor,edgeColor,edge);
    #endif

}

void ApplyOffset(inout float4 color,float4 offsetUV,float2 mainUV){
    half4 offsetColor = (half4)1;
    #if defined(OFFSET_ON)
        offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
        
        #if defined(DOUBLE_EFFECT)
        offsetColor += tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint * 0.4;
        #endif

        half4 offsetMask = tex2D(_OffsetMaskTex,mainUV);

        offsetColor *= _BlendIntensity;
        offsetColor *= offsetMask.r;
    #endif
    color.rgb *= offsetColor.rgb;
}

fixed4 frag(v2f i) : SV_Target
{
    half4 mainColor = (half4)0;
    #if defined(DISTORTION_ON)
        ApplyDistortion(mainColor,i.uv.xy,i.distortUV,i.color);
    #else
        mainColor = tex2D(_MainTex,i.uv.xy) * _Color * i.color;
    #endif
    
    #if defined(OFFSET_ON)
    ApplyOffset(mainColor,i.offsetUV,i.uv.zw);
    #endif

    //dissolve
    half4 edgeColor = (half4)0;
    #if defined(DISSOLVE_ON)
        ApplyDissolve(mainColor,i.dissolveUV,i.color);
    #endif

    return mainColor;
}

#endif //POWER_VFX_CGINC