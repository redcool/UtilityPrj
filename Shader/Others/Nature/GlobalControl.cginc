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

float WeatherIntensity(){
	#if defined(WEATHER_GLOBAL_CONTROL)
		return _WeatherIntensity;
	#endif
	return 1;
}

/**
	叠加天气强度
*/
#define ApplyWeather(weatherColor) lerp(1,weatherColor,WeatherIntensity());

/**
	叠加雷电强度
*/
float3 ApplyThunder(float3 c) {
	return c + _ThunderIntensity;
}
float4 ApplyThunder(float4 c) {
	return c + _ThunderIntensity;
}
#endif //GLOBAL_CONTROL_CGINC