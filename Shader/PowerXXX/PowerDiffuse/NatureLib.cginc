#ifndef NATURE_LIB_CGINC
#define NATURE_LIB_CGINC
#include "DeviceLevel.cginc"
#include "GlobalControl.cginc"
/**
	常用的符号
*/
#define PI 3.1415
#define UP_AXIS float3(0,1,0)
bool _PlantsOn;
bool _Plants_Off;
bool _RippleOn;
bool _RainReflectionOn;
/**
	通用方法
*/

float Gray(float3 c) {
	return dot(float3(0.2, 0.7, 0.02), c);
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

float Remap(float a,float b,float x){
	float d = b-a;
	return x * (1.0/d) - a/d;
}

/**
	地形采样
*/
// --- terrain 4 splats;
fixed4 SampleSplats(float4 splat_control,float2 uv0,float2 uv1,float2 uv2,float2 uv3,sampler2D splat0,sampler2D splat1,sampler2D splat2,sampler2D splat3){
	fixed4 lay1 = tex2D (splat0, uv0);
	fixed4 lay2 = tex2D (splat1, uv1);
	fixed4 lay3 = tex2D (splat2, uv2);
	fixed4 lay4 = tex2D (splat3, uv3);

	fixed4 c = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
  	return c;
}

/**
	环绕对splat进行采样
	例:
	fixed4 lay1 = WrapSampleLayer (_Splat0, IN.uv_Splat0,_LayerWrap.x,_WrapLayerIntensity.x,_WrapOn);
*/
float4 WrapSampleLayer(sampler2D layer,float2 uv,float wrapIntensity,float intensity,float wrapMode){
	float4 col = tex2D(layer,uv);
	float4 wrapCol = col * tex2D(layer,uv*wrapIntensity) * intensity;
	return lerp(col,wrapCol,wrapMode);
}



/**
	涟漪公式
*/
float3 ComputeRipple(sampler2D rippleTex,float2 uv, float t)
{
	float4 ripple = tex2D(rippleTex, uv);
	ripple.yz = ripple.yz * 2.0 - 1.0;

	float drop = frac(ripple.a + t);
	float move = ripple.x + drop -1;
	float dropFactor = 1 - saturate(drop);

	float final = dropFactor * sin(clamp(move*9,0,4)*PI);
	return float3(ripple.yz * final,1);
}

/**
	植物风力
*/
// #ifdef PLANTS
#include "TerrainEngine.cginc"
float4 _Wave;
float4 _AttenField;
float3 _WorldPos;
float3 _WorldScale;

//#define PLANTS_IN_WORLD

float4 ClampVertexWave(appdata_full v, float4 wave, float yDist, float xzDist) {
#if defined(EXPAND_BILLBOARD)
    ExpandBillboard (UNITY_MATRIX_IT_MV, v.vertex, v.normal, v.tangent);
#endif
	//setup _Wind
	_Wind.w += _GlobalWindIntensity; // apply global wind
	_Wind.xyz += _GlobalWindDir;
	//_Wind.xyz = normalize(_Wind.xyz); 	//避免顶点拉伸

	float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
	float4 wavePos = AnimateVertex(worldPos, v.normal, float4(v.color.xy, v.texcoord1.xy)  * wave);

//calcuate atten
	xzDist *= abs(_WorldScale.x);
	yDist *= abs(_WorldScale.y);

	float3 attenField = float3(xzDist,yDist,xzDist);
	float3 worldPosOffset = worldPos - _WorldPos;
// #if defined(UP_Y) // y向上 或 合并之后
	float xzAtten = saturate(length(worldPosOffset.xz) - attenField.x);
	float yAtten = saturate(worldPosOffset.y - attenField.y);
// #else //z向上,未合并
// 	float xzAtten = saturate(length(worldPosOffset.xy) - attenField.x);
// 	float yAtten = saturate(worldPosOffset.z - attenField.y);
// #endif

	float atten = saturate(xzAtten + yAtten);
	atten *= WeatherIntensity();
	float4 vertex = lerp(worldPos,wavePos,atten);
	return mul(unity_WorldToObject, vertex);
}
// #endif // end PLANTS


/**
	积雪效果
*/

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
	float borderRate = lerp(-0.2,_BorderWidth,WeatherIntensity());
	float edge = 1 - Edge(mainColor.rgb,borderRate);

	// final color
	float4 snowColor = lerp(mainColor,_SnowColor,snowRate * edge);

#ifdef _HEIGHT_SNOW
	float yDist = (height - _Distance) * _DistanceAttenWidth + _DistanceAttenWidth;
	float yRate = lerp(0, 1, saturate(yDist));
	float4 heightSnowCol = lerp(0, _SnowColor, yRate) * edge * WeatherIntensity();
	snowColor = max(snowColor,heightSnowCol);
#endif
	fixed mapping = _ToneMapping * snowColor + 1;//lerp(0,snowColor,_ToneMapping) + 1;
	return float4(snowColor.rgb/mapping,mainColor.a);
}

// end SNOW
#endif

/**
	流水
	1 平面流水
	2 涟漪
*/
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
	samplerCUBE _EnvTex;
	sampler2D _EnvNoiseMap;
	sampler2D _FakeReflectionTex;
	float _EnvIntensity;
	float4 _EnvTileOffset;
	float4 _EnvColor;

	sampler2D _VertexWaveNoiseTex;

	float _WaveBorderWidth;

	float _DirAngle;
	float _WaveIntensity;

	//--- ripple
	sampler2D _RippleTex;
	float _RippleScale; // uv tiling
	float _RippleIntensity;
	float _RippleSpeed;
	float4 _RippleColorTint;

struct v2f_surface{
	float2 uv:TEXCOORD;
	float3 worldPos:TEXCOORD1;
	float3 normal:TEXCOORD2;
};

void SurfaceWaveVertex(float2 uv ,out float4 normalUV){
	normalUV = 0;

	// #if !defined(RIPPLE_ON)
	if(!_RippleOn)
		normalUV = uv.xyxy * _Tile + frac(_Time.xxxx* _Direction);
	// #endif
}

float4 SampleTexInRain(sampler2D tex,float2 uv,float4 defaultColor){
	// #if !defined(RIPPLE_ON)
	if(!_RippleOn)
		return tex2D(tex,uv);
	// #endif
	return defaultColor;
}

void NoiseUVNormal(float4 mainColor,float4 normalUV,float3 worldNormal,
		out float2 noiseUV,out float3 noiseNormal,out float edge){
	
	noiseUV = 0;
	noiseNormal = 0;
	edge = 0;

	// #if !defined(RIPPLE_ON) && defined(LEVEL_HIGH_PLUS)
	if(!_RippleOn && _RainReflectionOn){
		noiseNormal = UnpackNormal(tex2D(_WaveNoiseMap,normalUV.xy));
		noiseNormal += UnpackNormal(tex2D(_WaveNoiseMap,normalUV.zw));

		edge = 1 - Edge(mainColor.rgb,_WaveBorderWidth);
		fixed dirEdge = DirEdge(worldNormal,float3(0,1,0),1 - _DirAngle);
		edge *= dirEdge * _WaveIntensity * WeatherIntensity();

		noiseUV = noiseNormal.xy * 0.02 * edge;
	}
	// #endif
}

float3 CalcEnvReflection(float2 uv,float3 worldPos,float3 normal){
	float3 envNoise = UnpackNormal(tex2D(_EnvNoiseMap,uv * _EnvTileOffset.xy + frac(_Time.xx * _EnvTileOffset.zw)));

	float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
	float3 r = reflect(-v,normal + envNoise*0.2);
	float4 envTex = texCUBE(_EnvTex,r);
	float3 envColor = envTex.rgb *_EnvColor * _EnvIntensity * 0.2 * WeatherIntensity();
	return envColor * 0.2;
}

float3 RippleColor(float3 normal,float2 uv,
	sampler2D rippleTex,float rippleScale,float rippleSpeed,float rippleIntensity,float3 rippleColorTint){
		
	float3 ripple = ComputeRipple(rippleTex,uv * rippleScale, frac(_Time.y * rippleSpeed));
	#if defined(TERRAIN_WEATHER) //Terrain shader used
		rippleColorTint = 1;
	#endif
	rippleColorTint = ApplyWeather(rippleColorTint);
	return rippleColorTint+Luminance(ripple) * rippleIntensity*10; // max value is 10.
}

float4 SurfaceWaveFrag(v2f_surface i,float4 col,float3 noiseNormal,float edge,out float3 envColor){
	envColor = (float3)0;
	// #if defined(LEVEL_HIGH_PLUS)
	if(_RainReflectionOn)
		envColor = CalcEnvReflection(i.uv,i.worldPos,i.normal);
	// #endif
	
	//--------- use rain ripple.
	// #if defined(RIPPLE_ON)
	// 	#if defined(LEVEL_HIGH_PLUS)
	// 		float3 rippleColor = RippleColor(i.normal,i.uv ,_RippleTex,_RippleScale,_RippleSpeed,_RippleIntensity,_RippleColorTint);
	// 		col.rgb *= rippleColor;
	// 	#else
	// 		col.rgb *= ApplyWeather(_RippleColorTint.rgb);
	// 	#endif
	// #else
	// 	col.rgb *= ApplyWeather(_WaveColor.rgb);
	// #endif
	if(_RippleOn){
		if(_RainReflectionOn){
			float3 rippleColor = RippleColor(i.normal,i.uv ,_RippleTex,_RippleScale,_RippleSpeed,_RippleIntensity,_RippleColorTint);
			col.rgb *= rippleColor;
		}else{
			col.rgb *= ApplyWeather(_RippleColorTint.rgb);
		}
	}else{
		col.rgb *= ApplyWeather(_WaveColor.rgb);
	}
	return col;
}

float4 SurfaceWaveFrag(v2f_surface i,float4 col,float3 noiseNormal,float edge){
	float3 envColor = (float3)0;
	float4 mainColor = SurfaceWaveFrag(i,col,noiseNormal,edge,envColor);
	mainColor.rgb += envColor.rgb;
	return mainColor;
}
/**
	RIPPLE_ON未开时,用新uv重采样4texture,实现平面流水效果
	其余返回 defaultColor
*/
fixed4 SampleSplatsInRain(float4 splat_control,float2 uv0,float2 uv1,float2 uv2,float2 uv3,
	sampler2D _Splat0,sampler2D _Splat1,sampler2D _Splat2,sampler2D _Splat3,float4 defaultColor){

	// #if !defined(RIPPLE_ON)
	if(! _RippleOn)
		return SampleSplats(splat_control,uv0,uv1,uv2,uv3,_Splat0,_Splat1,_Splat2,_Splat3);
	// #endif
	return defaultColor;
}

float SplatIntensity(float4 splatControl,float4 layerIntensity){
	half4 control = splatControl * layerIntensity;
	return control.r + control.g + control.b + control.a;
}
/**
	地形,分层控制涟漪的强度.
	对LEVEL_HIGH_PLUS有效
*/
float4 TintTerrainColorByLayers(float4 originalCol,float4 finalCol,float3 envColor,float4 splat_control,
float4 waveLayerIntensity,float4 envSplatLayerIntensity,float4 tintColor){
	float4 col = originalCol;
	// #if defined(LEVEL_HIGH_PLUS)
	if(_RainReflectionOn){
		//每层流水(涟漪)强度控制
		float layerIntensity = SplatIntensity(splat_control,waveLayerIntensity);
		half4 layerColor = (originalCol - finalCol);
		col += (layerColor * layerIntensity);
		//每层环境反射的强度
		col.rgb += envColor * SplatIntensity(splat_control,envSplatLayerIntensity); 
	}
	// #endif

	col.rgb *= ApplyWeather(tintColor);
	return col;
}

#endif// end SURFACE_WAVE

#endif //NATURE_LIB_CGINC