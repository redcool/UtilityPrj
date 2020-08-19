#if !defined(GLOBAL_CONTROL_CGINC)
#define GLOBAL_CONTROL_CGINC

/**
 	全局,由WeatherShader.cs传递.
*/
#define WEATHER_GLOBAL_CONTROL //受代码控制

float _WeatherIntensity;
float _ThunderIntensity; //雷电强度[0,1]
int _DeviceLevel; //设备等级.[1,2,3,4]

float _GlobalWindIntensity; //全局的风力
float3 _GlobalWindDir; //全局风向

float _DayIntensity;//昼夜强度
int _DaytimeOn; //材质的昼夜开关
int _SceneDayTimeOn; //场景的昼夜开关,通过DayTimeProcess传递

sampler2D _NightLightmap;
float _NightLightmapIntensity;

float WeatherIntensity(){
	#if defined(WEATHER_GLOBAL_CONTROL)
		return _WeatherIntensity;
	#endif
	return 1;
}

float DayIntensity(bool useLightmap){
	#if defined(WEATHER_GLOBAL_CONTROL)
		float intensity = _DayIntensity==0 ? 1 : _DayIntensity; //排除0的情况.
		intensity = (useLightmap && _NightLightmapIntensity == 1) ? 1 : intensity;//使用夜晚光照图
		intensity = _SceneDayTimeOn > 0 ? intensity : 1; //场景的昼夜开关
		return _DaytimeOn > 0 ? intensity : 1;
	#endif
	return 1;
}

float InverseDayIntensity(bool useLightmap){
	float intensity = _DaytimeOn > 0 ? 1 - DayIntensity(useLightmap) : 1; //材质昼夜开关处理
	intensity = _SceneDayTimeOn > 0 ? intensity : 1; //场景昼夜开关处理
	return intensity;
}

/**
	叠加天气强度
*/
#define ApplyWeather(weatherColor) lerp(1,weatherColor,WeatherIntensity()) ;

/**
	叠加雷电强度
*/
float3 ApplyThunder(float3 c) {
	return c + _ThunderIntensity;
}
float4 ApplyThunder(float4 c) {
	return c + _ThunderIntensity;
}

/**
	Blend Day Night Lightmap
*/

float3 BlendNightLightmap(float2 uv){
	half3 nightColor = DecodeLightmap(tex2D(_NightLightmap, uv));
	half3 bakedColor = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uv));
	/**
		无昼夜效果时,_DayIntensity为0,
		此时,使用白天光照图
	*/
	half intensity = _DayIntensity == 0 ? 1 : _DayIntensity; 
	
	float3 blendColor = lerp(nightColor,bakedColor,intensity);
	return _DaytimeOn ? blendColor : bakedColor;
}

#endif //GLOBAL_CONTROL_CGINC