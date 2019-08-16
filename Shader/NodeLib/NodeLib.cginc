#ifndef NODE_LIB_CGINC
#define NODE_LIB_CGINC

//input

float3 _Camera_Position() { return _WorldSpaceCameraPos; }
//float3 _Camera_Direction() { return -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V))[2].xyz); }
float _Camera_Orthographic() { return unity_OrthoParams.w; }
float _Camera_NearPlane() { return _ProjectionParams.y; }
float _Camera_FarPlane() { return _ProjectionParams.z; }
float _Camera_ZBufferSign() { return _ProjectionParams.x; }
float _Camera_Width() { return unity_OrthoParams.x; }
float _Camera_Height() { return unity_OrthoParams.y; }

//artistic
float3 NormalStrength(float3 n, float strength) {
	return float3(n.rg * strength, lerp(1, n.b, saturate(strength)));
}

float3 BlendNormal(float3 a, float3 b) {
	return normalize(float3(a.rb + b.rg, a.b*b.b));
}

float SimpleFresnal(float3 v, float3 n, float power) {
	return pow(1 - saturate(dot(normalize(n), normalize(v))), power);
}


float SchlickFresnal2(float3 v, float h, float f0) {
	float base = 1 - dot(v, h);
	float power = pow(base, 5.0);
	return power + f0 * (1 - power);
}


float SchlickFresnal(float3 v, float3 n, float f0) {
	return f0 + (1 - f0) * pow(1 - dot(v, n), 5);
}

float Random(float s) {
	return frac(sin(s) * 100000);
}

inline float unity_noise_randomValue(float2 uv)
{
	return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
}

inline float unity_noise_interpolate(float a, float b, float t)
{
	return (1.0 - t)*a + (t*b);
}

inline float unity_valueNoise(float2 uv)
{
	float2 i = floor(uv);
	float2 f = frac(uv);
	f = f * f * (3.0 - 2.0 * f);

	uv = abs(frac(uv) - 0.5);
	float2 c0 = i + float2(0.0, 0.0);
	float2 c1 = i + float2(1.0, 0.0);
	float2 c2 = i + float2(0.0, 1.0);
	float2 c3 = i + float2(1.0, 1.0);
	float r0 = unity_noise_randomValue(c0);
	float r1 = unity_noise_randomValue(c1);
	float r2 = unity_noise_randomValue(c2);
	float r3 = unity_noise_randomValue(c3);

	float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
	float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
	float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
	return t;
}

void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
	float t = 0.0;

	float freq = pow(2.0, float(0));
	float amp = pow(0.5, float(3 - 0));
	t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	freq = pow(2.0, float(1));
	amp = pow(0.5, float(3 - 1));
	t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	freq = pow(2.0, float(2));
	amp = pow(0.5, float(3 - 2));
	t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	Out = t;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
	Out = UV * Tiling + Offset;
}

#endif