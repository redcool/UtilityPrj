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
void TangentToWorldFrag(float3 packedNormal,float4 t2w0,float4 t2w1,float4 t2w2,
	out float3 worldPos,out float3 t,out float3 b,out float3 n)
{
	worldPos = float3(t2w0.w,t2w1.w,t2w2.w);
	t = normalize(float3(t2w0.x,t2w1.x,t2w2.x));
	b = normalize(float3(t2w0.y,t2w1.y,t2w2.y));
	n = normalize(float3(dot(t2w0.xyz,packedNormal),dot(t2w1.xyz,packedNormal),dot(t2w2.xyz,packedNormal)));
}
#endif