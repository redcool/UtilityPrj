// Based on sGame shader fur10layer
// would change 10 layers to 5 layers if optimization is needed

#ifndef SG3_FUR_INCLUDED
#define SG3_FUR_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardBRDF.cginc"

half4 _Color, _AmbientColor, _SpecularColor, _AoColor;
sampler2D _MainTex, _SubTex;
float4 _MainTex_ST, _SubTex_ST, _Gravity, _Wind, _UVoffset;
half _FresnelIntensity, _FresnelPower, _Shininess, _Transmission, 
     _tming, _dming, _Spacing;

struct VertexInputFur
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    fixed4 color : COLOR;
};

struct VertexOutputFur
{
	float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;
	half4 vertLit : TEXCOORD1;
    UNITY_FOG_COORDS(2)
};

VertexOutputFur vertFurBase(appdata_base v)
{
    VertexOutputFur o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputFur, o); 
    
    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    o.pos = mul(unity_MatrixVP, posWorld);
    o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);

    float3 normalDirWS = normalize(UnityObjectToWorldNormal(v.normal));
    float3 lightDirWS = normalize(_WorldSpaceLightPos0.xyz);
	float3 viewDirWS = normalize(_WorldSpaceCameraPos - posWorld.xyz);
	float3 halfDir = Unity_SafeNormalize(lightDirWS + viewDirWS);

    half diff = max (0, dot (normalDirWS, lightDirWS));
    diff = saturate((diff * (_Transmission + 1.0) + _Transmission * 0.5));
    half nh = max (0, dot (normalDirWS, halfDir));
    half spec = pow (nh, _Shininess * 64.0) * _SpecularColor;

    o.vertLit.xyz = (diff + spec) * _Color.rgb + _AmbientColor.rgb;

    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

half4 fragFurBase(VertexOutputFur i) : SV_Target
{
	half3 albedo = tex2D(_MainTex, i.uv.xy).xyz;
    half3 col = albedo * i.vertLit;

    UNITY_APPLY_FOG(i.fogCoord, col); 
	return half4(col, 1.0);
}

VertexOutputFur vertFur(VertexInputFur v)
{
    VertexOutputFur o;
    
    // force 
    float3 force;
    force.x = sin(_Time.y * 1.5 * _Wind.z + v.vertex.x * 0.5 * _Wind.x) * _Wind.w;
	force.y = cos(_Time.y * 0.5 * _Wind.z + v.vertex.y * 0.4 * _Wind.y) * _Wind.w;
	force.z = sin(_Time.y * 0.7 * _Wind.z + v.vertex.y * 0.3 * _Wind.x) * _Wind.w;
    float3 forceGravity = force + _Gravity.xyz;

    float3 offset = (forceGravity * FORCE + v.normal) * UV 
                    * _Spacing * 0.1 * saturate(v.color.w + _Gravity.w);

   	float4 newPos = {0.0, 0.0, 0.0, 1.0};
	newPos.xyz = v.vertex.xyz + offset;

    // new pos
    float4 posWorld = mul(unity_ObjectToWorld, newPos);
    o.pos = mul(unity_MatrixVP, posWorld);

    // uv offset
    float2 uvScale = float2(force.x * _UVoffset.z * UV, force.y * _UVoffset.w * UV);
    float2 uvOffset = (uvScale + _UVoffset.xy * UV) * 0.1;
	float2 uvMain = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
    float2 uvSub = _SubTex_ST.xy;

    o.uv.xy = uvMain + uvOffset / uvSub;
	o.uv.zw = uvMain * uvSub + uvOffset;

    // vectors 
    float3 normalDirWS = normalize(UnityObjectToWorldNormal(v.normal));
    float3 lightDirWS = normalize(_WorldSpaceLightPos0.xyz);
	float3 viewDirWS = normalize(_WorldSpaceCameraPos - posWorld.xyz);
	float3 halfDir = Unity_SafeNormalize(lightDirWS + viewDirWS);

    // fresnel 
    half fresnelTerm = pow(1.0 - saturate(dot(normalDirWS, viewDirWS)), _FresnelPower);
    half fresnel = fresnelTerm * _FresnelIntensity * FRESNEL;

    // ao and ambient
    half3 ao = (_AoColor * _AmbientColor - _AmbientColor) * (1.0 - FORCE);
    half3 ambient = ao + _AmbientColor * fresnel + _AmbientColor;

    // blinnPhong
    half diff = max (0, dot (normalDirWS, lightDirWS));
    half nh = max (0, dot (normalDirWS, halfDir));
    half spec = pow (nh, _Shininess * 64.0) * _SpecularColor;

    // transmission and spacing
    half lit = saturate(saturate((diff * (_Transmission + 1.0) + _Transmission * 0.5))
			   + _Spacing * SPACING); 

    // light combine
    o.vertLit.xyz = (lit + spec) * _Color.rgb + ambient;
    o.vertLit.a = v.color.a * _Color.a;

    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

half4 fragFur(VertexOutputFur i) : SV_Target
{
    // albedo
	half3 albedo = tex2D(_MainTex, i.uv.xy).xyz;
    half3 col = i.vertLit.rgb * albedo;
    // alpha
    half noise = tex2D(_SubTex, i.uv.zw).x;
    half dming = (1.0 - i.vertLit.a * _dming) * DMING + FORCE;
    half tming = saturate(noise * 2.0 - dming) * _tming;
    
    UNITY_APPLY_FOG(i.fogCoord, col); 
	return half4(col, tming);
}

#endif