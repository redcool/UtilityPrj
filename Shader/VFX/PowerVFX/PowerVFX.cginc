#if !defined(POWER_VFX_CGINC)
#define POWER_VFX_CGINC

fixed4 _Color;
sampler2D _MainTex;
half4 _MainTex_ST;

#if defined(DISTORTION_ON)
sampler2D _NoiseTex;
half4 _NoiseTex_ST;
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
int _OffsetBlend2Layers;
sampler2D _OffsetTex;
float4 _OffsetTex_ST;
float4 _OffsetTile,_OffsetDir;
float _BlendIntensity;
#endif

struct appdata
{
    float4 vertex : POSITION;
    half2 uv : TEXCOORD0;
    fixed4 color : COLOR;
};

struct v2f
{
    half4 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    fixed4 color : COLOR;
    fixed4 distortUV : TEXCOORD1;

    #if defined(OFFSET_ON)
    half4 offsetUV:TEXCOORD2;
    #endif
    #if defined(DISSOLVE_ON)
    half4 dissolveUV:TEXCOORD3;
    #endif
};

v2f vert(appdata v)
{
    v2f o;
    o.color = v.color;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv.xy = v.uv * _MainTex_ST.xy + _MainTex_ST.zw * _Time.xx;//TRANSFORM_TEX(v.uv, _MainTex);

    #if defined(DISTORTION_ON)
    o.distortUV = v.uv.xyxy * _DistortTile + _DistortDir * _Time.xxxx;
    #endif

    #if defined(OFFSET_ON)
    o.offsetUV = v.uv.xyxy * _OffsetTile + _Time.xxxx * _OffsetDir;
    #endif

    #if defined(DISSOLVE_ON)
    o.dissolveUV.xy = TRANSFORM_TEX(v.uv,_DissolveTex);
    #endif

    return o;
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
            half dist = 1 - length(dissolveUV - 0.5);
            dist = min(mainColor.a,dist);
            edgeColor.a = dist;
        #endif
        mainColor = lerp(mainColor,edgeColor,edge);
    #endif

}
void ApplyDistortion(inout float4 mainColor,float2 mainUV,float4 distortUV,float4 color){
    #if defined(DISTORTION_ON)
        half3 noise = UnpackNormal(tex2D(_NoiseTex, distortUV.xy));
        noise += UnpackNormal(tex2D(_NoiseTex, distortUV.zw));
        half2 uv = mainUV + noise * 0.2 *_DistortionIntensity;

        mainColor = tex2D(_MainTex,uv) * _Color * color;
    #endif
}

void ApplyOffset(inout float4 color,float4 offsetUV){
    half4 offsetColor = (half4)1;
    #if defined(OFFSET_ON)
        offsetColor = tex2D(_OffsetTex,offsetUV.xy);
        offsetColor += lerp(0,tex2D(_OffsetTex,offsetUV.zw),_OffsetBlend2Layers) *0.4;

        offsetColor *= _BlendIntensity;
    #endif
    color.rgb *= offsetColor.rgb;
}

fixed4 frag(v2f i) : SV_Target
{
    half4 mainColor = (half4)0;
    #if defined(DISTORTION_ON)
        ApplyDistortion(mainColor,i.uv,i.distortUV,i.color);
    #else
        mainColor = tex2D(_MainTex,i.uv) * _Color * i.color;
    #endif
    
    #if defined(OFFSET_ON)
    ApplyOffset(mainColor,i.offsetUV);
    #endif

    //dissolve
    half4 edgeColor = (half4)0;
    #if defined(DISSOLVE_ON)
        ApplyDissolve(mainColor,i.dissolveUV,i.color);
    #endif

    return mainColor;
}

#endif //POWER_VFX_CGINC