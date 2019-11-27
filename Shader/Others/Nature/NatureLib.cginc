
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f_surface members uv,worldPos,normalUV,normal)
#pragma exclude_renderers d3d11
#ifndef SNOW_CGINC
#define SNOW_CGINC


float Gray(float3 c) {
	return dot(float3(0.2, 0.7, 0.07), c);
}

float Edge(float3 c, float width) {
	float g = Gray(c);
	return smoothstep(g, g - 0.3, width);
}

float DirEdge(float3 dir1, float3 dir2, float delta) {
	return saturate(dot(dir1, dir2)) - delta;
}

float3 Saturate(float3 c,float value){
	float3 g = Gray(c);
	return lerp(g,c,value);
}

float3 Bright(float3 c,float value){
	return lerp(0,c,value);
}

half Remap(half a,half b,half x){
	half d = b-a;
	return x * (1.0/d) - a/d;
}

#ifdef PLANTS

#include "UnityBuiltin3xTreeLibrary.cginc"

inline float4 ClampWave(appdata_full v, float4 wave, float yRadius, float xzRadius) {
	float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

	float xzAtten = saturate(length(v.vertex.xz) - xzRadius);
	float yAtten = saturate(v.vertex.y - yRadius);
	float atten = xzAtten * yAtten;

	float4 wavePos = AnimateVertex(worldPos, v.normal, float4(v.color.xy, v.texcoord.xy)  * wave);

	float4 vertex = lerp(worldPos, wavePos, atten);
	return mul(unity_WorldToObject, vertex);
}
// end PLANTS
#endif

#ifdef _FEATURE_SNOW
#define SNOW_V2F(idx) float4 noiseUV:TEXCOORD##idx
#define SNOW_VERTEX(v2f) v2f.noiseUV = v2f.uv.xyxy * _SnowTile;

sampler2D _SnowNoiseMap;
float _NoiseDistortNormalIntensity;

float4 _SnowColor;
float4 _SnowTile;
float _SnowIntensity;

float4 _SnowDirection;
float _SnowAngleIntensity;
float4 _GlobalSnowDirection;
float _GlobalSnowAngleIntensity;

float4 _SnowRimColor;
float _BorderWidth;
float _ToneMapping; //reinhard mapping factor
//-------
#ifdef _HEIGHT_SNOW
float _Distance;
float _DistanceAttenWidth;
#endif



//vertex : compute final position
void SnowDir(float3 vertex, float3 normal, out float3 pos, out float3 worldNormal) {
	float3 worldPos = mul((float3x3)unity_ObjectToWorld, vertex);
	worldNormal = UnityObjectToWorldNormal(normal);

	float3 snowDir = normalize(_SnowDirection.xyz + _GlobalSnowDirection.xyz);
	float snowIntensity = clamp(_SnowDirection.w + _GlobalSnowDirection.w, 0, .2);

	float snowDot = saturate(dot(worldNormal, snowDir)) * snowIntensity;
	float upDot = saturate(dot(worldPos, float3(0, 1, 0)));

	pos = snowDir * snowDot * upDot;
	pos = mul((float3x3)unity_WorldToObject, worldPos + pos);
}

//fragment : final color
float4 SnowColor(float2 uv, float4 mainColor, float3 worldNormal, float3 worldPos, float height) {
	float2 noiseUV = worldPos.xz * _SnowTile;

	// normal 
	float3 n = worldNormal;
#ifdef SNOW_NOISE_MAP_ON
	float3 noise = UnpackNormal(tex2D(_SnowNoiseMap, noiseUV));
	n = worldNormal + noise * _NoiseDistortNormalIntensity;
	n = normalize(n);
#endif

	// dot
	float3 snowDir = normalize(_SnowDirection.xyz);
	float snowDot = saturate(dot(n, snowDir));
	float snowRate = smoothstep(snowDot, 0.1, 1 - _SnowAngleIntensity) * snowDot * 2;

	// mask
	float borderRate = lerp(-0.2,_BorderWidth,_SnowIntensity);
	float edge = 1 - Edge(mainColor.rgb,borderRate);

	// final color
	float4 snowColor = lerp(mainColor,_SnowColor,snowRate * edge);

#ifdef _HEIGHT_SNOW
	float yDist = (height - _Distance) * _DistanceAttenWidth + _DistanceAttenWidth;
	float yRate = lerp(0, 1, saturate(yDist));
	float4 heightSnowCol = lerp(0, _SnowColor, yRate)  * _SnowIntensity * edge;
	snowColor = max(snowColor,heightSnowCol);
#endif
	fixed mapping = lerp(0,snowColor,_ToneMapping) + 1;
	return snowColor/mapping;
}

// end SNOW
#endif


#if defined(_FEATURE_SURFACE_WAVE)
	float4  _WaveColor;
	float4  _Tile;
	float4  _Direction;
	float  _FresnalWidth;
	float  _VertexWaveIntensity;
	float  _VertexWaveSpeed;
	float  _SpecPower;
	float  _Glossness;
	float  _SpecWidth;

	sampler2D _WaveNoiseMap;
	samplerCUBE _ReflectionTex;
	sampler2D _FakeReflectionTex;
	sampler2D _VertexWaveNoiseTex;

	float _WaveBorderWidth;

	float _DirAngle;
	float _WaveIntensity;
	float _WaveIntensityScale;

struct v2f_surface{
	float2 uv;
	float3 worldPos;
	float3 normal;
};

void SurfaceWaveVertex(float2 uv ,out float4 normalUV){
	normalUV = uv.xyxy * _Tile + _Time.xxxx* _Direction;
}

void NoiseUVNormal(float4 mainColor,float4 normalUV,float3 worldNormal,
		out float2 noiseUV,out float3 noiseNormal,out float edge){
			
	noiseNormal = UnpackNormal(tex2D(_WaveNoiseMap,normalUV.xy));
	noiseNormal += UnpackNormal(tex2D(_WaveNoiseMap,normalUV.zw));

	edge = 1 - Edge(mainColor.rgb,_WaveBorderWidth);
	fixed dirEdge = DirEdge(worldNormal,float3(0,1,0),1 - _DirAngle);
	edge *= dirEdge * _WaveIntensity * _WaveIntensityScale;

	noiseUV = noiseNormal.xy * 0.02 * edge;
}

// float4 Sample(sampler2D tex,float2 uv,float4 normalUV){
// 	float3 n;
// 	float2 noiseUV;
// 	NoiseUVNormal(mainColor,normalUV,noiseUV,n);
// 	// sample the texture
// 	return tex2D(tex, uv + noiseUV);
// }

float4 SurfaceWaveFrag(v2f_surface i,float4 col,float3 noiseNormal,float edge){
	float4 waterColor = _WaveColor;
	float fresnalWidth =  _FresnalWidth;
	float specPower = _SpecPower;
	float glossness = _Glossness;
	float specWidth = _SpecWidth;

	float2 uv = normalize(i.worldPos.xz);
	float3 worldNormal = UnityObjectToWorldNormal(i.normal);
	float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
	float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
	float3 h = normalize(l+v);

	col = lerp(col,col * waterColor,edge);
	//col /= (1+col);
return col*0.75;
	//-------------- diffuse
	float nl = saturate(dot(worldNormal, l));
	fixed3 diffCol = nl * col.rgb;

	//--------------- fresnal
	float nv = dot(worldNormal,v);
	float invertNV = 1-nv;
	fixed3 fresnal = pow(invertNV ,fresnalWidth);//smoothstep(invertNV,invertNV*0.9,_FresnalWidth);

	//--------------specular
	float nh = saturate(dot(worldNormal,h));
	float spec = pow(nh,specPower * 128) * glossness;
	spec += smoothstep(spec,spec*0.9,specWidth);
	float3 specCol = spec * _LightColor0.rgb;

	//--------------- reflection
	float3 r = reflect(-v,worldNormal);
	float3 reflCol = texCUBE(_ReflectionTex,r + noiseNormal );
	reflCol += tex2D(_FakeReflectionTex,i.uv + noiseNormal.xy * 2);

//return float4(col + specCol,1);
	col.rgb += diffCol+specCol+ fresnal;
//				return col;
	col.rgb *= reflCol * col.a;

	return col;
}

// end SURFACE_WAVE
#endif
// end outer
#endif