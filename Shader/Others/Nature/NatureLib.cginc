
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

// --- global vars
half _WeatherIntensity;

#ifdef PLANTS

float4 _Wave;
float4 _AttenField;

#include "TerrainEngine.cginc"

inline float4 ClampVertexWave(appdata_full v, float4 wave, float yDist, float xzDist) {
#if defined(EXPAND_BILLBOARD)
    ExpandBillboard (UNITY_MATRIX_IT_MV, v.vertex, v.normal, v.tangent);
#endif

	float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

	_Wind.xyz = normalize(_Wind.xyz); 	//避免顶点拉伸
	float4 wavePos = AnimateVertex(worldPos, v.normal, float4(v.color.xy, v.texcoord1.xy)  * wave);

#if defined(UP_Y) // y向上
	float xzAtten = saturate(length(v.vertex.xz) - xzDist);
	float yAtten = saturate(v.vertex.y - yDist);
#else //z向上
	float xzAtten = saturate(length(v.vertex.xy) - xzDist);
	float yAtten = saturate(v.vertex.z - yDist);
#endif

	float atten = saturate(xzAtten + yAtten);

	float4 vertex = lerp(worldPos,wavePos,atten);

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

float4 _SnowDirection;
float _SnowAngleIntensity;
float4 _GlobalSnowDirection;
float _GlobalSnowAngleIntensity;

float4 _SnowRimColor;
float _BorderWidth;
float _ToneMapping; //reinhard mapping factor
float _DefaultSnowRate = 1.5;
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

#if !defined(DISABLE_SNOW_DIR)
	// dot
	float3 snowDir = normalize(_SnowDirection.xyz);
	float snowDot = saturate(dot(n, snowDir));
	float snowRate = smoothstep(snowDot, 0.1, 1 - _SnowAngleIntensity) * snowDot * 2;
#else
	float snowRate = _DefaultSnowRate;
#endif

	// mask
	float borderRate = lerp(-0.2,_BorderWidth,_WeatherIntensity);
	float edge = 1 - Edge(mainColor.rgb,borderRate);

	// final color
	float4 snowColor = lerp(mainColor,_SnowColor,snowRate * edge);

#ifdef _HEIGHT_SNOW
	float yDist = (height - _Distance) * _DistanceAttenWidth + _DistanceAttenWidth;
	float yRate = lerp(0, 1, saturate(yDist));
	float4 heightSnowCol = lerp(0, _SnowColor, yRate)  * _WeatherIntensity * edge;
	snowColor = max(snowColor,heightSnowCol);
#endif
	fixed mapping = _ToneMapping * snowColor + 1;//lerp(0,snowColor,_ToneMapping) + 1;
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
	edge *= dirEdge * _WaveIntensity * _WeatherIntensity;

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

	col = lerp(col,col * _WaveColor,edge);
	//col /= (1+col);
return col;

	float3 l = half3(0,.8,0);//normalize(UnityWorldSpaceLightDir(i.worldPos));
	float3 worldNormal = normalize(i.normal);
	//-------------- diffuse
	float nl = saturate(dot(worldNormal, l));
	fixed3 diffCol = nl * col.rgb;
	col.rgb += diffCol * 0.2;

//return float4(diffCol,1);
	//--------------- fresnal
	float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
	float nv = dot(worldNormal,v);
	float invertNV = 1-nv;
	fixed3 fresnal = pow(invertNV ,_FresnalWidth);//smoothstep(invertNV,invertNV*0.9,_FresnalWidth);
	col.rgb += fresnal * 0.2;

	//--------------specular
	float3 h = normalize(l+v);
	float nh = saturate(dot(noiseNormal*nl,h));
	//float spec = smoothstep(nh-0.9,nh,_SpecWidth)*nl;
	float spec = pow(nh,_SpecPower * 32) * _Glossness;
	spec *= smoothstep(spec,spec-0.3,_SpecWidth);
	float3 specCol = spec ;
	col.rgb += specCol * 0.2;

//return col + fixed4(diffCol + specCol,1);
	//--------------- reflection
	float2 uv = normalize(i.worldPos.xz);	
	float3 r = reflect(-v,worldNormal);
	float3 reflCol = texCUBE(_ReflectionTex,r + noiseNormal );
	reflCol += tex2D(_FakeReflectionTex,i.uv + noiseNormal.xy * 2);
	//reflCol *= 0.4;
	col.rgb += reflCol * 0.08;

	//col.rgb += (diffCol+specCol+fresnal+reflCol)*0.2;
	return col;
}

// end SURFACE_WAVE
#endif
// end outer
#endif