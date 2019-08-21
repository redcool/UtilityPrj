// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifndef NODE_LIB_CGINC
#define NODE_LIB_CGINC

// -- tangent to world matrix v2f.
#define V2F_TANGENT_TO_WORLD(id0,id1,id2) \
	float4 t2w0:TEXCOORD##id0; \
	float4 t2w1:TEXCOORD##id1; \
	float4 t2w2:TEXCOORD##id2

// -- tangent to world matrix vertex.
void TangentToWorldVertex(float3 vertex,float3 objectNormal,float4 objectTangent,out float4 t2w0,out float4 t2w1,out float4 t2w2){
	float3 n = UnityObjectToWorldNormal(objectNormal);
	float3 t = UnityObjectToWorldDir(objectTangent);
	float3 b = cross(n,t) * objectTangent.w;
	float3 worldPos = mul(unity_ObjectToWorld,vertex);

	t2w0 = float4(t.x,b.x,n.x,worldPos.x);
	t2w1 = float4(t.y,b.y,n.y,worldPos.y);
	t2w2 = float4(t.z,b.z,n.z,worldPos.z);
}

// -- tangent to world matrix fragment.
void TangentToWorldFrag(float3 packedNormal,float4 t2w0,float4 t2w1,float4 t2w2,
	out float3 worldPos,out float3 t,out float3 b,out float3 n)
{
	worldPos = float3(t2w0.w,t2w1.w,t2w2.w);
	t = normalize(float3(t2w0.x,t2w1.x,t2w2.x));
	b = normalize(float3(t2w0.y,t2w1.y,t2w2.y));
	n = normalize(float3(dot(t2w0.xyz,packedNormal),dot(t2w1.xyz,packedNormal),dot(t2w2.xyz,packedNormal)));
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

float Gray(float3 rgb){
	return dot(float3(0.07,0.7,0.2),rgb);
}

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