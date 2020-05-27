#ifndef TANGENT_LIB_CGINC
#define TANGENT_LIB_CGINC

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
void TangentToWorldFrag(float3 normalTangent,float4 t2w0,float4 t2w1,float4 t2w2,
	out float3 worldPos,out float3 t,out float3 b,out float3 n)
{
	worldPos = float3(t2w0.w,t2w1.w,t2w2.w);
	t = normalize(float3(t2w0.x,t2w1.x,t2w2.x));
	b = normalize(float3(t2w0.y,t2w1.y,t2w2.y));
	n = normalize(float3(dot(t2w0.xyz,normalTangent),dot(t2w1.xyz,normalTangent),dot(t2w2.xyz,normalTangent)));
}

// macro type
#define TANGENT_TO_WORLD_VERT(vertex,objectNormal,objectTangent,v2f)\
	TangentToWorldVertex(vertex,objectNormal,objectTangent,v2f.t2w0,v2f.t2w1,v2f.t2w2);

#define TANGENT_TO_WORLD_FRAG(normalTangent,v2f)\
	float3 worldPos,tangentWorld,normalWorld,binormalWorld;\
	TangentToWorldFrag(normalTangent,v2f.t2w0,v2f.t2w1,v2f.t2w2,worldPos,tangentWorld,binormalWorld,normalWorld);\

/*
	使用 切线空间数据
		vertex shader计算即可.
		fragment shader直接使用 法线图数据即可.

	t: objectTangent
	n: objectNormal
*/
float3 WorldToTangent(float4 t,float3 n,float3 worldDir){
	float3 b = cross(n,t) * t.w;
	return float3(dot(float3(t.x,t.y,t.z),worldDir),dot(float3(b.x,b.y,b.z),worldDir),dot(float3(n.x,n.y,n.z),worldDir));
}
#endif