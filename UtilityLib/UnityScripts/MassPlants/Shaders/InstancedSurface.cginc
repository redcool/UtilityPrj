

#ifndef INSTANCESURFACE_CGINC
#define INSTANCESURFACE_CGINC


#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
StructuredBuffer<float4> positionBuffer;
#endif

void setup()
{
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	float4 data = positionBuffer[unity_InstanceID];

	unity_ObjectToWorld._11_21_31_41 = float4(data.w, 0, 0, 0);
	unity_ObjectToWorld._12_22_32_42 = float4(0, data.w, 0, 0);
	unity_ObjectToWorld._13_23_33_43 = float4(0, 0, data.w, 0);
	unity_ObjectToWorld._14_24_34_44 = float4(data.xyz, 1);
	unity_WorldToObject = unity_ObjectToWorld;
	unity_WorldToObject._14_24_34 *= -1;
	unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
#endif
}


void vert(inout appdata_full v) {
	v.vertex.y += v.normal * sin(_Time.y)*0.1f;
}
#endif